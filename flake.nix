{
  description = "Prebuilt uniffi-bindgen-go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
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

          xz -dc "$src" > $out/bin/uniffi-bindgen-go
          chmod +x $out/bin/uniffi-bindgen-go

          runHook postInstall
        '';
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/uniffi-bindgen-go";
      };
    };
}
