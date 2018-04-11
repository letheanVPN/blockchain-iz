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

#pragma once

#include <boost/variant.hpp>
#include <boost/functional/hash/hash.hpp>
#include <vector>
#include <cstring>  // memcmp
#include <sstream>
#include <atomic>
#include "serialization/serialization.h"
#include "serialization/variant.h"
#include "serialization/vector.h"
#include "serialization/binary_archive.h"
#include "serialization/json_archive.h"
#include "serialization/debug_archive.h"
#include "serialization/crypto.h"
#include "serialization/keyvalue_serialization.h" // eepe named serialization
#include "cryptonote_config.h"
#include "crypto/crypto.h"
#include "crypto/hash.h"
#include "misc_language.h"
#include "tx_extra.h"
#include "ringct/rctTypes.h"

namespace cryptonote
{
  struct block;
  class transaction;
  struct tx_extra_merge_mining_tag;
  // Implemented in cryptonote_format_utils.cpp
  bool get_transaction_hash(const transaction& t, crypto::hash& res);
  bool get_mm_tag_from_extra(const std::vector<uint8_t>& tx, tx_extra_merge_mining_tag& mm_tag);

  const static crypto::hash null_hash = AUTO_VAL_INIT(null_hash);
  const static crypto::hash8 null_hash8 = AUTO_VAL_INIT(null_hash8);
  const static crypto::public_key null_pkey = AUTO_VAL_INIT(null_pkey);

  typedef std::vector<crypto::signature> ring_signature;


  /* outputs */

  struct txout_to_script
  {
    std::vector<crypto::public_key> keys;
    std::vector<uint8_t> script;

    BEGIN_SERIALIZE_OBJECT()
      FIELD(keys)
      FIELD(script)
    END_SERIALIZE()
  };

  struct txout_to_scripthash
  {
    crypto::hash hash;
  };

  struct txout_to_key
  {
    txout_to_key() { }
    txout_to_key(const crypto::public_key &_key) : key(_key) { }
    crypto::public_key key;
  };


  /* inputs */

  struct txin_gen
  {
    size_t height;

    BEGIN_SERIALIZE_OBJECT()
      VARINT_FIELD(height)
    END_SERIALIZE()
  };

  struct txin_to_script
  {
    crypto::hash prev;
    size_t prevout;
    std::vector<uint8_t> sigset;

    BEGIN_SERIALIZE_OBJECT()
      FIELD(prev)
      VARINT_FIELD(prevout)
      FIELD(sigset)
    END_SERIALIZE()
  };

  struct txin_to_scripthash
  {
    crypto::hash prev;
    size_t prevout;
    txout_to_script script;
    std::vector<uint8_t> sigset;

    BEGIN_SERIALIZE_OBJECT()
      FIELD(prev)
      VARINT_FIELD(prevout)
      FIELD(script)
      FIELD(sigset)
    END_SERIALIZE()
  };

  struct txin_to_key
  {
    uint64_t amount;
    std::vector<uint64_t> key_offsets;
    crypto::key_image k_image;      // double spending protection

    BEGIN_SERIALIZE_OBJECT()
      VARINT_FIELD(amount)
      FIELD(key_offsets)
      FIELD(k_image)
    END_SERIALIZE()
  };


  typedef boost::variant<txin_gen, txin_to_script, txin_to_scripthash, txin_to_key> txin_v;

  typedef boost::variant<txout_to_script, txout_to_scripthash, txout_to_key> txout_target_v;

  //typedef std::pair<uint64_t, txout> out_t;
  struct tx_out
  {
    uint64_t amount;
    txout_target_v target;

    BEGIN_SERIALIZE_OBJECT()
      VARINT_FIELD(amount)
      FIELD(target)
    END_SERIALIZE()


  };

  class transaction_prefix
  {

  public:
    // tx information
    size_t   version;
    uint64_t unlock_time;  //number of block (or time), used as a limitation like: spend this tx not early then block/time
	bool is_mm_tx;

