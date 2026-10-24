{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  python3,
  pkg-config,
  gtk4,
  appstream,
  desktop-file-utils,
  glib,
  libadwaita,
  wrapGAppsHook4,
  gobject-introspection,
  makeWrapper,
  libxml2, # Fornisce xmllint
   _7zz,
  cmake,
  meson,
  ninja,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "akizip";
  version = "0.4.2";

 format = "other"; # Indica a Nix di non cercare un setup.py

  src = fetchFromGitHub {
    owner = "AkiZip";
    repo = "AkiZip";
    rev = "${version}";
    hash = "sha256-pClocrWk/pTwmpaEHv/Zfg6e9CkrD9Bx5/fTJGUDDlE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    libxml2
    python3.pkgs.wrapPython 
    (python3.withPackages (ps: with ps; [ pygobject3 ]))  #Fornisce il modulo 'gi'
    cmake
    pkg-config
    glib
    wrapGAppsHook4
    makeWrapper
    gobject-introspection
    appstream  # for appstreamcli
    desktop-file-utils # for desktop-file-validate
    gettext # msgfmt
  ];

   buildInputs = [
    python3
    python3.pkgs.pygobject3
    gtk4
    libadwaita
  ];

  # Sostituisce il percorso hardcoded /app/bin/7zz con quello reale in Nix
  postPatch = ''
      find . -name "*.py" -exec sed -i 's|/app/bin/7zz|${_7zz}/bin/7zz|g' {} +
  '';
  
   propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];
 
  # Forza il collegamento tra il wrapper GNOME e quello Python
   makeWrapperArgs = [
     "--prefix GI_TYPELIB_PATH : \"$GI_TYPELIB_PATH\""
  ];

  meta = {
    description = "";
    homepage = "https://github.com/AkiZip/AkiZip";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aki-zip";
    platforms = lib.platforms.all;
  };
}
