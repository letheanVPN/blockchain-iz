// Copyright (c) 2014-2017, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// Parts of this file are originally copyright (c) 2012-2013 The Cryptonote developers
#include <boost/asio/ip/address.hpp>
#include <boost/filesystem/operations.hpp>
#include <cstdint>
#include "include_base_utils.h"
using namespace epee;

#include "wallet_vpn_rpc_server.h"
#include "wallet/wallet_args.h"
#include "common/command_line.h"
#include "common/i18n.h"
#include "common/util.h"
#include "cryptonote_basic/cryptonote_format_utils.h"
#include "cryptonote_basic/account.h"
#include "wallet_rpc_server_commands_defs.h"
#include "misc_language.h"
#include "string_coding.h"
#include "string_tools.h"
#include "crypto/hash.h"
#include "mnemonics/electrum-words.h"
#include "rpc/rpc_args.h"
#include "rpc/core_rpc_server_commands_defs.h"

#undef MONERO_DEFAULT_LOG_CATEGORY
#define MONERO_DEFAULT_LOG_CATEGORY "wallet.vpn.rpc"

namespace
{
  const command_line::arg_descriptor<std::string, true> arg_rpc_bind_port = {"vpn-rpc-bind-port", "Sets bind port for VPN RPC server"};
  const command_line::arg_descriptor<bool> arg_trusted_daemon = {"trusted-daemon", "Enable commands which rely on a trusted daemon", false};

  constexpr const char default_rpc_username[] = "letheanvpn";
}

namespace tools
{
	const char* wallet_vpn_rpc_server::tr(const char* str)
	{
		return i18n_translate(str, "tools::wallet_vpn_rpc_server");
	}

