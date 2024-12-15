{stdenv, fetchurl, gkrellm, glib, pkg-config, gtk2, gdk-pixbuf}:

stdenv.mkDerivation rec {
  name = "alltraxclock";
  version = "2.0.2";
  src = fetchurl {
    url = "https://launchpad.net/debian/+archive/primary/+sourcefiles/${name}/${version}-2/${name}_${version}.orig.tar.gz";
    sha256 = "sha256-QW0fgpQXg72YIroy8IcWRicBAT7Q4Q1NBkDZ1OfRgY0=";
  };

    buildInputs = [ pkg-config gkrellm gtk2 glib gdk-pixbuf ];

    dontStrip = true;
    buildPhase = '' make clean
                    make '';

    installPhase = '' mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellaclock.sh}" "$out/bin/gkrellaclock"
                      chmod a+x "$out/bin/gkrellaclock"
                      substituteAll "${./gkrellaclockOFF.sh}" "$out/bin/gkrellaclockOFF"
                      chmod a+x "$out/bin/gkrellaclockOFF" '';
      postInstall = '' $out/bin/gkrellaclock '';
}