    std::vector<txin_v> vin;
    std::vector<tx_out> vout;
    //extra
    std::vector<uint8_t> extra;

    BEGIN_SERIALIZE()
      VARINT_FIELD(version)
      if((version == 0 || CURRENT_TRANSACTION_VERSION < version) && !is_mm_tx) return false;
      VARINT_FIELD(unlock_time)
      FIELD(vin)
      FIELD(vout)
      FIELD(extra)
    END_SERIALIZE()

  public:
    transaction_prefix(){}
  };

  class transaction: public transaction_prefix
  {
  private:
    // hash cash
    mutable std::atomic<bool> hash_valid;
    mutable std::atomic<bool> blob_size_valid;

  public:
    std::vector<std::vector<crypto::signature> > signatures; //count signatures  always the same as inputs count
    rct::rctSig rct_signatures;

    // hash cash
    mutable crypto::hash hash;
    mutable size_t blob_size;

    transaction();
    transaction(const transaction &t): transaction_prefix(t), hash_valid(false), blob_size_valid(false), signatures(t.signatures), rct_signatures(t.rct_signatures) { if (t.is_hash_valid()) { hash = t.hash; set_hash_valid(true); } if (t.is_blob_size_valid()) { blob_size = t.blob_size; set_blob_size_valid(true); } }
    transaction &operator=(const transaction &t) { transaction_prefix::operator=(t); set_hash_valid(false); set_blob_size_valid(false); signatures = t.signatures; rct_signatures = t.rct_signatures; if (t.is_hash_valid()) { hash = t.hash; set_hash_valid(true); } if (t.is_blob_size_valid()) { blob_size = t.blob_size; set_blob_size_valid(true); } return *this; }
    virtual ~transaction();
    void set_null();
    void invalidate_hashes();
    bool is_hash_valid() const { return hash_valid.load(std::memory_order_acquire); }
    void set_hash_valid(bool v) const { hash_valid.store(v,std::memory_order_release); }
    bool is_blob_size_valid() const { return blob_size_valid.load(std::memory_order_acquire); }
    void set_blob_size_valid(bool v) const { blob_size_valid.store(v,std::memory_order_release); }

    BEGIN_SERIALIZE_OBJECT()
      if (!typename Archive<W>::is_saving())
      {
        set_hash_valid(false);
        set_blob_size_valid(false);
      }

      FIELDS(*static_cast<transaction_prefix *>(this))

      if (version <= 1)
      {
        ar.tag("signatures");
        ar.begin_array();
        PREPARE_CUSTOM_VECTOR_SERIALIZATION(vin.size(), signatures);
        bool signatures_not_expected = signatures.empty();
		if (!signatures_not_expected && vin.size() != signatures.size()) {
			MERROR("Failed TX sig check");
			return false;
		}

        for (size_t i = 0; i < vin.size(); ++i)
        {
          size_t signature_size = get_signature_size(vin[i]);
          if (signatures_not_expected)
          {
            if (0 == signature_size)
              continue;
            else
              return false;
          }

          PREPARE_CUSTOM_VECTOR_SERIALIZATION(signature_size, signatures[i]);
		  if (signature_size != signatures[i].size()) {
			  MERROR("Failed TX size check");
			  return false;
		  }

          FIELDS(signatures[i]);

          if (vin.size() - i > 1)
            ar.delimit_array();
        }
        ar.end_array();
      }
      else
      {
        ar.tag("rct_signatures");
        if (!vin.empty())
        {
          ar.begin_object();
          bool r = rct_signatures.serialize_rctsig_base(ar, vin.size(), vout.size());
          if (!r || !ar.stream().good()) return false;
          ar.end_object();
          if (rct_signatures.type != rct::RCTTypeNull)
          {
            ar.tag("rctsig_prunable");
            ar.begin_object();
            r = rct_signatures.p.serialize_rctsig_prunable(ar, rct_signatures.type, vin.size(), vout.size(),
                vin[0].type() == typeid(txin_to_key) ? boost::get<txin_to_key>(vin[0]).key_offsets.size() - 1 : 0);
            if (!r || !ar.stream().good()) return false;
            ar.end_object();
          }
        }
      }
    END_SERIALIZE()

