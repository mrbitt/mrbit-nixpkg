{
  lib,
  fetchurl,
  stdenv,
  gettext,
  pkg-config,
  glib,
  gtk2,
  libX11,
  libSM,
  libICE,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  which,
}:

stdenv.mkDerivation rec {
  name = "gkrellm-2.4.0";
  pname = "gkrellm";

  src = fetchurl {
    url = "http://gkrellm.srcbox.net/releases/${name}.tar.bz2";
    sha256 = "sha256-b4NmV2C5Nq1LVfkYKx7HYB+vOKDyXqHkvdyZZQiPAy0=";
  };

  # Forces modern GCC to accept legacy GTK signal callback pointer mismatches as warnings
  NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  nativeBuildInputs = [
    pkg-config
    which
    copyDesktopItems
    wrapGAppsHook3
  ];
  buildInputs = [
    gettext
    glib
    gtk2
    libX11
    libSM
    libICE
  ];

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
  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX=''"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "gkrellm";
      exec = "gkrellm";
      icon = "gkrellm";
      desktopName = "GKrellM";
      genericName = "System monitor";
      comment = "The GNU Krell Monitors";
      categories = [
        "System"
        "Monitor"
      ];
    })
  ];

  # postInstall = ''
  #
  #   mkdir -p $out/share/pixmaps
  #   cp src/${pname}.ico $out/share/pixmaps/${pname}.png
  # '';

  meta = {
    description = "Themeable process stack of system monitors";
    longDescription = ''
      GKrellM is a single process stack of system monitors which
      supports applying themes to match its appearance to your window
      manager, Gtk, or any other theme.
    '';

    homepage = "http://gkrellm.srcbox.net";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
