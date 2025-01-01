{ lib
, stdenv
, fetchzip
, copyDesktopItems
, makeDesktopItem
, tcl
, tk
}:

stdenv.mkDerivation rec {
   version = "5.7";
   pname = "tkdiff";
  src = fetchzip {
     url = "https://downloads.sourceforge.net/project/tkdiff/tkdiff/${version}/${pname}-${lib.replaceStrings [ "." ] [ "-" ] version}.zip";
     sha256 = "sha256-ZndpolvaXoCAzR4KF+Bu7DJrXyB/C2H2lWp5FyzOc4M=";
  };

  dontConfigure = true;
  dontBuild = true;

nativeBuildInputs = [ copyDesktopItems ];

installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/pixmaps
    cp tkdiff $out/bin
    chmod +x $out/bin/tkdiff
     install -Dm644 "${./tkdiff.png}" "$out/share/pixmaps/tkdiff.png"
  runHook postInstall
      '';

 desktopItems = [ (makeDesktopItem {
    name = "tkdiff";
    exec = "tkdiff";
    icon = "tkdiff";
    desktopName = "tkdiff";
    comment     = meta.description;
    categories  = [ "Development" ];
  }) ];

 meta = with lib; {
    description = "A graphical front end to the diff program";
    homepage    = "http://tkdiff.sourceforge.net/";
    platforms   = platforms.all;
    license     = with licenses; [
      bsd2 # tix
      gpl2 # patches from portage
    ];
  };
}