    template<bool W, template <bool> class Archive>
    bool serialize_base(Archive<W> &ar)
    {
      FIELDS(*static_cast<transaction_prefix *>(this))

      if (version <= 1)
      {
      }
      else
      {
		  MWARNING("Processing RCT tx ..");
        ar.tag("rct_signatures");
        if (!vin.empty())
        {
          ar.begin_object();
          bool r = rct_signatures.serialize_rctsig_base(ar, vin.size(), vout.size());
          if (!r || !ar.stream().good()) return false;
          ar.end_object();
        }
      }
      return true;
    }

  private:
    static size_t get_signature_size(const txin_v& tx_in);
  };


  inline
  transaction::transaction()
  {
    set_null();
  }

  inline
  transaction::~transaction()
  {
    //set_null();
  }

  inline
  void transaction::set_null()
  {
    version = 1;
    unlock_time = 0;
	is_mm_tx = false;
    vin.clear();
    vout.clear();
    extra.clear();
    signatures.clear();
    rct_signatures.type = rct::RCTTypeNull;
    set_hash_valid(false);
    set_blob_size_valid(false);
  }

  inline
  void transaction::invalidate_hashes()
  {
    set_hash_valid(false);
    set_blob_size_valid(false);
  }

  inline
  size_t transaction::get_signature_size(const txin_v& tx_in)
  {
    struct txin_signature_size_visitor : public boost::static_visitor<size_t>
    {
      size_t operator()(const txin_gen& txin) const{return 0;}
      size_t operator()(const txin_to_script& txin) const{return 0;}
      size_t operator()(const txin_to_scripthash& txin) const{return 0;}
      size_t operator()(const txin_to_key& txin) const {return txin.key_offsets.size();}
    };

    return boost::apply_visitor(txin_signature_size_visitor(), tx_in);
  }



  /************************************************************************/
  /*                                                                      */
  /************************************************************************/

  struct bytecoin_block
  {
	  uint8_t major_version;
	  uint8_t minor_version;
	  crypto::hash prev_id;
	  uint32_t nonce;
	  size_t number_of_transactions;
	  std::vector<crypto::hash> miner_tx_branch;
	  transaction miner_tx;
	  std::vector<crypto::hash> blockchain_branch;
  };

  struct serializable_bytecoin_block
  {
	  bytecoin_block& b;
	  uint64_t& timestamp;
	  bool hashing_serialization;
	  bool header_only;

	  serializable_bytecoin_block(bytecoin_block& b_, uint64_t& timestamp_, bool hashing_serialization_, bool header_only_) :
		  b(b_), timestamp(timestamp_), hashing_serialization(hashing_serialization_), header_only(header_only_)
	  {
		  b.miner_tx.is_mm_tx = true;
	  }

	  BEGIN_SERIALIZE_OBJECT()
	  VARINT_FIELD_N("major_version", b.major_version);
	  VARINT_FIELD_N("minor_version", b.minor_version);
	  VARINT_FIELD(timestamp);
	  FIELD_N("prev_id", b.prev_id);
	  FIELD_N("nonce", b.nonce);

	  if (hashing_serialization)
	  {
		  crypto::hash miner_tx_hash;
		  if (!get_transaction_hash(b.miner_tx, miner_tx_hash)) {
			  MERROR("Failed to get transaction hash for miner tx");
			  return false;
		  }
		  crypto::hash merkle_root;
		  crypto::tree_hash_from_branch(b.miner_tx_branch.data(), b.miner_tx_branch.size(), miner_tx_hash, 0, merkle_root);

		  FIELD(merkle_root);
	  }
	  VARINT_FIELD_N("number_of_transactions", b.number_of_transactions);
	  if (b.number_of_transactions < 1) {
		  MERROR("Num tx < 1?");
		  return false;
	  }

