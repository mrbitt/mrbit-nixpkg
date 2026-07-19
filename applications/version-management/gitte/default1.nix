{ 
lib,
stdenv,
python3Packages,
fetchzip, 
meson, 
ninja, 
pkg-config, 
gtk4,
wrapGAppsHook4,
git,
desktop-file-utils,
libsecret,
vte,
json-glib,
libxml2,       # Fornisce xmllint per elaborare i file gresource XML
libadwaita,
rustPlatform,
cargo,
rustc,
}:

rustPlatform.buildRustPackage rec {
  pname = "gitte";
  version = "0.3.0";

  src = fetchzip {
    url = "https://codeberg.org/ckruse/Gitte/archive/${version}.tar.gz";
    # Se l'hash non corrisponde, Nix mostrerà l'hash corretto durante il build.
    # Sostituisci questo valore se necessario.
    hash = "sha256-3r+CTmdE8UiVOWzerBL/LPZWXrL50NrMHyKQMbYfKbo="; 
  };

 # Questo blocco scarica ed estrae offline i crate Rust prima di avviare Meson
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}-cargo-deps";
    hash = "sha256-Hfh4g3LJETaWxXJoy69Sa91z7PWzXb/Xd/a608NJMWg="; # Sostituisci con l'hash generato da Nix
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    libxml2
    wrapGAppsHook4 # Necessario per propagare gli schemi grafici GTK4
    # Hook e compilatori necessari per far funzionare il backend Rust di Meson
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    gtk4
    libadwaita
    vte # Gitte integra un terminale virtuale VTE
    python3Packages.pyflakes
    json-glib
    libsecret
    git
  ];

  postInstall = ''
    ronn --roff man/actionlint.1.ronn
    installManPage man/actionlint.1
    wrapProgram "$out/bin/gitte" \
      --prefix PATH : ${
        lib.makeBinPath [
          python3Packages.pyflakes
        ]
      }
  '';

  meta = with lib; {
    description = "Un client Git moderno basato su GTK4 e Libadwaita";
    homepage = "https://codeberg.org/ckruse/Gitte";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
