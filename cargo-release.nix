# cargo-release, held at the last release that builds on the fleet's rustc.
#
# nixos-26.05 ships cargo-release 1.1.7, whose rust-version is 1.97, while
# the channel's rustc is 1.95.0, so `pkgs.cargo-release` cannot build there
# ("rustc 1.95.0 is not supported by the following packages:
# cargo-release@1.1.7 requires rustc 1.97", measured 2026-11-07 on seven
# fleet repos). 1.1.6 declares rust-version 1.92. The recipe is nixpkgs'
# (pkgs/by-name/ca/cargo-release/package.nix on nixos-26.05, MIT) with the
# version, source hash and cargo hash changed; nothing else.
#
# Delete this repo's use once nixpkgs-lock's channel ships a cargo-release
# its own rustc builds.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  stdenv,
  curl,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-release";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "crate-ci";
    repo = "cargo-release";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w+7kvJQBlb40W+vRAXmySOaL513501fj25PkWI8lQTw=";
  };

  cargoHash = "sha256-rU8HQBrK/0aRCz5hvUQCMxRCbP2N98S+0gvVNqkap7s=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ curl ];

  nativeCheckInputs = [ git ];

  checkFlags = [
    # Skip tests that require internet connection
    "--skip=publish::unpublished_git_dependency"
    "--skip=publish::unpublished_workspace_dependency"
  ];

  # disable vendored-libgit2 and vendored-openssl
  buildNoDefaultFeatures = true;

  meta = {
    description = ''Cargo subcommand "release": everything about releasing a rust crate'';
    mainProgram = "cargo-release";
    homepage = "https://github.com/crate-ci/cargo-release";
    changelog = "https://github.com/crate-ci/cargo-release/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
  };
})