	  if (!header_only)
	  {
		  ar.tag("miner_tx_branch");
		  ar.begin_array();
		  size_t branch_size = crypto::tree_depth(b.number_of_transactions);
		  PREPARE_CUSTOM_VECTOR_SERIALIZATION(branch_size, const_cast<bytecoin_block&>(b).miner_tx_branch);
		  if (b.miner_tx_branch.size() != branch_size) {
			  MERROR("Miner tx branch size != branch size");
			  return false;
		  }
		  for (size_t i = 0; i < branch_size; ++i)
		  {
			  FIELDS(b.miner_tx_branch[i]);
			  if (i + 1 < branch_size)
				  ar.delimit_array();
		  }
		  ar.end_array();

		  FIELD(b.miner_tx);

		  tx_extra_merge_mining_tag mm_tag;
		  if (!get_mm_tag_from_extra(b.miner_tx.extra, mm_tag)) {
			  MERROR("Failed to get mm tag from extra.");
			  return false;
		  }

		  ar.tag("blockchain_branch");
		  ar.begin_array();
		  PREPARE_CUSTOM_VECTOR_SERIALIZATION(mm_tag.depth, const_cast<bytecoin_block&>(b).blockchain_branch);
		  if (mm_tag.depth != b.blockchain_branch.size()) {
			  MERROR("Mm tag depth != blockchian_branch size");
			  return false;
		  }
		  for (size_t i = 0; i < mm_tag.depth; ++i)
		  {
			  FIELDS(b.blockchain_branch[i]);
			  if (i + 1 < mm_tag.depth)
				  ar.delimit_array();
		  }
		  ar.end_array();
	  }
	  END_SERIALIZE()
  };

  // Implemented below
  inline serializable_bytecoin_block make_serializable_bytecoin_block(const block& b, bool hashing_serialization, bool header_only);

  struct block_header
  {
    uint8_t major_version;
    uint8_t minor_version;  // now used as a voting mechanism, rather than how this particular block is built
    uint64_t timestamp;
    crypto::hash prev_id;
    uint32_t nonce;

    BEGIN_SERIALIZE()
      VARINT_FIELD(major_version)
		if (major_version > BLOCK_MAJOR_VERSION_4) {
			MERROR("Block version is too high " << (unsigned)major_version);
			return false;
		}
      VARINT_FIELD(minor_version)
	  if (major_version == BLOCK_MAJOR_VERSION_1 || major_version >= BLOCK_MAJOR_VERSION_4)
		  VARINT_FIELD(timestamp)
      FIELD(prev_id)
	  if (major_version == BLOCK_MAJOR_VERSION_1 || major_version >= BLOCK_MAJOR_VERSION_4)
		FIELD(nonce)
    END_SERIALIZE()
  };

  struct block: public block_header
  {
  private:
    // hash cash
    mutable std::atomic<bool> hash_valid;

  public:
    block(): block_header(), hash_valid(false) {}
    block(const block &b): block_header(b), hash_valid(false), miner_tx(b.miner_tx), parent_block(b.parent_block), tx_hashes(b.tx_hashes) { if (b.is_hash_valid()) { hash = b.hash; set_hash_valid(true); } }
	block &operator=(const block &b) { block_header::operator=(b); hash_valid = false; miner_tx = b.miner_tx; parent_block = b.parent_block; tx_hashes = b.tx_hashes; if (b.is_hash_valid()) { hash = b.hash; set_hash_valid(true); } return *this; }
    void invalidate_hashes() { set_hash_valid(false); }
    bool is_hash_valid() const { return hash_valid.load(std::memory_order_acquire); }
    void set_hash_valid(bool v) const { hash_valid.store(v,std::memory_order_release); }

	bytecoin_block parent_block;
    transaction miner_tx;
    std::vector<crypto::hash> tx_hashes;

    // hash cash
    mutable crypto::hash hash;

