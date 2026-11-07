# SPEC — nix-cargo-release

## §G GOAL

cargo-release for the fleet's dev shells, at the newest release the fleet's pinned rustc can build, cached on `pr0d1r2.cachix.org`, until nixpkgs ships one its own rustc builds.

## §C CONSTRAINTS

- C1: Nix flake; nixpkgs follows `github:pr0d1r2/nixpkgs-lock` (the fleet pin, `nixos-26.05`, rustc 1.95.0 on 2026-11-07).
- C2: 4 systems: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux; x86_64-darwin is evaluated, never built.
- C3: the recipe is nixpkgs' `pkgs/by-name/ca/cargo-release/package.nix` with only the version and the two hashes changed.
- C4: root flake inputs are `nixpkgs-lock` and `nixpkgs` only: every root input lands in every consumer's lock.
- C5: cachix binary cache in `nixConfig`.

## §I INTERFACES

- I.pkg: `packages.<system>.{default,cargo-release}`.
- I.overlay: `overlays.default` — `pkgs.cargo-release` becomes this flake's cached build.
- I.check: `checks.<system>.version` — the binary reports the held version.

## §V INVARIANTS

V1: the held version's `rust-version` is at most the rustc of nixpkgs-lock's channel; CI builds it with that rustc on every tier-1 system.
V2: this flake's nixpkgs rev equals nixpkgs-lock's (CI `assert-pins`), so consumers on the fleet pin substitute it from the cache.

## §T TASKS

id|status|task|cites
T1|x|package cargo-release 1.1.6 with an overlay, a version check and CI|C3,V1
T2|.|retire the repo once nixpkgs-lock's channel ships a cargo-release its own rustc builds: consumers drop the overlay|V1

## §B BUGS

id|date|cause|fix
