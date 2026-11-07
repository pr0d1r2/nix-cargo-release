{
  description = "Nix package for cargo-release, held at the last release the fleet's rustc builds";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  # Consumer-facing flake: every input here lands in every consumer's lock,
  # so it carries only what the package needs.
  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    rec {
      packages = forAllSystems (
        pkgs:
        let
          package = pkgs.callPackage ./cargo-release.nix { };
        in
        {
          default = package;
          cargo-release = package;
        }
      );

      # `pkgs.cargo-release` becomes this flake's cached build:
      #   nixpkgs.legacyPackages.${system}.extend nix-cargo-release.overlays.default
      overlays.default = final: _prev: {
        inherit (packages.${final.stdenv.hostPlatform.system}) cargo-release;
      };

      checks = forAllSystems (pkgs: {
        version = pkgs.runCommand "cargo-release-version" { } ''
          ${packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/cargo-release release --version | grep -F 1.1.6
          touch $out
        '';
      });
    };
}