	//------------------------------------------------------------------------------------------------------------------------------
	wallet_vpn_rpc_server::wallet_vpn_rpc_server() :m_wallet(NULL), rpc_login_filename(), m_stop(false), m_trusted_daemon(false)
	{
	}
	//------------------------------------------------------------------------------------------------------------------------------
	wallet_vpn_rpc_server::~wallet_vpn_rpc_server()
	{
		try
		{
			boost::system::error_code ec{};
			boost::filesystem::remove(rpc_login_filename, ec);
		}
		catch (...) {}
	}
	//------------------------------------------------------------------------------------------------------------------------------
	void wallet_vpn_rpc_server::set_wallet(wallet2 *cr)
	{
		m_wallet = cr;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::run()
	{
		m_stop = false;
		m_net_server.add_idle_handler([this]() {
			try {
				if (m_wallet) m_wallet->refresh();
			}
			catch (const std::exception& ex) {
				LOG_ERROR("Exception at while refreshing, what=" << ex.what());
			}
			return true;
		}, 20000);
		m_net_server.add_idle_handler([this]() {
			if (m_stop.load(std::memory_order_relaxed))
			{
				send_stop_signal();
				return false;
			}
			return true;
		}, 500);

		//DO NOT START THIS SERVER IN MORE THEN 1 THREADS WITHOUT REFACTORING
		return epee::http_server_impl_base<wallet_vpn_rpc_server, connection_context>::run(1, true);
	}
	//------------------------------------------------------------------------------------------------------------------------------
	void wallet_vpn_rpc_server::stop()
	{
		if (m_wallet)
		{
			m_wallet->store();
			delete m_wallet;
			m_wallet = NULL;
		}
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::init(const boost::program_options::variables_map *vm)
	{
		auto rpc_config = cryptonote::rpc_args::process(*vm);
		if (!rpc_config)
			return false;

		m_vm = vm;
		tools::wallet2 *walvars;
		std::unique_ptr<tools::wallet2> tmpwal;

		if (m_wallet)
			walvars = m_wallet;
		else
		{
			tmpwal = tools::wallet2::make_dummy(*m_vm);
			walvars = tmpwal.get();
		}
		boost::optional<epee::net_utils::http::login> http_login{};
		std::string bind_port = command_line::get_arg(*m_vm, arg_rpc_bind_port);
		m_trusted_daemon = command_line::get_arg(*m_vm, arg_trusted_daemon);
		if (!command_line::has_arg(*m_vm, arg_trusted_daemon))
		{
			if (tools::is_local_address(walvars->get_daemon_address()))
			{
				MINFO(tr("Daemon is local, assuming trusted"));
				m_trusted_daemon = true;
			}
		}

		if (!rpc_config->login)
		{
			std::array<std::uint8_t, 16> rand_128bit{ {} };
			crypto::rand(rand_128bit.size(), rand_128bit.data());
			http_login.emplace(
				default_rpc_username,
				string_encoding::base64_encode(rand_128bit.data(), rand_128bit.size())
			);
		}
		else
		{
			http_login.emplace(
				std::move(rpc_config->login->username), std::move(rpc_config->login->password).password()
			);
		}
		assert(bool(http_login));

		std::string temp = "lethean-wallet-vpn-rpc." + bind_port + ".login";
		const auto cookie = tools::create_private_file(temp);
		if (!cookie)
		{
			LOG_ERROR(tr("Failed to create file ") << temp << tr(". Check permissions or remove file"));
			return false;
		}
		rpc_login_filename.swap(temp); // nothrow guarantee destructor cleanup
		temp = rpc_login_filename;
		std::fputs(http_login->username.c_str(), cookie.get());
		std::fputc(':', cookie.get());
		std::fputs(http_login->password.c_str(), cookie.get());
		std::fflush(cookie.get());
		if (std::ferror(cookie.get()))
		{
			LOG_ERROR(tr("Error writing to file ") << temp);
			return false;
		}
		LOG_PRINT_L0(tr("RPC username/password is stored in file ") << temp);

		m_http_client.set_server(walvars->get_daemon_address(), walvars->get_daemon_login());

		m_net_server.set_threads_prefix("RPC");
		return epee::http_server_impl_base<wallet_vpn_rpc_server, connection_context>::init(
			std::move(bind_port), std::move(rpc_config->bind_ip), std::move(http_login)
		);
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::not_open(epee::json_rpc::error& er)
	{
		er.code = WALLET_RPC_ERROR_CODE_NOT_OPEN;
		er.message = "No wallet file";
		return false;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	uint64_t wallet_vpn_rpc_server::adjust_mixin(uint64_t mixin)
	{
		if (mixin < 3 && m_wallet->use_fork_rules(4, 10)) {
			MWARNING("Requested ring size " << (mixin + 1) << " too low for hard fork 6, using 4");
			mixin = 3;
		}
		return mixin;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	void wallet_vpn_rpc_server::fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &txid, const crypto::hash &payment_id, const tools::wallet2::payment_details &pd)
	{
		entry.txid = string_tools::pod_to_hex(pd.m_tx_hash);
		entry.payment_id = string_tools::pod_to_hex(payment_id);
		if (entry.payment_id.substr(16).find_first_not_of('0') == std::string::npos)
			entry.payment_id = entry.payment_id.substr(0, 16);
		entry.height = pd.m_block_height;
		entry.timestamp = pd.m_timestamp;
		entry.amount = pd.m_amount;
		entry.unlock_time = pd.m_unlock_time;
		entry.fee = 0; // TODO
		entry.note = m_wallet->get_tx_note(pd.m_tx_hash);
		entry.type = "in";
	}
	//------------------------------------------------------------------------------------------------------------------------------
	void wallet_vpn_rpc_server::fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &txid, const tools::wallet2::confirmed_transfer_details &pd)
	{		
		entry.txid = string_tools::pod_to_hex(txid);
		entry.payment_id = string_tools::pod_to_hex(pd.m_payment_id);
		if (entry.payment_id.substr(16).find_first_not_of('0') == std::string::npos)
			entry.payment_id = entry.payment_id.substr(0, 16);
		entry.height = pd.m_block_height;
		entry.timestamp = pd.m_timestamp;
		entry.unlock_time = pd.m_unlock_time;
		entry.fee = pd.m_amount_in - pd.m_amount_out;
		uint64_t change = pd.m_change == (uint64_t)-1 ? 0 : pd.m_change; // change may not be known
		entry.amount = pd.m_amount_in - change - entry.fee;
		entry.note = m_wallet->get_tx_note(txid);

		for (const auto &d : pd.m_dests) {
			entry.destinations.push_back(wallet_rpc::transfer_destination());
			wallet_rpc::transfer_destination &td = entry.destinations.back();
			td.amount = d.amount;
			td.address = get_account_address_as_str(m_wallet->testnet(), d.addr);
		}

		entry.type = "out";
	}
	//------------------------------------------------------------------------------------------------------------------------------
	void wallet_vpn_rpc_server::fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &txid, const tools::wallet2::unconfirmed_transfer_details &pd)
	{
		bool is_failed = pd.m_state == tools::wallet2::unconfirmed_transfer_details::failed;
		entry.txid = string_tools::pod_to_hex(txid);
		entry.payment_id = string_tools::pod_to_hex(pd.m_payment_id);
		entry.payment_id = string_tools::pod_to_hex(pd.m_payment_id);
		if (entry.payment_id.substr(16).find_first_not_of('0') == std::string::npos)
			entry.payment_id = entry.payment_id.substr(0, 16);
		entry.height = 0;
		entry.timestamp = pd.m_timestamp;
		entry.fee = pd.m_amount_in - pd.m_amount_out;
		entry.amount = pd.m_amount_in - pd.m_change - entry.fee;
		entry.unlock_time = pd.m_tx.unlock_time;
		entry.note = m_wallet->get_tx_note(txid);
		entry.type = is_failed ? "failed" : "pending";
	}
	//------------------------------------------------------------------------------------------------------------------------------
	void wallet_vpn_rpc_server::fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &payment_id, const tools::wallet2::payment_details &pd)
	{
		entry.txid = string_tools::pod_to_hex(pd.m_tx_hash);
		entry.payment_id = string_tools::pod_to_hex(payment_id);
		if (entry.payment_id.substr(16).find_first_not_of('0') == std::string::npos)
			entry.payment_id = entry.payment_id.substr(0, 16);
		entry.height = 0;
		entry.timestamp = pd.m_timestamp;
		entry.amount = pd.m_amount;
		entry.unlock_time = pd.m_unlock_time;
		entry.fee = 0; // TODO
		entry.note = m_wallet->get_tx_note(pd.m_tx_hash);
		entry.type = "pool";
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_getbalance(const wallet_rpc::COMMAND_RPC_GET_BALANCE::request& req, wallet_rpc::COMMAND_RPC_GET_BALANCE::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		try
		{
			res.balance = m_wallet->balance();
			res.unlocked_balance = m_wallet->unlocked_balance();
		}
		catch (const std::exception& e)
		{
			er.code = WALLET_RPC_ERROR_CODE_UNKNOWN_ERROR;
			er.message = e.what();
			return false;
		}
		return true;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_getaddress(const wallet_rpc::COMMAND_RPC_GET_ADDRESS::request& req, wallet_rpc::COMMAND_RPC_GET_ADDRESS::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		try
		{
			res.address = m_wallet->get_account().get_public_address_str(m_wallet->testnet());
		}
		catch (const std::exception& e)
		{
			er.code = WALLET_RPC_ERROR_CODE_UNKNOWN_ERROR;
			er.message = e.what();
			return false;
		}
		return true;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_getheight(const wallet_rpc::COMMAND_RPC_GET_HEIGHT::request& req, wallet_rpc::COMMAND_RPC_GET_HEIGHT::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		try
		{
			res.height = m_wallet->get_blockchain_current_height();
		}
		catch (const std::exception& e)
		{
			er.code = WALLET_RPC_ERROR_CODE_UNKNOWN_ERROR;
			er.message = e.what();
			return false;
		}
		return true;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_make_integrated_address(const wallet_rpc::COMMAND_RPC_MAKE_INTEGRATED_ADDRESS::request& req, wallet_rpc::COMMAND_RPC_MAKE_INTEGRATED_ADDRESS::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		try
		{
			crypto::hash8 payment_id;
			if (req.payment_id.empty())
			{
				payment_id = crypto::rand<crypto::hash8>();
			}
			else
			{
				if (!tools::wallet2::parse_short_payment_id(req.payment_id, payment_id))
				{
					er.code = WALLET_RPC_ERROR_CODE_WRONG_PAYMENT_ID;
					er.message = "Invalid payment ID";
					return false;
				}
			}

			res.integrated_address = m_wallet->get_account().get_public_integrated_address_str(payment_id, m_wallet->testnet());
			res.payment_id = epee::string_tools::pod_to_hex(payment_id);
			return true;
		}
		catch (const std::exception &e)
		{
			er.code = WALLET_RPC_ERROR_CODE_UNKNOWN_ERROR;
			er.message = e.what();
			return false;
		}
		return true;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_split_integrated_address(const wallet_rpc::COMMAND_RPC_SPLIT_INTEGRATED_ADDRESS::request& req, wallet_rpc::COMMAND_RPC_SPLIT_INTEGRATED_ADDRESS::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		try
		{
			cryptonote::account_public_address address;
			crypto::hash8 payment_id;
			bool has_payment_id;

			if (!get_account_integrated_address_from_str(address, has_payment_id, payment_id, m_wallet->testnet(), req.integrated_address))
			{
				er.code = WALLET_RPC_ERROR_CODE_WRONG_ADDRESS;
				er.message = "Invalid address";
				return false;
			}
			if (!has_payment_id)
			{
				er.code = WALLET_RPC_ERROR_CODE_WRONG_ADDRESS;
				er.message = "Address is not an integrated address";
				return false;
			}
			res.standard_address = get_account_address_as_str(m_wallet->testnet(), address);
			res.payment_id = epee::string_tools::pod_to_hex(payment_id);
			return true;
		}
		catch (const std::exception &e)
		{
			er.code = WALLET_RPC_ERROR_CODE_UNKNOWN_ERROR;
			er.message = e.what();
			return false;
		}
		return true;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_incoming_transfers(const wallet_rpc::COMMAND_RPC_INCOMING_TRANSFERS::request& req, wallet_rpc::COMMAND_RPC_INCOMING_TRANSFERS::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		if (req.transfer_type.compare("all") != 0 && req.transfer_type.compare("available") != 0 && req.transfer_type.compare("unavailable") != 0)
		{
			er.code = WALLET_RPC_ERROR_CODE_TRANSFER_TYPE;
			er.message = "Transfer type must be one of: all, available, or unavailable";
			return false;
		}

		bool filter = false;
		bool available = false;
		if (req.transfer_type.compare("available") == 0)
		{
			filter = true;
			available = true;
		}
		else if (req.transfer_type.compare("unavailable") == 0)
		{
			filter = true;
			available = false;
		}

		wallet2::transfer_container transfers;
		m_wallet->get_transfers(transfers);

		bool transfers_found = false;
		for (const auto& td : transfers)
		{
			if (!filter || available != td.m_spent)
			{
				if (!transfers_found)
				{
					transfers_found = true;
				}
				auto txBlob = t_serializable_object_to_blob(td.m_tx);
				wallet_rpc::transfer_details rpc_transfers;
				rpc_transfers.amount = td.amount();
				rpc_transfers.spent = td.m_spent;
				rpc_transfers.global_index = td.m_global_output_index;
				rpc_transfers.tx_hash = epee::string_tools::pod_to_hex(td.m_txid);
				rpc_transfers.tx_size = txBlob.size();
				res.transfers.push_back(rpc_transfers);
			}
		}

		return true;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::is_vpn_transaction(const crypto::hash &payment_id) {		
		std::string payment_id_hex = string_tools::pod_to_hex(payment_id);
		if (payment_id_hex.length() > 16)
			payment_id_hex = payment_id_hex.substr(0, 16);
		crypto::hash8 payment_id8;
		bool is_short_payment_id = wallet2::parse_short_payment_id(payment_id_hex, payment_id8);
		return (is_short_payment_id && payment_id_hex.compare("0000000000000000") != 0);
	}	
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_get_transfers(const wallet_rpc::COMMAND_RPC_GET_TRANSFERS::request& req, wallet_rpc::COMMAND_RPC_GET_TRANSFERS::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		if (m_wallet->restricted())
		{
			er.code = WALLET_RPC_ERROR_CODE_DENIED;
			er.message = "Command unavailable in restricted mode.";
			return false;
		}

		uint64_t min_height = 0, max_height = (uint64_t)-1;
		if (req.filter_by_height)
		{
			min_height = req.min_height;
			max_height = req.max_height;
		}

		if (req.in)
		{
			std::list<std::pair<crypto::hash, tools::wallet2::payment_details>> payments;
			m_wallet->get_payments(payments, min_height, max_height);
			for (std::list<std::pair<crypto::hash, tools::wallet2::payment_details>>::const_iterator i = payments.begin(); i != payments.end(); ++i) {
				//ignore entires that do not contain 16-char encrypted payment ID
				if (!is_vpn_transaction(i->first))
					continue;
				res.in.push_back(wallet_rpc::transfer_entry());			
				fill_transfer_entry(res.in.back(), i->second.m_tx_hash, i->first, i->second);
			}
		}

		if (req.out)
		{
			std::list<std::pair<crypto::hash, tools::wallet2::confirmed_transfer_details>> payments;
			m_wallet->get_payments_out(payments, min_height, max_height);
			for (std::list<std::pair<crypto::hash, tools::wallet2::confirmed_transfer_details>>::const_iterator i = payments.begin(); i != payments.end(); ++i) {
				//ignore entires that do not contain 16-char encrypted payment ID
				if (!is_vpn_transaction(i->second.m_payment_id))
					continue;
				res.out.push_back(wallet_rpc::transfer_entry());				
				fill_transfer_entry(res.out.back(), i->first, i->second);
			}
		}

		if (req.pending || req.failed) {
			std::list<std::pair<crypto::hash, tools::wallet2::unconfirmed_transfer_details>> upayments;
			m_wallet->get_unconfirmed_payments_out(upayments);
			for (std::list<std::pair<crypto::hash, tools::wallet2::unconfirmed_transfer_details>>::const_iterator i = upayments.begin(); i != upayments.end(); ++i) {
				const tools::wallet2::unconfirmed_transfer_details &pd = i->second;
				bool is_failed = pd.m_state == tools::wallet2::unconfirmed_transfer_details::failed;
				if (!((req.failed && is_failed) || (!is_failed && req.pending)))
					continue;
				//ignore entires that do not contain 16-char encrypted payment ID
				if (!is_vpn_transaction(i->second.m_payment_id))
					continue;
				std::list<wallet_rpc::transfer_entry> &entries = is_failed ? res.failed : res.pending;
				entries.push_back(wallet_rpc::transfer_entry());
				fill_transfer_entry(entries.back(), i->first, i->second);
			}
		}

		if (req.pool)
		{
			m_wallet->update_pool_state();

			std::list<std::pair<crypto::hash, tools::wallet2::payment_details>> payments;
			m_wallet->get_unconfirmed_payments(payments);
			for (std::list<std::pair<crypto::hash, tools::wallet2::payment_details>>::const_iterator i = payments.begin(); i != payments.end(); ++i) {
				//ignore entires that do not contain 16-char encrypted payment ID
				if (!is_vpn_transaction(i->first))
					continue;
				res.pool.push_back(wallet_rpc::transfer_entry());
				fill_transfer_entry(res.pool.back(), i->first, i->second);
			}
		}

		return true;
	}
	//------------------------------------------------------------------------------------------------------------------------------
	bool wallet_vpn_rpc_server::on_get_transfer_by_txid(const wallet_rpc::COMMAND_RPC_GET_TRANSFER_BY_TXID::request& req, wallet_rpc::COMMAND_RPC_GET_TRANSFER_BY_TXID::response& res, epee::json_rpc::error& er)
	{
		if (!m_wallet) return not_open(er);
		if (m_wallet->restricted())
		{
			er.code = WALLET_RPC_ERROR_CODE_DENIED;
			er.message = "Command unavailable in restricted mode.";
			return false;
		}

		crypto::hash txid;
		cryptonote::blobdata txid_blob;
		if (!epee::string_tools::parse_hexstr_to_binbuff(req.txid, txid_blob))
		{
			er.code = WALLET_RPC_ERROR_CODE_WRONG_TXID;
			er.message = "Transaction ID has invalid format";
			return false;
		}

		if (sizeof(txid) == txid_blob.size())
		{
			txid = *reinterpret_cast<const crypto::hash*>(txid_blob.data());
		}
		else
		{
			er.code = WALLET_RPC_ERROR_CODE_WRONG_TXID;
			er.message = "Transaction ID has invalid size: " + req.txid;
			return false;
		}

		std::list<std::pair<crypto::hash, tools::wallet2::payment_details>> payments;
		m_wallet->get_payments(payments, 0);
		for (std::list<std::pair<crypto::hash, tools::wallet2::payment_details>>::const_iterator i = payments.begin(); i != payments.end(); ++i) {
			if (i->second.m_tx_hash == txid)
			{
				fill_transfer_entry(res.transfer, i->second.m_tx_hash, i->first, i->second);
				return true;
			}
		}

		std::list<std::pair<crypto::hash, tools::wallet2::confirmed_transfer_details>> payments_out;
		m_wallet->get_payments_out(payments_out, 0);
		for (std::list<std::pair<crypto::hash, tools::wallet2::confirmed_transfer_details>>::const_iterator i = payments_out.begin(); i != payments_out.end(); ++i) {
			if (i->first == txid)
			{
				fill_transfer_entry(res.transfer, i->first, i->second);
				return true;
			}
		}

		std::list<std::pair<crypto::hash, tools::wallet2::unconfirmed_transfer_details>> upayments;
		m_wallet->get_unconfirmed_payments_out(upayments);
		for (std::list<std::pair<crypto::hash, tools::wallet2::unconfirmed_transfer_details>>::const_iterator i = upayments.begin(); i != upayments.end(); ++i) {
			if (i->first == txid)
			{
				fill_transfer_entry(res.transfer, i->first, i->second);
				return true;
			}
		}

		m_wallet->update_pool_state();

		std::list<std::pair<crypto::hash, tools::wallet2::payment_details>> pool_payments;
		m_wallet->get_unconfirmed_payments(pool_payments);
		for (std::list<std::pair<crypto::hash, tools::wallet2::payment_details>>::const_iterator i = pool_payments.begin(); i != pool_payments.end(); ++i) {
			if (i->second.m_tx_hash == txid)
			{
				fill_transfer_entry(res.transfer, i->first, i->second);
				return true;
			}
		}

		er.code = WALLET_RPC_ERROR_CODE_WRONG_TXID;
		er.message = "Transaction not found.";
		return false;
	}
	//------------------------------------------------------------------------------------------------------------------------------
}

int main(int argc, char** argv) {
	namespace po = boost::program_options;

	const auto arg_wallet_file = wallet_args::arg_wallet_file();
	const auto arg_from_json = wallet_args::arg_generate_from_json();

	po::options_description desc_params(wallet_args::tr("Wallet options"));
	tools::wallet2::init_options(desc_params);
	command_line::add_arg(desc_params, arg_rpc_bind_port);
	command_line::add_arg(desc_params, arg_trusted_daemon);
	cryptonote::rpc_args::init_options(desc_params);
	command_line::add_arg(desc_params, arg_wallet_file);
	command_line::add_arg(desc_params, arg_from_json);

	const auto vm = wallet_args::main(
		argc, argv,
		"lethean-wallet-vpn-rpc [--wallet-file=<file>|--generate-from-json=<file>] [--vpn-rpc-bind-port=<port>]",
		desc_params,
		po::positional_options_description(),
		"lethean-wallet-vpn-rpc.log",
		true
	);
	if (!vm)
	{
		return 1;
	}

	std::unique_ptr<tools::wallet2> wal;
	try
	{
		const auto wallet_file = command_line::get_arg(*vm, arg_wallet_file);
		const auto from_json = command_line::get_arg(*vm, arg_from_json);

		if (!wallet_file.empty() && !from_json.empty())
		{
			LOG_ERROR(tools::wallet_vpn_rpc_server::tr("Can't specify more than one of --wallet-file and --generate-from-json"));
			return 1;
		}

		if (wallet_file.empty() && from_json.empty())
		{
			LOG_ERROR(tools::wallet_vpn_rpc_server::tr("Must specify --wallet-file or --generate-from-json or --wallet-dir"));
			return 1;
		}

		LOG_PRINT_L0(tools::wallet_vpn_rpc_server::tr("Loading wallet..."));
		if (!wallet_file.empty())
		{
			wal = tools::wallet2::make_from_file(*vm, wallet_file).first;
		}
		else
		{
			wal = tools::wallet2::make_from_json(*vm, from_json);
		}
		if (!wal)
		{
			return 1;
		}

		bool quit = false;
		tools::signal_handler::install([&wal, &quit](int) {
			assert(wal);
			quit = true;
			wal->stop();
		});

		wal->refresh();
		// if we ^C during potentially length load/refresh, there's no server loop yet
		if (quit)
		{
			MINFO(tools::wallet_vpn_rpc_server::tr("Storing wallet..."));
			wal->store();
			MINFO(tools::wallet_vpn_rpc_server::tr("Stored ok"));
			return 1;
		}
		MINFO(tools::wallet_vpn_rpc_server::tr("Loaded ok"));
	}
	catch (const std::exception& e)
	{
		LOG_ERROR(tools::wallet_vpn_rpc_server::tr("Wallet initialization failed: ") << e.what());
		return 1;
	}

	tools::wallet_vpn_rpc_server wrpc;
	if (wal) wrpc.set_wallet(wal.release());
	bool r = wrpc.init(&(vm.get()));
	CHECK_AND_ASSERT_MES(r, 1, tools::wallet_vpn_rpc_server::tr("Failed to initialize wallet rpc server"));
	tools::signal_handler::install([&wrpc, &wal](int) {
		wrpc.send_stop_signal();
	});
	LOG_PRINT_L0(tools::wallet_vpn_rpc_server::tr("Starting wallet rpc server"));
	wrpc.run();
	LOG_PRINT_L0(tools::wallet_vpn_rpc_server::tr("Stopped wallet rpc server"));
	try
	{
		LOG_PRINT_L0(tools::wallet_vpn_rpc_server::tr("Storing wallet..."));
		wrpc.stop();
		LOG_PRINT_L0(tools::wallet_vpn_rpc_server::tr("Stored ok"));
	}
	catch (const std::exception& e)
	{
		LOG_ERROR(tools::wallet_vpn_rpc_server::tr("Failed to store wallet: ") << e.what());
		return 1;
	}
	return 0;
}

