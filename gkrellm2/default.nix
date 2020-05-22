{ fetchurl, stdenv, gettext, pkgconfig, glib, gtk2, libX11, libSM, libICE, makeDesktopItem, which
, IOKit ? null }:

let
  pname = "gkrellm";

  desktop = makeDesktopItem {
    desktopName = pname;
    name = pname;
    exec = "${pname}";
    icon = "${pname}";
    terminal = "False";
    comment = "Lightweight graphical system monitorsn using GTK";
    type = "Application";
    categories = "System;";
    genericName = pname;
  };
in
with stdenv.lib;

stdenv.mkDerivation rec {
  name = "gkrellm-2.3.11";

  src = fetchurl {
    url = "http://gkrellm.srcbox.net/releases/${name}.tar.bz2";
    sha256 = "01lccz4fga40isv09j8rjgr0qy10rff9vj042n6gi6gdv4z69q0y";
  };

  nativeBuildInputs = [ pkgconfig which ];
  buildInputs = [gettext glib gtk2 libX11 libSM libICE]
    ++ optionals stdenv.isDarwin [ IOKit ];

  hardeningDisable = [ "format" ];

  # Makefiles are patched to fix references to `/usr/X11R6' and to add
  # `-lX11' to make sure libX11's store path is in the RPATH.
  patchPhase = ''
    echo "patching makefiles..."
    for i in Makefile src/Makefile server/Makefile
    do
      sed -i "$i" -e "s|/usr/X11R6|${libX11.dev}|g ; s|-lICE|-lX11 -lICE|g"
    done
  '';

  makeFlags = [ "STRIP=-s" ];
  installFlags = [ "DESTDIR=$(out)" ];

  postInstall = ''
    mkdir -p "$out/share/applications"
    install -Dm644 ${desktop}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
    mkdir -p $out/share/pixmaps
    cp src/${pname}.ico $out/share/pixmaps/${pname}.png
  '';
  
  meta = {
    description = "Themeable process stack of system monitors";
    longDescription = ''
      GKrellM is a single process stack of system monitors which
      supports applying themes to match its appearance to your window
      manager, Gtk, or any other theme.
    '';

    homepage = "http://gkrellm.srcbox.net";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
