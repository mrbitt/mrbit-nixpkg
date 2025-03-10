{ lib, stdenv, fetchurl, pkg-config, autoconf, glib, gtk3, copyDesktopItems, makeDesktopItem }:


stdenv.mkDerivation rec {
  pname = "gentoo";
  version = "0.20.7";

  src = fetchurl {
    url = "http://downloads.sourceforge.net/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1amiibrarywi92r3v469jqjl7pfqbc897868812pwbwsa0ws2l4s";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "gentoo";
      desktopName = "Gentoo";
      exec = "gentoo";
      comment = "Lightweight graphical file manager for Unix-like systems, using GTK3";
      icon = "gentoo";
      categories = [ "FileTools" "FileManager"
        "System"
        "Emulator"
      ];
    })
  ];
  
    
  Patches = ''
    substituteInPlace configure.ac --replace "GTK_DISABLE_DEPRECATED" ""
    '';
  postPatch = '' sed -i -e 's^/gentoo/16x16^/gentoo^' gentoorc.in || die
                 sed -i -e 's^/gnome/16x16/mimetypes^/gentoo^' gentoorc.in || die
                 sed -i -e 's^/usr/share/icons^'$out'/share/gentoo^' gentoorc.in || die
                 sed -i -e 's^DirEnter &apos;dir=/usr/local^'$out'/share^' gentoorc.in || die '';
 
  
  nativeBuildInputs = [ copyDesktopItems autoconf pkg-config ];
  buildInputs = [ glib gtk3 ];

  postInstall = ''
    mkdir -p $out/share/icons/gentoo
    cp -r icons/* $out/share/icons/gentoo/
    rm -fr $out/share/gentoo

    mkdir -p "$out/share/doc/gentoo"
    cp -r docs/* $out/share/doc/gentoo/

    mkdir -p "$out/share/applications"
    
    mkdir -p $out/share/pixmaps
    cp $out/share/icons/gentoo/${pname}.png $out/share/pixmaps/${pname}.png
  '';

 meta = with lib; {
    description = "Graphical file manager for Unix-like systems, using GTK+";
    homepage = "https://sourceforge.net/projects/gentoo";
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
