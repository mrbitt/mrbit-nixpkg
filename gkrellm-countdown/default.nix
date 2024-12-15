{stdenv, fetchurl, gkrellm, glib, pkg-config, gtk2 }:

stdenv.mkDerivation rec {
  pname = "gkrellm-countdown";
  version = "0.1.2";
  src = fetchurl {
    url = "https://slackware.uk/people/alphageek/slackware-10.2/source/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1lixxxrikv60bd9zvz9cn3npbmglrd043jmv5f5w9siv7iyffpmh";
};

#patches = [./gkrellmoon-0.6-makefile.patch];

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gkrellm gtk2 glib ];
    dontConfigure = true;
    buildPhase = '' make clean
                    make'';
    installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellcount.sh}" "$out/bin/gkrellcount"
                      chmod a+x "$out/bin/gkrellcount"
                      substituteAll "${./gkrellcountOFF.sh}" "$out/bin/gkrellcountOFF"
                      chmod a+x "$out/bin/gkrellcountOFF"
                      strip --strip-unneeded $out/gkrellm2/plugins/*.so '';
      postInstall = '' $out/bin/gkrellcount '';
}
