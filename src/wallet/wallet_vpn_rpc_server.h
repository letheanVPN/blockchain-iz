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

#pragma  once

#include <boost/program_options/options_description.hpp>
#include <boost/program_options/variables_map.hpp>
#include <string>
#include "net/http_server_impl_base.h"
#include "wallet_rpc_server_commands_defs.h"
#include "wallet2.h"

#undef MONERO_DEFAULT_LOG_CATEGORY
#define MONERO_DEFAULT_LOG_CATEGORY "wallet.vpn.rpc"

namespace tools
{
  /************************************************************************/
  /*                                                                      */
  /************************************************************************/
  class wallet_vpn_rpc_server: public epee::http_server_impl_base<wallet_vpn_rpc_server>
  {
  public:
    typedef epee::net_utils::connection_context_base connection_context;

    static const char* tr(const char* str);

    wallet_vpn_rpc_server();
    ~wallet_vpn_rpc_server();

    bool init(const boost::program_options::variables_map *vm);
    bool run();
    void stop();
    void set_wallet(wallet2 *cr);

  private:

    CHAIN_HTTP_TO_MAP2(connection_context); //forward http requests to uri map

    BEGIN_URI_MAP2()
      BEGIN_JSON_RPC_MAP("/json_rpc")
        MAP_JON_RPC_WE("getbalance",         on_getbalance,         wallet_rpc::COMMAND_RPC_GET_BALANCE)
        MAP_JON_RPC_WE("getaddress",         on_getaddress,         wallet_rpc::COMMAND_RPC_GET_ADDRESS)
        MAP_JON_RPC_WE("getheight",          on_getheight,          wallet_rpc::COMMAND_RPC_GET_HEIGHT)
        MAP_JON_RPC_WE("incoming_transfers", on_incoming_transfers, wallet_rpc::COMMAND_RPC_INCOMING_TRANSFERS)
        MAP_JON_RPC_WE("make_integrated_address", on_make_integrated_address, wallet_rpc::COMMAND_RPC_MAKE_INTEGRATED_ADDRESS)
        MAP_JON_RPC_WE("split_integrated_address", on_split_integrated_address, wallet_rpc::COMMAND_RPC_SPLIT_INTEGRATED_ADDRESS)
        MAP_JON_RPC_WE("get_vpn_transfers",      on_get_transfers,      wallet_rpc::COMMAND_RPC_GET_TRANSFERS)
        MAP_JON_RPC_WE("get_transfer_by_txid", on_get_transfer_by_txid, wallet_rpc::COMMAND_RPC_GET_TRANSFER_BY_TXID)
      END_JSON_RPC_MAP()
    END_URI_MAP2()

      //json_rpc
      bool on_getbalance(const wallet_rpc::COMMAND_RPC_GET_BALANCE::request& req, wallet_rpc::COMMAND_RPC_GET_BALANCE::response& res, epee::json_rpc::error& er);
      bool on_getaddress(const wallet_rpc::COMMAND_RPC_GET_ADDRESS::request& req, wallet_rpc::COMMAND_RPC_GET_ADDRESS::response& res, epee::json_rpc::error& er);
      bool on_getheight(const wallet_rpc::COMMAND_RPC_GET_HEIGHT::request& req, wallet_rpc::COMMAND_RPC_GET_HEIGHT::response& res, epee::json_rpc::error& er);
	  bool on_make_integrated_address(const wallet_rpc::COMMAND_RPC_MAKE_INTEGRATED_ADDRESS::request& req, wallet_rpc::COMMAND_RPC_MAKE_INTEGRATED_ADDRESS::response& res, epee::json_rpc::error& er);
      bool on_split_integrated_address(const wallet_rpc::COMMAND_RPC_SPLIT_INTEGRATED_ADDRESS::request& req, wallet_rpc::COMMAND_RPC_SPLIT_INTEGRATED_ADDRESS::response& res, epee::json_rpc::error& er);
      bool on_incoming_transfers(const wallet_rpc::COMMAND_RPC_INCOMING_TRANSFERS::request& req, wallet_rpc::COMMAND_RPC_INCOMING_TRANSFERS::response& res, epee::json_rpc::error& er);
	  bool is_vpn_transaction(const crypto::hash& payment_id);
      bool on_get_transfers(const wallet_rpc::COMMAND_RPC_GET_TRANSFERS::request& req, wallet_rpc::COMMAND_RPC_GET_TRANSFERS::response& res, epee::json_rpc::error& er);
      bool on_get_transfer_by_txid(const wallet_rpc::COMMAND_RPC_GET_TRANSFER_BY_TXID::request& req, wallet_rpc::COMMAND_RPC_GET_TRANSFER_BY_TXID::response& res, epee::json_rpc::error& er);

      // helpers
      void fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &txid, const crypto::hash &payment_id, const tools::wallet2::payment_details &pd);
      void fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &txid, const tools::wallet2::confirmed_transfer_details &pd);
      void fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &txid, const tools::wallet2::unconfirmed_transfer_details &pd);
      void fill_transfer_entry(tools::wallet_rpc::transfer_entry &entry, const crypto::hash &payment_id, const tools::wallet2::payment_details &pd);
      bool not_open(epee::json_rpc::error& er);
      uint64_t adjust_mixin(uint64_t mixin);

      wallet2 *m_wallet;
      std::string rpc_login_filename;
      std::atomic<bool> m_stop;
      bool m_trusted_daemon;
      epee::net_utils::http::http_simple_client m_http_client;
      const boost::program_options::variables_map *m_vm;
  };
}
