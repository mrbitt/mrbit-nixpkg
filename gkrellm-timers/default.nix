{lib, stdenv, fetchFromGitHub, gkrellm, glib, gtk2-x11, pkg-config, imlib2, libX11, atk, pango }:

stdenv.mkDerivation rec {
  pname = "gkrellm_timers";
  version = "1.3";
  src = fetchFromGitHub {
    owner = "zuckschwerdt";
    repo = "gkrellm-timers";
    rev = version;
    hash = "sha256-3CbdNMR6VN5c8wUgCCNbmCs4nwIFWr+lgWPk2N5nvrw=";
  };
  
    preBuild = ''
    #substituteInPlace Makefile --replace "imlib-config" "pkg-config"
    #substituteInPlace Makefile --replace "gtk-config" "pkg-config"
    #substituteInPlace Makefile --replace "--cflags-gdk" "--cflags imlib2"
    #substituteInPlace Makefile --replace "--libs-gdk" "--libs imlib2"
    #substituteInPlace Makefile --replace "--cflags" "--cflags gtk+-x11-2.0"
    #substituteInPlace Makefile --replace "--libs" "--libs gtk+-x11-2.0" 
    #substituteInPlace gkrellm_timers.c --replace "<gkrellm/gkrellm.h>" "<gkrellm2/gkrellm.h>"
   substituteInPlace Makefile --replace-fail -I/usr/local/include -I/$out/include
    substituteAllInPlace Makefile --replace-fail 'usr' $out
  '';
   
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ imlib2 gkrellm glib gtk2-x11 libX11 atk pango ];
   
      makeFlags = [
		"prefix=${placeholder "out"}"
		#"CFLAGS=-enable_nls=1"
		];
  
      installPhase = ''
                      mkdir -p $out/gkrellm2/plugins/ $out/bin
                      cp *.so $out/gkrellm2/plugins/
                      substituteAll "${./gkrellm-timers.sh}" "$out/bin/timers"
                      chmod a+x "$out/bin/timers"
                      substituteAll "${./gkrellm-timersOFF.sh}" "$out/bin/gkrellm-timersOFF"
                      chmod a+x "$out/bin/gkrellm-timersOFF"
                      strip --strip-all $out/gkrellm2/plugins/*.so '';

 enableParallelBuilding = true;
  
 meta = {
    description = "Timer and Stopwatch plugin for the GKrellM stack";
    homepage = "https://github.com/zuckschwerdt/gkrellm-timers";
    changelog = "https://github.com/zuckschwerdt/gkrellm-timers/blob/${src.rev}/ChangeLog";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gkrellm-timers";
    platforms = lib.platforms.all;
  };
}
