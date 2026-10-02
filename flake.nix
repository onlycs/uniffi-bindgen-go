{
  description = "Prebuilt uniffi-bindgen-go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "uniffi-bindgen-go";
          version = "0.7.1+v0.31.0";

          src = pkgs.fetchurl {
            url = "https://codeberg.org/tendulkar/uniffi-bindgen-go/releases/download/v0.7.1+v0.31.0/uniffi-bindgen-go.xz";
            hash = "sha256-i51UwKRVxoAT7eDwvo2WihKlxXk96igAjvO2Rx6Dys8=";
          };

          nativeBuildInputs = [ pkgs.xz ];
          dontUnpack = true;

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin

            xz -dc "$src" > "$out/bin/uniffi-bindgen-go"
            chmod +x "$out/bin/uniffi-bindgen-go"

            runHook postInstall
          '';
        };

        packages.fromSource = pkgs.rustPlatform.buildRustPackage {
          pname = "uniffi-bindgen-go";
          version = "0.7.1+v0.31.0";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          nativeBuildInputs = with pkgs; [ pkg-config ];

          buildInputs = [ ];

          cargoBuildFlags = [
            "--package"
            "uniffi-bindgen-go"
          ];

          cargoTestFlags = [
            "--package"
            "uniffi-bindgen-go"
          ];
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/uniffi-bindgen-go";
        };

        apps.fromSource = {
          type = "app";
          program = "${self.packages.${system}.fromSource}/bin/uniffi-bindgen-go";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            toolchain

            go
            gopls

            pkg-config
            gcc

            nil
            nixd
          ];

          RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
        };
      }
    );
}