    BEGIN_SERIALIZE_OBJECT()
      if (!typename Archive<W>::is_saving())
        set_hash_valid(false);
      FIELDS(*static_cast<block_header *>(this))
	  if (major_version == BLOCK_MAJOR_VERSION_2 || major_version == BLOCK_MAJOR_VERSION_3) {
		  auto sbb = make_serializable_bytecoin_block(*this, false, false);
		  FIELD_N("parent_block", sbb);
	  }
      FIELD(miner_tx)
      FIELD(tx_hashes)
    END_SERIALIZE()
  };

  inline serializable_bytecoin_block make_serializable_bytecoin_block(const block& b, bool hashing_serialization, bool header_only)
  {
	block & block_ref = const_cast<block&>(b);
	return serializable_bytecoin_block(block_ref.parent_block, block_ref.timestamp, hashing_serialization, header_only);
  }

  /************************************************************************/
  /*                                                                      */
  /************************************************************************/
  struct account_public_address
  {
    crypto::public_key m_spend_public_key;
    crypto::public_key m_view_public_key;

    BEGIN_SERIALIZE_OBJECT()
      FIELD(m_spend_public_key)
      FIELD(m_view_public_key)
    END_SERIALIZE()

    BEGIN_KV_SERIALIZE_MAP()
      KV_SERIALIZE_VAL_POD_AS_BLOB_FORCE(m_spend_public_key)
      KV_SERIALIZE_VAL_POD_AS_BLOB_FORCE(m_view_public_key)
    END_KV_SERIALIZE_MAP()
  };

  struct keypair
  {
    crypto::public_key pub;
    crypto::secret_key sec;

    static inline keypair generate()
    {
      keypair k;
      generate_keys(k.pub, k.sec);
      return k;
    }
  };
  //---------------------------------------------------------------

}

BLOB_SERIALIZER(cryptonote::txout_to_key);
BLOB_SERIALIZER(cryptonote::txout_to_scripthash);

VARIANT_TAG(binary_archive, cryptonote::txin_gen, 0xff);
VARIANT_TAG(binary_archive, cryptonote::txin_to_script, 0x0);
VARIANT_TAG(binary_archive, cryptonote::txin_to_scripthash, 0x1);
VARIANT_TAG(binary_archive, cryptonote::txin_to_key, 0x2);
VARIANT_TAG(binary_archive, cryptonote::txout_to_script, 0x0);
VARIANT_TAG(binary_archive, cryptonote::txout_to_scripthash, 0x1);
VARIANT_TAG(binary_archive, cryptonote::txout_to_key, 0x2);
VARIANT_TAG(binary_archive, cryptonote::transaction, 0xcc);
VARIANT_TAG(binary_archive, cryptonote::block, 0xbb);

VARIANT_TAG(json_archive, cryptonote::txin_gen, "gen");
VARIANT_TAG(json_archive, cryptonote::txin_to_script, "script");
VARIANT_TAG(json_archive, cryptonote::txin_to_scripthash, "scripthash");
VARIANT_TAG(json_archive, cryptonote::txin_to_key, "key");
VARIANT_TAG(json_archive, cryptonote::txout_to_script, "script");
VARIANT_TAG(json_archive, cryptonote::txout_to_scripthash, "scripthash");
VARIANT_TAG(json_archive, cryptonote::txout_to_key, "key");
VARIANT_TAG(json_archive, cryptonote::transaction, "tx");
VARIANT_TAG(json_archive, cryptonote::block, "block");

VARIANT_TAG(debug_archive, cryptonote::txin_gen, "gen");
VARIANT_TAG(debug_archive, cryptonote::txin_to_script, "script");
VARIANT_TAG(debug_archive, cryptonote::txin_to_scripthash, "scripthash");
VARIANT_TAG(debug_archive, cryptonote::txin_to_key, "key");
VARIANT_TAG(debug_archive, cryptonote::txout_to_script, "script");
VARIANT_TAG(debug_archive, cryptonote::txout_to_scripthash, "scripthash");
VARIANT_TAG(debug_archive, cryptonote::txout_to_key, "key");
VARIANT_TAG(debug_archive, cryptonote::transaction, "tx");
VARIANT_TAG(debug_archive, cryptonote::block, "block");
