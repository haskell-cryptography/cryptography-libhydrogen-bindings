{-# LANGUAGE CApiFFI #-}

module Cryptography.Hydrogen.Bindings.Main
  ( -- * Initialization
    hydroInit,

    -- * Versioning
    hydroVersionMajor,
    hydroVersionMinor,
  )
where

import Foreign.C.Types (CInt (CInt))

-- | Sets up @libhydrogen@. Only needs to be called once, before any of the
-- bindings in this package are used.
--
-- = Note
--
-- If you are implementing a library using the bindings we provide, you probably
-- don't need to worry about calling this function. For any executable (whether
-- it be an actual application, a test, a benchmark, or anything else), calling
-- it once, before you do anything else, is sufficient. Duplicate calls are
-- harmless, but pointless.
--
-- = Corresponds to
--
-- [@hydro_init@](https://github.com/jedisct1/libhydrogen/wiki/Installation#usage-on-all-systems)
--
-- @since 1.0.0
foreign import capi "hydrogen.h hydro_init"
  hydroInit ::
    -- | @0@ on success, @-1@ on failure.
    IO CInt

-- | The major version of @libhydrogen@ used in these bindings.
--
-- = Corresponds to
--
-- [@HYDRO_VERSION_MAJOR@](https://github.com/jedisct1/libhydrogen/wiki/Installation#usage-on-all-systems)
--
-- @since 1.0.0
foreign import capi "hydrogen.h value HYDRO_VERSION_MAJOR"
  hydroVersionMajor :: CInt

-- | The minor version of @libhydrogen@ used in these bindings.
--
-- = Corresponds to
--
-- [@HYDRO_VERSION_MINOR@](https://github.com/jedisct1/libhydrogen/wiki/Installation#usage-on-all-systems)
--
-- @since 1.0.0
foreign import capi "hydrogen.h value HYDRO_VERSION_MINOR"
  hydroVersionMinor :: CInt
