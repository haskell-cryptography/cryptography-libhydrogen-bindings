{-# LANGUAGE CApiFFI #-}

-- | = Note on contexts
--
-- A context is an eight-byte sequence, designed to distinguish domains in which
-- security-oriented functions are called. This means that, even if keys are
-- shared across contexts, the results are unlikely to be the same.
--
-- Contexts don't have to be secret, or have a low entropy. It is acceptable to
-- use the same context for your entire application.
--
-- For more details, see [the documentation for contexts in
-- @libhydrogen@](https://github.com/jedisct1/libhydrogen/wiki/Contexts).
module Cryptography.Hydrogen.Bindings.GenericHashing
  ( -- * Types
    HydroHashState,

    -- * Constants
    hydroHashKeyBytes,
    hydroHashStateSize,
    hydroHashBytesMin,
    hydroHashBytesMax,
    hydroHashBytes,

    -- * Functions
    hydroHashKeygen,
    hydroHashHash,
    hydroHashInit,
    hydroHashUpdate,
    hydroHashFinal,
  )
where

import Data.Word (Word8)
import Foreign.C.Types (CChar, CInt (CInt), CSize (CSize))
import Foreign.Ptr (Ptr)

-- | Generate a hashing key.
--
-- = Corresponds to
--
-- [@hydro_hash_keygen@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#usage)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_hash_keygen"
  hydroHashKeygen ::
    -- | Out-parameter where the key will be written. Must have space for
    -- 'hydroHashKeyBytes'-many bytes. Will be modified in-place.
    Ptr Word8 ->
    -- | Works in-place.
    IO ()

-- | The number of bytes in a hashing key suitable for use with the functions in
-- this module. Also the size of key that gets generated by 'hydroHashKeygen'.
--
-- = Corresponds to
--
-- [@hydro_hash_KEYBYTES@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#constants)
--
-- @since 1.0.0
foreign import capi "hydrogen.h value hydro_hash_KEYBYTES"
  hydroHashKeyBytes :: CSize

-- | Hashes a message of a given length.
--
-- = Corresponds to
--
-- [@hydro_hash_hash@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#usage)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_hash_hash"
  hydroHashHash ::
    -- | Out-parameter where the hash will be written to. Will be modified
    -- in-place.
    Ptr Word8 ->
    -- | The length of the result. This must be at least 'hydroHashBytesMin',
    -- and at most 'hydroHashBytesMax' (inclusive on both ends). A good typical
    -- choice is 'hydroHashBytes'.
    CSize ->
    -- | The byte sequence to hash. Will not be modified.
    Ptr Word8 ->
    -- | The length of the sequence to hash.
    CSize ->
    -- | A context (see note on contexts).
    Ptr CChar ->
    -- | A key. This can be 'nullPtr'.
    Ptr Word8 ->
    -- | Something that needs clarification.
    IO CInt

-- | An opaque type representing hash state. You can only use this via a 'Ptr',
-- the memory for which has be allocated by the caller. We provide
-- 'hydroHashStateSize' to help with this.
--
-- = Corresponds to
--
-- [@hydro_hash_state@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#data-types)
--
-- @since 1.0.0
data HydroHashState

-- | The amount of memory needed to store a 'HydroHashState' (by way of a
-- pointer).
--
-- @since 1.0.0
foreign import capi "hydrogen_helpers.h value hydro_hash_state_size"
  hydroHashStateSize :: CSize

-- | The minimum possible size for a hash produced by this API.
--
-- = Corresponds to
--
-- [@hydro_hash_BYTES_MIN@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#constants)
--
-- @since 1.0.0
foreign import capi "hydrogen.h value hydro_hash_BYTES_MIN"
  hydroHashBytesMin :: CSize

-- | The maximum possible size for a hash produced by this API.
--
-- = Corresponds to
--
-- [@hydro_hash_BYTES_MAX@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#constants)
--
-- @since 1.0.0
foreign import capi "hydrogen.h value hydro_hash_BYTES_MAX"
  hydroHashBytesMax :: CSize

-- | The recommended size for a hash produced by this API.
--
-- = Corresponds to
--
-- [@hydro_hash_BYTES@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#constants)
--
-- @since 1.0.0
foreign import capi "hydrogen.h value hydro_hash_BYTES"
  hydroHashBytes :: CSize

-- | Initializes a 'HydroHashState' for a streaming hash.
--
-- = Corresponds to
--
-- [@hydro_hash_init@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#usage)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_hash_init"
  hydroHashInit ::
    -- | Pointer to hash state to initialize. Will be modified in-place.
    Ptr HydroHashState ->
    -- | A context (see note on contexts).
    Ptr CChar ->
    -- | A key. This can be 'nullPtr'.
    Ptr Word8 ->
    -- | Something that needs clarification.
    IO CInt

-- | Hash the given byte sequence \'into\' the hash state.
--
-- = Corresponds to
--
-- [@hydro_hash_update@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#usage)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_hash_update"
  hydroHashUpdate ::
    -- | Pointer to hash state. Will be modified in-place.
    Ptr HydroHashState ->
    -- | The byte sequence to \'hash in\'. Will not be modified.
    Ptr Word8 ->
    -- | The length of the byte sequence.
    CSize ->
    -- | Something that needs clarification.
    IO CInt

-- | Convert the accumulated hash state into a hash. The resulting hash state
-- should not be used after this call.
--
-- = Corresponds to
--
-- [@hydro_hash_final@](https://github.com/jedisct1/libhydrogen/wiki/Generic-hashing#usage)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_hash_final"
  hydroHashFinal ::
    -- | Pointer to hash state. Will be modified in-place, and will not be valid
    -- for future calls.
    Ptr HydroHashState ->
    -- | Out-parameter to store the resulting hash. Will be modified in-place.
    Ptr Word8 ->
    -- | The length of the result. This must be at least 'hydroHashBytesMin',
    -- and at most 'hydroHashBytesMax' (inclusive on both ends). A good typical
    -- choice is 'hydroHashBytes'.
    CSize ->
    -- | Something that needs clarification.
    IO CInt