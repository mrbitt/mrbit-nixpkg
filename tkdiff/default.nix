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

installPhase = ''
    mkdir -p $out/bin
    cp tkdiff $out/bin
    chmod +x $out/bin/tkdiff
      '';

# desktopItems = [
#    (makeDesktopItem {
#      name = "tkdiff";
#      exec = "tkdiff";
#      desktopName = "tkdiff";
#      genericName = "Generic diff program";
#      comment =  meta.description;
#      categories = [ "Development" ];
#    })
#  ];


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
