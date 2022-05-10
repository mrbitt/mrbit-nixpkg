{stdenv, fetchurl, gkrellm, glib, gtk2, libX11, libXtst, pkgconfig, imlib2, }:

stdenv.mkDerivation rec {
  pname = "wmhdplop";
  version = "0.9.11";
  src = fetchurl {
    url = "https://www.dockapps.net/download/${pname}-${version}.tar.gz";
    sha256 = "1dsm870rglgsqh2wg5k7hqxykjnx36wrakxfnzm7npjzpwmhsagq";
  };

       # patches = [./wmhdplop-0.9.10-sysmacros.patch];
       #  patches = [./wmhdplop-0.9.10-cflags.patch];

    buildInputs = [ pkgconfig gkrellm glib gtk2 libX11 libXtst imlib2];
    configureFlags = [ "--libdir=$(out)/gkrellm2/plugins" ];
    
    postPatch = '' sed -e '/gkhdplop_so_LDFLAGS/s, -Wl , ,' -i Makefile.in '';


    installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellm-hdplop.sh}" "$out/bin/gkhdplop"
                      chmod a+x "$out/bin/gkhdplop"
                      substituteAll "${./gkrellm-hdplopOFF.sh}" "$out/bin/gkrellm-hdplopOFF"
                      chmod a+x "$out/bin/gkrellm-hdplopOFF"
                      strip --strip-all $out/gkrellm2/plugins/*.so '';
}
