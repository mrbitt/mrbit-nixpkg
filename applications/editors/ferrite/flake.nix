{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        craneLib = crane.mkLib pkgs;

        # Dipendenze comuni (per build e runtime)
        commonArgs = {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;

          nativeBuildInputs = with pkgs; [ 
            pkg-config 
            makeWrapper 
          ];

          buildInputs = with pkgs; [
            libwayland
            libxkbcommon
            libGL
          ];
        };

        # 1. Compila solo le dipendenze (Cached)
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        # 2. Compila il pacchetto reale usando gli artefatti sopra
        ferrite = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;

          postInstall = ''
            wrapProgram $out/bin/ferrite \
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath commonArgs.buildInputs}"
          '';
        });

      in {
        packages.default = ferrite;
        
        devShells.default = pkgs.mkShell {
          inputsFrom = [ ferrite ];
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath commonArgs.buildInputs}"
            echo "Ambiente di sviluppo Ferrite pronto!"
          '';
        };
      }
    );
}
