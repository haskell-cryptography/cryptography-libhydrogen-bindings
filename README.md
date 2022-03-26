# `cryptography-libhydrogen-bindings` [![CI](https://github.com/haskell-cryptography/cryptography-libhydrogen-bindings/actions/workflows/ci.yml/badge.svg)](https://github.com/haskell-cryptography/cryptography-libhydrogen-bindings/actions/workflows/ci.yml) [![made with Haskell](https://img.shields.io/badge/Made%20in-Haskell-%235e5086?logo=haskell&style=flat-square)](https://haskell.org)

## What is this?

A set of low-level bindings (and helpers) wrapping
[`libhydrogen`](https://github.com/jedisct1/libhydrogen), commit
`7bd39c471d31e654b132153c04e20ff49f257cb2`.

## What're the goals of this project?

### Ease of use

No user of this library should ever have to think about C, linking to system
libraries, enabling SIMD through weird flags, or any similar issues. Just add
this as a dependency and go.

### Minimality

No weird lawless type class hierarchy. No dependencies outside of `base`. These
are truly minimal bindings, for those who want the ability to operate as close
to the original code as posssible.

### Stability and clarity

Just by reading the documentation of this library, you should know everything
you need to use it. No reading the C 'documentation' should ever be required.
Furthermore, you shouldn't need to doubt that this behaves - our CI should prove
it to you. No surprises on upgrades either - _impeccable_
[PVP](https://pvp.haskell.org) compliance only here.

## How do I use this?

See the Haddocks for each of the public modules for explanations of what
functions all do. These are deliberately kept close to C, as they're designed to
be 'wrapped up' in whatever API you choose to expose.

## What does this run on?

Our CI currently checks Windows, Linux (on Ubuntu) and macOS. We check the
following GHC versions:

* 8.10.7
* 9.0.2
* 9.2.2

## What can I do with this?

The bindings themselves are licensed under `BSD-3-Clause`, while the C code for
`libhydrogen` is under `ISC`. See the `LICENSE` and `LICENSE.LIBHYDROGEN` files for
more information.
