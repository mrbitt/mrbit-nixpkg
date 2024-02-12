{ lib
, stdenv
, fetchurl
, wafHook
, python3
, pkg-config
, freetype
, libglvnd
, libXmu
, fontmiscmisc
}:

stdenv.mkDerivation rec {
  pname = "zutty";
  version = "0.15";

  src = fetchurl {
    url = "https://git.hq.sig7.se/zutty.git/snapshot/7e481c04507e9b5cacfe67fe2b96bdb449b08726.tar.gz";
    hash = "sha256-Ze94lkdt6DopGDoWvMS9LC6SIYtM0IF/XZiowf3R5R4=";
  };

  nativeBuildInputs = [
    wafHook
    python3
    pkg-config
  ];

  buildInputs = [
    freetype
    libglvnd
    libXmu
  ];

  postPatch = ''
    substituteInPlace src/options.h \
      --replace '/usr/share/fonts' '${fontmiscmisc}/lib/X11/fonts/misc'
  '';

  postInstall = ''
    install -Dm644 -t $out/share/doc/${pname} doc/*
    install -Dm644 "./icons/zutty.desktop" -t $out/share/applications/zutty.desktop
    install -Dm644 "./icons/zutty.svg" -t $out/share/icons/hicolor/scalable/apps/zutty.svg
        for res in 16x16 32x32 48x48 64x64 96x96 128x128; 
         do  
        install -Dm644 "./icons/zutty_$res.png" -t $out/share/icons/hicolor/$res/apps/zutty.png
      done
  '';

  meta = with lib; {
    homepage = "https://tomscii.sig7.se/zutty/";
    description = "A high-end terminal for low-end systems";
    longDescription = ''
      Zutty is a terminal emulator for the X Window System, functionally
      similar to several other X terminal emulators such as xterm, rxvt and
      countless others. It is also similar to other, much more modern,
      GPU-accelerated terminal emulators such as Alacritty and Kitty. What
      really sets Zutty apart is its radically simple, yet extremely efficient
      rendering implementation, coupled with a sufficiently complete feature
      set to make it useful for a wide range of users. Zutty offers high
      throughput with low latency, and strives to conform to relevant
      (published or de-facto) standards.
    '';
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ gravndal ];
    platforms = platforms.linux;
  };
}
