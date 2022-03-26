{-# LANGUAGE CApiFFI #-}

module Cryptography.Hydrogen.Helpers
  ( -- * Zeroing memory
    hydroMemzero,

    -- * Constant-time equality
    hydroEqual,

    -- * Hexadecimal encoding and decoding
    hydroBin2Hex,
    hydroHex2Bin,

    -- * Large unsigned numbers
    hydroIncrement,
    hydroCompare,

    -- * Padding
    hydroPad,
    hydroUnpad,
  )
where

import Data.Word (Word8)
import Foreign.C.Types (CChar, CInt (CInt), CSize (CSize), CUChar)
import Foreign.Ptr (Ptr)
import System.Posix.Types (CSsize (CSsize))

-- | Overwrites a memory region with zeroes. Can be used to wipe sensitive data
-- after it's no longer needed.
--
-- = Corresponds to
--
-- [@hydro_memzero@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#zeroing-memory)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_memzero"
  hydroMemzero ::
    -- | Memory area to zero.
    Ptr CUChar ->
    -- | How many bytes to zero.
    CSize ->
    -- | Does not return anything.
    IO ()

-- | A constant-time test for equality. Should be used when comparing secret
-- data, such as authentication tags or keys, to avoid side-channel attacks.
--
-- = Important note
--
-- If the two arguments are equal as 'Ptr's (that is, refer to the same
-- address), this function will return @0@, as this is only likely to happen on
-- misuse.
--
-- = Corresponds to
--
-- [@hydro_equal@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#constant-time-test-for-equality)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_equal"
  hydroEqual ::
    -- | Pointer to first data block. Will not be modified.
    Ptr CUChar ->
    -- | Pointer to second data block. Will not be modified.
    Ptr CUChar ->
    -- | How many bytes from each block to compare.
    CSize ->
    -- | @1@ if both areas are equal, @0@ otherwise.
    CInt

-- | Hexadecimal encoding, converting a byte sequence into a
-- hexadecimal one. The result written to the out-parameter will be a C string,
-- including a terminating null byte. This function is constant-time for any
-- given length of input.
--
-- = Corresponds to
--
-- [@hydro_bin2hex@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#hexadecimal-encodingdecoding)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_bin2hex"
  hydroBin2Hex ::
    -- | Out-parameter for C string result.
    Ptr CChar ->
    -- | Maximum number of bytes to write to the out-parameter. If the binary
    -- string to convert has length @n@, this must be at least @2n + 1@.
    CSize ->
    -- | Pointer to binary data to convert to hex. Will not be modified.
    Ptr Word8 ->
    -- | Length of data to convert to hex.
    CSize ->
    -- | Returns its first argument on success, and 'Foreign.Ptr.nullPtr'
    -- otherwise.
    IO (Ptr CChar)

-- | Parse a hexadecimal string into a byte sequence. The hexadecimal string
-- does not have to be null-terminated, as its length is specified as an
-- argument. This function is constant-time for any given length and format,
-- defined as \'number of bytes to write and set of characters to ignore\'.
--
-- = Note about \'ignore\' argument
--
-- This argument is a C string of characters to skip. For example, if passed
-- (the equivalent of) @": "@, (the equivalents of) @"69:FC"@, @"69 FC"@ and
-- @"69 : FC"@ would all be valid inputs, and parse the same.
--
-- Additionally, you can also pass 'nullPtr' to use a \'strict mode\' which
-- disallows /all/ non-hexadecimal characters.
--
-- = Note about \'hex end\' argument
--
-- Normally, this function stops in one of three situations:
--
-- * When it encounters a non-hexadecimal, non-ignored (as per \'ignore\'
-- argument) character in the input; or
-- * When the maximum permitted number of bytes has been written; or
-- * The entire specified length has been parsed.
--
-- If the \'hex end\' argument is not set to 'nullPtr', it will be set to point
-- to the character following the last parsed character of the input.
--
-- = Corresponds to
--
-- [@hydro_hex2bin@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#hexadecimal-encodingdecoding)
--
-- @since 1.0.0
foreign import ccall unsafe "hydrogen.h hydro_hex2bin"
  -- We need to use ccall unsafe due to this fix not being backported yet: https://gitlab.haskell.org/ghc/ghc/-/commit/34f224e0bb6b1e81d7e50c1b48946a3cd196f9e7
  hydroHex2Bin ::
    -- | Out-parameter for byte sequence result.
    Ptr Word8 ->
    -- | Maximum number of bytes to write.
    CSize ->
    -- | Pointer to hexadecimal string to parse. Will not be modified.
    Ptr CChar ->
    -- | How much of the string to read.
    CSize ->
    -- | \'Ignore\' argument (see note). Will not be modified.
    Ptr CChar ->
    -- | \'Hex end\' argument (see note).
    Ptr (Ptr CChar) ->
    -- | @-1@ if there was not sufficient space to produce the entire parsed
    -- result; otherwise, the number of bytes written to the out-parameter for
    -- the byte sequence result.
    IO CInt

-- | Increment a little-endian-represented unsigned number, in constant time for
-- a given length.
--
-- = Corresponds to
--
-- [@hydro_increment@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#incrementing-large-numbers)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_increment"
  hydroIncrement ::
    -- | Pointer to little-endian-encoded number data. Will be modified
    -- in-place.
    Ptr Word8 ->
    -- | Length of data.
    CSize ->
    -- | Modifies in-place.
    IO ()

-- | Compare two little-endian-represented unsigned numbers, in constant time
-- for a given length.
--
-- = Corresponds to
--
-- [@hydro_compare@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#comparing-large-numbers)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_compare"
  hydroCompare ::
    -- | Pointer to first little-endian-encoded number data. Will not be
    -- modified.
    Ptr Word8 ->
    -- | Pointer to second little-endian-encoded number data. Will not be
    -- modified.
    Ptr Word8 ->
    -- | Length of data to compare.
    CSize ->
    -- | @0@ if the first and second number are the same, @-1@ if the first
    -- number is smaller, @1@ otherwise.
    CInt

-- | Pad some data using [the ISO/IEC 7816-4 padding
-- algorithm](https://en.wikipedia.org/wiki/Padding_(cryptography)#ISO/IEC_7816-4),
-- so that the total length becomes a multiple of the specified amount.
--
-- = Corresponds to
--
-- [@hydro_pad@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#padding)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_pad"
  hydroPad ::
    -- | Pointer to the data to pad. This should include space for padding. Will
    -- be modified in-place.
    Ptr CUChar ->
    -- | Length of /unpadded/ data.
    CSize ->
    -- | The \'block size\': the final padded length will be a multiple of this
    -- amount.
    CSize ->
    -- | Maximum length we can write to the data pointer. This includes /both/
    -- the original data /and/ the padding this function will add.
    CSize ->
    -- | The final padded size, or @-1@ if there was not enough space.
    IO CInt

-- | Compute the original, unpadded length of some data previously padded with
-- 'hydroPad'.
--
-- = Corresponds to
--
-- [@hydro_unpad@](https://github.com/jedisct1/libhydrogen/wiki/Helpers#padding)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_unpad"
  hydroUnpad ::
    -- | Pointer to padded data. Will not be modified.
    Ptr CUChar ->
    -- | The length of the padded data.
    CSize ->
    -- | The \'block size\' used as a padding target; the length of the data
    -- must be a multiple of this number.
    CSize ->
    -- | The original length of the data (without padding), or @-1@ if the
    -- padding is incorrect given the other parameters.
    CSsize
