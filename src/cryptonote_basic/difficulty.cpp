// Copyright (c) 2018- Lethean developers
// Copyright (c) 2017 SUMOKOIN
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

#include <algorithm>
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <vector>

//#include "include_base_utils.h"
#include "misc_language.h"
#include "common/int-util.h"
#include "crypto/hash.h"
#include "cryptonote_config.h"
#include "difficulty.h"
#include "boost/math/special_functions/round.hpp"

#undef MONERO_DEFAULT_LOG_CATEGORY
#define MONERO_DEFAULT_LOG_CATEGORY "difficulty"


#define MAX_AVERAGE_TIMESPAN          (uint64_t) DIFFICULTY_TARGET_V2*12  // 24 minutes
#define MIN_AVERAGE_TIMESPAN          (uint64_t) DIFFICULTY_TARGET_V2/12  // 10s


namespace cryptonote {

  using std::size_t;
  using std::uint64_t;
  using std::vector;

#if defined(__x86_64__)
  static inline void mul(uint64_t a, uint64_t b, uint64_t &low, uint64_t &high) {
    low = mul128(a, b, &high);
  }

#else

  static inline void mul(uint64_t a, uint64_t b, uint64_t &low, uint64_t &high) {
    // __int128 isn't part of the standard, so the previous function wasn't portable. mul128() in Windows is fine,
    // but this portable function should be used elsewhere. Credit for this function goes to latexi95.

    uint64_t aLow = a & 0xFFFFFFFF;
    uint64_t aHigh = a >> 32;
    uint64_t bLow = b & 0xFFFFFFFF;
    uint64_t bHigh = b >> 32;

    uint64_t res = aLow * bLow;
    uint64_t lowRes1 = res & 0xFFFFFFFF;
    uint64_t carry = res >> 32;

    res = aHigh * bLow + carry;
    uint64_t highResHigh1 = res >> 32;
    uint64_t highResLow1 = res & 0xFFFFFFFF;

    res = aLow * bHigh;
    uint64_t lowRes2 = res & 0xFFFFFFFF;
    carry = res >> 32;

    res = aHigh * bHigh + carry;
    uint64_t highResHigh2 = res >> 32;
    uint64_t highResLow2 = res & 0xFFFFFFFF;

    //Addition

    uint64_t r = highResLow1 + lowRes2;
    carry = r >> 32;
    low = (r << 32) | lowRes1;
    r = highResHigh1 + highResLow2 + carry;
    uint64_t d3 = r & 0xFFFFFFFF;
    carry = r >> 32;
    r = highResHigh2 + carry;
    high = d3 | (r << 32);
  }

#endif

  static inline bool cadd(uint64_t a, uint64_t b) {
    return a + b < a;
  }

  static inline bool cadc(uint64_t a, uint64_t b, bool c) {
    return a + b < a || (c && a + b == (uint64_t) -1);
  }

  bool check_hash(const crypto::hash &hash, difficulty_type difficulty) {
    uint64_t low, high, top, cur;
    // First check the highest word, this will most likely fail for a random hash.
    mul(swap64le(((const uint64_t *) &hash)[3]), difficulty, top, high);
    if (high != 0) {
      return false;
    }
    mul(swap64le(((const uint64_t *) &hash)[0]), difficulty, low, cur);
    mul(swap64le(((const uint64_t *) &hash)[1]), difficulty, low, high);
    bool carry = cadd(cur, low);
    cur = high;
    mul(swap64le(((const uint64_t *) &hash)[2]), difficulty, low, high);
    carry = cadc(cur, low, carry);
    carry = cadc(high, top, carry);
    return !carry;
  }

