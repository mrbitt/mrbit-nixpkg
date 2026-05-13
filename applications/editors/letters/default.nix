{ 
lib, 
python3, 
fetchzip, 
meson, 
ninja, 
pkg-config, 
gtk4,
wrapGAppsHook4,
gobject-introspection,
appstream,
desktop-file-utils,
blueprint-compiler,
webkitgtk_6_0,
pandoc,
libadwaita 
}:

python3.pkgs.buildPythonApplication rec {
  pname = "letters";
  version = "0.2.0";

   format = "other"; # Indica a Nix di non cercare un setup.py

  src = fetchzip {
    url = "https://codeberg.org/eyekay/letters/archive/${version}.tar.gz";
    sha256 = "sha256-hgGAUjX9Fh4PKDpeS6ydimZHIXhtEaD87WvI76RpQ/0=";
  };

  nativeBuildInputs = [ meson ninja pkg-config wrapGAppsHook4 gobject-introspection desktop-file-utils appstream blueprint-compiler ];
  buildInputs = [ gtk4 libadwaita webkitgtk_6_0 pandoc ];
  propagatedBuildInputs = with python3.pkgs; [ pygobject3 pypandoc weasyprint ]; # Aggiungi dipendenze python se necessarie

  meta = with lib; {
    description = "Un'applicazione per scrivere lettere e documenti";
    homepage = "https://codeberg.org";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
