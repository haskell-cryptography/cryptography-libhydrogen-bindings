{-# LANGUAGE CApiFFI #-}

module Cryptography.Hydrogen.Bindings.Random
  ( -- * Random generation
    hydroRandomU32,
    hydroRandomUniform,
    hydroRandomBuf,
    hydroRandomBufDeterministic,

    -- * Reseeding
    hydroRandomRatchet,
    hydroRandomReseed,

    -- * Constants
    hydroRandomSeedBytes,
  )
where

import Data.Word (Word32, Word8)
import Foreign.C.Types (CSize (CSize), CUChar)
import Foreign.Ptr (Ptr)

-- | Generate an unpredictable value between @0x00000000@ and @0xffffffff@.
--
-- = Corresponds to
--
-- [@hydro_random_u32@](https://github.com/jedisct1/libhydrogen/wiki/Random-numbers#32-bit-random-numbers)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_random_u32"
  hydroRandomU32 :: IO Word32

-- | Generate an unpredictable value from @0x00000000@ (inclusive) and the given
-- argument (exclusive). All values in this range can occur with equal
-- probability.
--
-- = Corresponds to
--
-- [@hydro_random_uniform@](https://github.com/jedisct1/libhydrogen/wiki/Random-numbers#random-numbers-within-an-arbitrary-interval)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_random_uniform"
  hydroRandomUniform ::
    -- | Upper bound (exclusive).
    Word32 ->
    IO Word32

-- | Fill a buffer with random bytes.
--
-- = Corresponds to
--
-- [@hydro_random_uniform@](https://github.com/jedisct1/libhydrogen/wiki/Random-numbers#generating-an-arbitrary-long-random-sequence)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_random_buf"
  hydroRandomBuf ::
    -- | Out-parameter to fill.
    Ptr CUChar ->
    -- | Number of bytes to write.
    CSize ->
    -- | Works in-place.
    IO ()

-- | Fill a buffer with random bytes based on the given seed. For a given seed,
-- this will always produce the same bytes. Mostly useful for tests.
--
-- = Corresponds to
--
-- [@hydro_random_buf_deterministic@](https://github.com/jedisct1/libhydrogen/wiki/Random-numbers#deterministic-random-numbers)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_random_buf_deterministic"
  hydroRandomBufDeterministic ::
    -- | Out-parameter to fill.
    Ptr CUChar ->
    -- | Number of bytes to write.
    CSize ->
    -- | Pointer to a seed. Must point to exactly 'hydroRandomSeedBytes' bytes.
    -- Will not be modified.
    Ptr Word8 ->
    -- | Works in-place.
    IO ()

-- | The length of a seed suitable for use with 'hydroRandomBufDeterministic'.
--
-- = Corresponds to
--
-- [@hydro_random_SEEDBYTES@](https://github.com/jedisct1/libhydrogen/wiki/Random-numbers#constants)
--
-- @since 1.0.0
foreign import capi "hydrogen.h value hydro_random_SEEDBYTES"
  hydroRandomSeedBytes :: CSize

-- | Erase part of the PRNG state, and replace the secret key. This ensures that
-- the state is not recoverable.
--
-- = Corresponds to
--
-- [@hydro_random_ratchet@](https://github.com/jedisct1/libhydrogen/wiki/Random-numbers#ratcheting)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_random_ratchet"
  hydroRandomRatchet :: IO ()

-- | Reseeds the PRNG. Should be used if you plan to combine these bindings with
-- 'Control.Concurrent.forkOS', or anything which uses similar functionality
-- (that is, bound threads).
--
-- = Corresponds to
--
-- [@hydro_random_reseed@](https://github.com/jedisct1/libhydrogen/wiki/Random-numbers#reseeding)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_random_reseed"
  hydroRandomReseed :: IO ()