	difficulty_type next_difficulty(uint8_t blockMajorVersion, std::vector<uint64_t> timestamps, std::vector<difficulty_type> cumulativeDifficulties) {

		if (blockMajorVersion >= BLOCK_MAJOR_VERSION_5) {
			// LWMA-3 difficulty algorithm 
			// Copyright (c) 2017-2018 Zawy, MIT License
			// https://github.com/zawy12/difficulty-algorithms/issues/3
			// See commented version for required config file changes. Fix your FTL and MTP.

			uint64_t  T = DIFFICULTY_TARGET_V2;
		    uint64_t  N = DIFFICULTY_WINDOW_V4; // N=45, 60, and 90 for T=600, 120, 60.
		    uint64_t  L(0), ST, sum_3_ST(0), next_D, prev_D, max_TS, prev_max_TS;
		        
		    assert(timestamps.size() == cumulativeDifficulties.size() && 
		    	timestamps.size() <= N+1 );

		    // If it's a new coin, do startup code. 
		    // Increase difficulty_guess if it needs to be much higher, but guess lower than lowest guess.
		    uint64_t difficulty_guess = 10000; 
		    if (timestamps.size() <= 10) { return difficulty_guess; }
		    if (timestamps.size() < N +1) { N = timestamps.size()-1; }

		    prev_max_TS = timestamps.front();
		    for ( uint64_t i = 1; i <= N; i++) {  
		      if (timestamps[i] > prev_max_TS) {   
		      	max_TS = timestamps[i];
		      } else {
		      	max_TS = prev_max_TS + 1;   
		      }
		      ST = std::min(6*T, max_TS - prev_max_TS);
		      prev_max_TS = max_TS;
		      L +=  ST * i ; 
		      if ( i > N-3 ) { sum_3_ST += ST; } 
		    }
		    next_D = ((cumulativeDifficulties[N] - cumulativeDifficulties[0])*T*(N+1)*99)/(100*2*L);

		    prev_D = cumulativeDifficulties[N] - cumulativeDifficulties[N-1];
		    next_D = std::max((prev_D*67)/100, std::min(next_D, (prev_D*150)/100));

		    // implement LWMA-2 change from LWMA. 
		    if ( sum_3_ST < (8*T)/10) {  next_D = std::max(next_D,(prev_D*108)/100); }

		    return next_D;

		} else if (blockMajorVersion == BLOCK_MAJOR_VERSION_4) {
			// LWMA difficulty algorithm
			// Background:  https://github.com/zawy12/difficulty-algorithms/issues/3
			// Copyright (c) 2017-2018 Zawy (pseudocode)
			// MIT license http://www.opensource.org/licenses/mit-license.php
			// Copyright (c) 2018 The Karbowanec developers (initial code)
			// Copyright (c) 2018 Haven Protocol (refinements)
			// Degnr8, Karbowanec, Masari, Bitcoin Gold, Bitcoin Candy, and Haven have contributed.

			// This algorithm is: next_difficulty = harmonic_mean(Difficulties) * T / LWMA(Solvetimes)
			// The harmonic_mean(Difficulties) = 1/average(Targets) so it is also:
			// next_target = avg(Targets) * LWMA(Solvetimes) / T.
			// This is "the best algorithm" because it has lowest root-mean-square error between 
			// needed & actual difficulty during hash attacks while having the lowest standard 
			// deviation during stable hashrate. That is, it's the fastest for a given stability and vice versa.
			// Do not use "if solvetime < 1 then solvetime = 1" which allows a catastrophic exploit.
			// Do not sort timestamps.  "Solvetimes" and "LWMA" variables must allow negatives.
			// Do not use MTP as most recent block.  Do not use (POW)Limits, filtering, or tempering.
			// Do not forget to set N (aka DIFFICULTY_WINDOW in Cryptonote) to recommendation below.
			// The nodes' future time limit (FTL) aka CRYPTONOTE_BLOCK_FUTURE_TIME_LIMIT needs to
			// be reduced from 60*60*2 to 500 seconds to prevent timestamp manipulation from miner's with 
			//  > 50% hash power.  If this is too small, it can be increased to 1000 at a cost in protection.

			// Set DIFFICULTY_WINDOW_V3 = N where N is defined below.
			// N=45, 55, 70, 90, 120 for T=600, 240, 120, 90, and 60 seconds
			// This is optimized for small coin protection.  It's fast!
			// Largest coin for a given POW can safely double N.

			// Set DIFFICULTY_BLOCKS_COUNT_V3 = DIFFICULTY_WINDOW_V3 +1;

			// Set your constants so everyone uses same variables.
			size_t N = DIFFICULTY_WINDOW_V3;
			const int64_t T = static_cast<int64_t>(DIFFICULTY_TARGET_V2);

			// Return a difficulty of 1 for first 3 blocks if it's the start of the chain.
			if (timestamps.size() < 4) { return 1; }
			// Otherwise, use a smaller N if the start of the chain is less than N+1.
			else if (timestamps.size() < N + 1) { N = timestamps.size() - 1; }
			// Otherwise make sure timestamps and cumulative_difficulties are correct size.
			else {
				timestamps.resize(N + 1);
				cumulativeDifficulties.resize(N + 1);
			}

			size_t length = timestamps.size();
			assert(length == cumulativeDifficulties.size());
			assert(length <= DIFFICULTY_BLOCKS_COUNT_V3);

			// To get an average solvetime to within +/- ~0.1%, use an adjustment factor.
			// adjust=0.999 for 80 < N < 120(?)
			const double adjust = 0.998;  // for 45 < N < 80 
										  // The divisor k normalizes the LWMA sum to a standard LWMA.
			const double k = N * (N + 1) / 2;

			double LWMA(0), sum_inverse_D(0), harmonic_mean_D(0), nextDifficulty(0);
			int64_t solveTime(0);
			uint64_t difficulty(0), next_difficulty(0);

			// Loop through N most recent blocks. N is most recently solved block.
			for (size_t i = 1; i <= N; i++) {
				solveTime = static_cast<int64_t>(timestamps[i]) - static_cast<int64_t>(timestamps[i - 1]);
				// Next line not required if coin uses BTC's MTP of 11 blocks & FTL=500 to 1000. 
				solveTime = std::min<int64_t>((T * 6), std::max<int64_t>(solveTime, (-6 * T)));
				difficulty = cumulativeDifficulties[i] - cumulativeDifficulties[i - 1];
				LWMA += (int64_t)(solveTime * i) / k;
				sum_inverse_D += 1 / static_cast<double>(difficulty);
			}
			harmonic_mean_D = N / sum_inverse_D;
			
			// Keep LWMA sane in case something unforeseen occurs.
			if (static_cast<int64_t>(boost::math::round(LWMA)) < T / 20)
				LWMA = static_cast<double>(T / 20);

			nextDifficulty = harmonic_mean_D * T / LWMA * adjust;

			// No limits should be employed, but this is correct way to employ a 20% symmetrical limit:
			// nextDifficulty=max(previous_Difficulty*0.8,min(previous_Difficulty/0.8, next_Difficulty)); 

			next_difficulty = static_cast<uint64_t>(nextDifficulty);
			return next_difficulty;

		} else if (blockMajorVersion == BLOCK_MAJOR_VERSION_3) {
			assert(DIFFICULTY_BLOCKS_COUNT_V2 >= 2);

			if (timestamps.size() > DIFFICULTY_BLOCKS_COUNT_V2) {
				timestamps.resize(DIFFICULTY_BLOCKS_COUNT_V2);
				cumulativeDifficulties.resize(DIFFICULTY_BLOCKS_COUNT_V2);
			}

			size_t length = timestamps.size();
			assert(length == cumulativeDifficulties.size());
			assert(length <= DIFFICULTY_BLOCKS_COUNT_V2);
			if (length <= 1) {
				return 1;
			}

			sort(timestamps.begin(), timestamps.end());

			size_t cutBegin, cutEnd;
			assert(2 * DIFFICULTY_CUT_V2 <= DIFFICULTY_BLOCKS_COUNT_V2 - 2);
			if (length <= DIFFICULTY_BLOCKS_COUNT_V2 - 2 * DIFFICULTY_CUT_V2) {
				cutBegin = 0;
				cutEnd = length;
			}
			else {
				cutBegin = (length - (DIFFICULTY_BLOCKS_COUNT_V2 - 2 * DIFFICULTY_CUT_V2) + 1) / 2;
				cutEnd = cutBegin + (DIFFICULTY_BLOCKS_COUNT_V2 - 2 * DIFFICULTY_CUT_V2);
			}
			assert(cutBegin + 2 <= cutEnd && cutEnd <= length);
			uint64_t totalTimespan = timestamps[cutEnd - 1] - timestamps[cutBegin];
			if (totalTimespan == 0) {
				totalTimespan = 1;
			}
			//LOG_PRINT_L3("Total timespan " << totalTimespan << " ts size " << timestamps.size() << " length " << length);

			// begin sumo

			uint64_t timespan_median = 0;
			if (cutBegin > 0 && length >= cutBegin * 2 + 3) {
				std::vector<std::uint64_t> time_spans;
				for (size_t i = length - cutBegin * 2 - 3; i < length - 1; i++) {
					uint64_t time_span = timestamps[i + 1] - timestamps[i];
					if (time_span == 0) {
						time_span = 1;
					}
					time_spans.push_back(time_span);

					//LOG_PRINT_L3("Timespan " << i << ": " << (time_span / 60) / 60 << ":" << (time_span > 3600 ? (time_span % 3600) / 60 : time_span / 60) << ":" << time_span % 60 << " (" << time_span << ")");
				}
				timespan_median = epee::misc_utils::median(time_spans);
			}

			uint64_t timespan_length = length - cutBegin * 2 - 1;
			//LOG_PRINT_L3("Timespan Median: " << timespan_median << ", Timespan Average: " << totalTimespan / timespan_length);

			uint64_t total_timespan_median = timespan_median > 0 ? timespan_median * timespan_length : totalTimespan * 7 / 10;
			uint64_t adjusted_total_timespan = (totalTimespan * 8 + total_timespan_median * 3) / 10; //  0.8A + 0.3M (the median of a poisson distribution is 70% of the mean, so 0.25A = 0.25/0.7 = 0.285M)
			if (adjusted_total_timespan > MAX_AVERAGE_TIMESPAN * timespan_length) {
				adjusted_total_timespan = MAX_AVERAGE_TIMESPAN * timespan_length;
			}
			if (adjusted_total_timespan < MIN_AVERAGE_TIMESPAN * timespan_length) {
				adjusted_total_timespan = MIN_AVERAGE_TIMESPAN * timespan_length;
			}

			//end sumo

			difficulty_type totalWork = cumulativeDifficulties[cutEnd - 1] - cumulativeDifficulties[cutBegin];
			assert(totalWork > 0);

			uint64_t low, high;
			low = mul128(totalWork, DIFFICULTY_TARGET_V2, &high);
			if (high != 0 || std::numeric_limits<uint64_t>::max() - low < (totalTimespan - 1)) {
				return 0;
			}

			//begin sumo
			uint64_t next_diff = (low + adjusted_total_timespan - 1) / adjusted_total_timespan;
			if (next_diff < 1) next_diff = 1;
			//LOG_PRINT_L3("Total timespan: " << totalTimespan << ", Adjusted total timespan: " << adjusted_total_timespan << ", Total work: " << totalWork << ", Next diff: " << next_diff << ", Hashrate (H/s): " << next_diff / DIFFICULTY_TARGET_V2);

			return next_diff;
			//end sumo
		} else {

			assert(DIFFICULTY_WINDOW >= 2);

			if (timestamps.size() > DIFFICULTY_WINDOW) {
				timestamps.resize(DIFFICULTY_WINDOW);
				cumulativeDifficulties.resize(DIFFICULTY_WINDOW);
			}

			size_t length = timestamps.size();
			assert(length == cumulativeDifficulties.size());
			assert(length <= DIFFICULTY_WINDOW);
			if (length <= 1) {
				return 1;
			}

			sort(timestamps.begin(), timestamps.end());

			size_t cutBegin, cutEnd;
			assert(2 * DIFFICULTY_CUT <= DIFFICULTY_WINDOW - 2);
			if (length <= DIFFICULTY_WINDOW - 2 * DIFFICULTY_CUT) {
				cutBegin = 0;
				cutEnd = length;
			}
			else {
				cutBegin = (length - (DIFFICULTY_WINDOW - 2 * DIFFICULTY_CUT) + 1) / 2;
				cutEnd = cutBegin + (DIFFICULTY_WINDOW - 2 * DIFFICULTY_CUT);
			}
			assert(/*cut_begin >= 0 &&*/ cutBegin + 2 <= cutEnd && cutEnd <= length);
			uint64_t timeSpan = timestamps[cutEnd - 1] - timestamps[cutBegin];
			if (timeSpan == 0) {
				timeSpan = 1;
			}

			difficulty_type totalWork = cumulativeDifficulties[cutEnd - 1] - cumulativeDifficulties[cutBegin];
			assert(totalWork > 0);

			uint64_t low, high;
			low = mul128(totalWork, DIFFICULTY_TARGET_V1, &high);
			if (high != 0 || std::numeric_limits<uint64_t>::max() - low < (timeSpan - 1)) {
				return 0;
			}

			return (low + timeSpan - 1) / timeSpan;
		}
	}
}
