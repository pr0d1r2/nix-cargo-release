# nix-cargo-release

[![CI](https://github.com/pr0d1r2/nix-cargo-release/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-cargo-release/actions/workflows/ci.yml) [![NixOS 26.05](https://img.shields.io/badge/NixOS-26.05-blue.svg?logo=nixos)](https://nixos.org)

Nix package for [cargo-release](https://github.com/crate-ci/cargo-release), held at **1.1.6**, the last release that builds with the rustc of the fleet's nixpkgs pin. Pre-built binaries are served via [cachix](https://pr0d1r2.cachix.org).

## Why

nixos-26.05 ships cargo-release 1.1.7, which declares `rust-version = 1.97`, while the channel's rustc is 1.95.0. Any dev shell that includes `pkgs.cargo-release` therefore fails to build:

```text
error: rustc 1.95.0 is not supported by the following packages:
  cargo-release@1.1.7 requires rustc 1.97
```

1.1.6 declares `rust-version = 1.92`. The recipe is nixpkgs' own with the version and hashes changed.

## Usage

As an overlay, so `pkgs.cargo-release` is this build:

```nix
{
  inputs.nix-cargo-release = {
    url = "github:pr0d1r2/nix-cargo-release";
    inputs.nixpkgs-lock.follows = "nixpkgs-lock";
  };

  # pkgs = nixpkgs.legacyPackages.${system}.extend nix-cargo-release.overlays.default;
}
```

Or the package directly: `nix-cargo-release.packages.${system}.default`.

Retire it once the channel ships a cargo-release its own rustc builds.

## Binary cache

To accept the cache without prompts, add to `~/.config/nix/nix.conf`:

```ini
trusted-substituters = https://pr0d1r2.cachix.org
trusted-public-keys = pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=
```
