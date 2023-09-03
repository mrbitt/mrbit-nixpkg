{ lib, stdenv, fetchurl, tcl, tk, copyDesktopItems, makeDesktopItem  }:

stdenv.mkDerivation rec {
  pname = "tkrev";
  version = "9.4.5";

  src = fetchurl {
    url = "mirror://sourceforge/tkcvs/tkrev_${version}.tar.gz";
    sha256 = "sha256-jMlrik3WNef4L4YIpiM9469Xi5mcw/CMBv/iRQZGsuk=";
  };

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [ tcl tk ];

  patchPhase = ''
    for file in tkrev/tkrev.tcl tkdiff/tkdiff; do
        substituteInPlace "$file" \
            --replace "exec wish" "exec ${tk}/bin/wish"
    done
  '';

  installPhase = ''
    runHook preInstall
    ./doinstall.tcl $out
      mkdir -p $out/share/applications $out/share/pixmaps
      install -Dvm444 "tkdiff/Delta.ico" "$out/share/pixmaps/tkdiff.png"
      install -Dvm444 "tkrev/bitmaps/TkRev_128.gif" "$out/share/pixmaps/tkrev.png"
     runHook postInstall
    '';

  desktopItems = [ (makeDesktopItem {
    name = "tkdiff";
    exec = "tkdiff";
    icon = "tkdiff";
    desktopName = "tkdiff";
    comment     = meta.description;
    categories  = [ "Development" ];
  }) 
                 (makeDesktopItem {
    name = "tkrev";
    exec = "tkrev";
    icon = "tkrev";
    desktopName = "tkrev";
    comment     = meta.description;
    categories  = [ "Development" ];
  })
      ];

  meta = {
    homepage = "https://tkcvs.sourceforge.io";
    description = "TCL/TK GUI for cvs and subversion";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
}
