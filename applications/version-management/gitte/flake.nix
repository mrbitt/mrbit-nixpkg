{
  description = "Flake per compilare Gitte con un compilatore Rust aggiornato";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Overlay ufficiale per avere sempre l'ultimo toolchain di Rust
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
      
      # Specifichiamo la versione di Rust stabile più recente fornita dall'overlay
      rustToolchain = pkgs.rust-bin.stable.latest.default;
      
      # Creiamo una piattaforma di build personalizzata che usa il nuovo compilatore
      customRustPlatform = pkgs.makeRustPlatform {
        cargo = rustToolchain;
        rustc = rustToolchain;
      };
    in {
      packages.${system}.default = pkgs.callPackage ./default.nix { 
        rustPlatform = customRustPlatform; 
      };
    };
}

