{stdenv, fetchurl, gkrellm, glib, pkgconfig, gtk2 }:

stdenv.mkDerivation rec {
  name = "gkrellaclock-0.3.4";
  src = fetchurl {
    url = "http://oborlinux.free.fr/arch/${name}.tar.gz";
    sha256 = "5923c5fa6c31ceb1944e57219d893634e503d44dc5e91f3deba46f0d71e787b7";
  };
  
    patches = [./gkrellaclock-makefile.patch];
    
    buildInputs = [ pkgconfig gkrellm gtk2 glib ];

    buildPhase = '' make clean
                    make '';

    installPhase = '' mkdir -p $out/usr/local/lib/gkrellm2/plugins
                      cp *.so $out/usr/local/lib/gkrellm2/plugins '';
}
