# Changelog

## [0.6.2](https://github.com/neochrome/r65/compare/v0.6.1...v0.6.2) (2023-11-15)


### Bug Fixes

* **c64:** program execution should wait for subprocess to finish ([a95c0c7](https://github.com/neochrome/r65/commit/a95c0c7ac87dbe8bce8b4dd79f3620e18bb54af7))

## [0.6.1](https://github.com/neochrome/r65/compare/v0.6.0...v0.6.1) (2023-11-15)


### Miscellaneous Chores

* release 0.6.1 ([8746835](https://github.com/neochrome/r65/commit/87468359efec50573485a7d8f052c9dcf837f344))

## [0.6.0](https://github.com/neochrome/r65/compare/v0.5.0...v0.6.0) (2023-11-13)


### Features

* add pseudo instruction to encode text ([5e353b1](https://github.com/neochrome/r65/commit/5e353b16f1cfb8ec8f11d834a4d54e244700ea2e))

## [0.5.0](https://github.com/neochrome/r65/compare/v0.4.1...v0.5.0) (2021-12-29)

* Bump r65 to 0.5.0 (tag: v0.5.0)
* segment switching now keeps current scope by default
* also build examples by default
* add simple checkpoint validation and fix symbol generation
* update syntax example
* make disasm output more "assembler" like :)
* default fill byte to 0x00
* rename implicit segment scopes
* add TinyRand macro
* add raster chain helper
* no need to write symbols a binary file
* add support to resolve fully qualified label
* detect correct default filename when saving
* fix DEBUG test for raster util macro
* fix unary not operator for Integers

## [0.4.1](https://github.com/neochrome/r65/compare/v0.4.0...v0.4.1) (2021-12-06)

* add support to configure checkpoints for labels

## [0.4.0](https://github.com/neochrome/r65/compare/v0.3.0...v0.4.0) (2021-12-06)

* macros by default in scope, add option to give separate scope
* add support to launch vice with symbols loaded
* add support to emit symbols (labels)

## [0.3.0](https://github.com/neochrome/r65/compare/v0.2.1...v0.3.0) (2021-12-05)

* c64 bootstrap macro must only be used with a block
* add support for calling macros in current scope
* add more addressing specs
* add c64 IO constants for keyboard access

## [0.2.1](https://github.com/neochrome/r65/compare/v0.2.0...v0.2.1) (2021-12-01)

* include label names when printing a program

## [0.2.0](https://github.com/neochrome/r65/compare/v0.1.0...v0.2.0) (2021-12-01)

* updated c64 constants
* make macro calling work with all sorts of args

## [0.1.0](https://github.com/neochrome/r65/compare/4dbc6ae...v0.1.0) (2021-11-28)

* package as a gem
* unlicense
* initial version
