{ lib
, stdenv
, fetchzip
, copyDesktopItems
, makeDesktopItem
, tcl
, tk
}:

stdenv.mkDerivation rec {
  version = "5.4";
  pname = "tkdiff";
  src = fetchzip {
     url = "https://downloads.sourceforge.net/project/tkdiff/tkdiff/5.4/${pname}-5-4.zip";
     sha256 = "0d1mqs4rrh19c62kgj7k133zsn88clah35v4wp1hmimfcwcqd8pr";
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
