{ lib
, stdenv
, fetchurl
, gtk3
, pcre
, glib
, desktop-file-utils
, meson
, cmake
, ninja
, appstream
, pkg-config
, wrapGAppsHook
, unstableGitUpdater
, gettext
}:

stdenv.mkDerivation {
  pname = "fsearch";
  version = "0.2.2";

  src = fetchurl {
    url = "https://github.com/cboxdoerfer/fsearch/archive/refs/tags/0.2.2.tar.gz";
    #owner = "cboxdoerfer";
    #repo = "fsearch";
    #rev = "06e99b900f96a235fdfbc5ca0ddcbc0ee592faac";
    sha256 = "sha256-yY1zAAQ2xxgqhsMymPc5DIK854VLgkyAl4rMCA2XlEU=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    cmake
    ninja
    pkg-config
    wrapGAppsHook
    gettext
  ];

  buildInputs = [
    glib
    gtk3
    pcre
    appstream
  ];

  preFixup = ''
    substituteInPlace $out/share/applications/io.github.cboxdoerfer.FSearch.desktop \
      --replace "Exec=fsearch" "Exec=$out/bin/fsearch"
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/cboxdoerfer/fsearch.git";
  };

  meta = with lib; {
    description = "A fast file search utility for Unix-like systems based on GTK+3";
    homepage = "https://github.com/cboxdoerfer/fsearch.git";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ artturin ];
    platforms = platforms.unix;
    mainProgram = "fsearch";
    broken = stdenv.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/fsearch.x86_64-darwin
  };
}
