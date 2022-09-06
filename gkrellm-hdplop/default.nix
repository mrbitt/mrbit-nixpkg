{lib, stdenv, fetchurl, gkrellm, glib, gtk2, libX11, libXtst, pkg-config, imlib2 }:

stdenv.mkDerivation rec {
  pname = "wmhdplop";
  version = "0.9.12";
  src = fetchurl {
    url = "https://www.dockapps.net/download/${pname}-${version}.tar.gz";
    sha256 = "sha256-ZgYx6ObIm3FXovSFJYrQ0yOhSPm0pwSQObl7xEIL25o=";
  };
       # patches = [./wmhdplop-0.9.10-sysmacros.patch];
       # patches = [./wmhdplop-0.9.10-cflags.patch];
    
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ imlib2 gkrellm glib gtk2 libX11 libXtst ];
   
   #configureFlags = [ "--prefix=${placeholder "out"}" "--libdir=$(out)/gkrellm2/plugins" "--enable-gkrellm" ];
    
   #postPatch = '' sed -e '/gkhdplop_so_LDFLAGS/s, -Wl , ,' -i Makefile.in '';


    installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellm-hdplop.sh}" "$out/bin/gkhdplop"
                      chmod a+x "$out/bin/gkhdplop"
                      substituteAll "${./gkrellm-hdplopOFF.sh}" "$out/bin/gkrellm-hdplopOFF"
                      chmod a+x "$out/bin/gkrellm-hdplopOFF"
                      strip --strip-all $out/gkrellm2/plugins/*.so '';

 enableParallelBuilding = true;
  
 meta = with lib; {
    description = "Monitors your hard drives and displays visual information about their activity (read, write, swapin, swapout), 
                     and optionally (if hddtemp is running as a daemon), displays their temperature/status. ";
    homepage = "https://www.dockapps.net/wmhdplop";
    maintainers = [  ];
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
