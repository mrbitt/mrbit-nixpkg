{ lib, stdenv, fetchurl, qtbase, qttools, qtdeclarative, pkg-config, makeWrapper, lsb-release, qtquickcontrols, qmake, qt5, mkDerivation , ffmpeg-full, sox ,libnotify ,mplayer }:

mkDerivation  rec{
  pname = "qwinff";
  version = "0.2.1";

   src = fetchurl {
    url = "http://sourceforge.net/projects/qwinff/files/release/v0.2.1/qwinff_0.2.1.tar.bz2";
    sha256 = "0x9r2713x63kmqx7y6312rpil7wlynzq0rnglgyzkid0haj2jf2s";
   };
   
  # prePatch ='' substituteInPlace ./qwinff-0.2.1-src_ui_mainwindow.patch --replace  '/usr/' $out'/'
  #              substituteInPlace ./qwinff-0.2.1-src_main.patch --replace  '/usr/' $out'/'
  #    '';
  #patches = [./qwinff-0.2.1-src_main.patch
  #			./qwinff-0.2.1-src_ui_mainwindow.patch ];
  
  makeFlags = [
              # author do not use configure and prefix directly using $prefix
              "prefix=$(out)"
              "DATA_PATH=$(prefix)/share/${pname}"
            ]; 
            
  nativeBuildInputs = [ qmake pkg-config makeWrapper lsb-release ];
  buildInputs = [ qtbase qttools qtquickcontrols qtdeclarative sox ffmpeg-full libnotify mplayer ];
    dontConfigure = true;
    enableParallelBuilding = true;
  postPatch = '' #substituteInPlace Makefile --replace 'DATA_PATH' '$(out)/bin'
                 substituteInPlace Makefile --replace '/usr' $out'/' 
                 substituteInPlace src/main.cpp --replace '/usr' $out'/' 
                 '';  
 
   buildPhase = '' #cd ./src
           # make clean 
            make  '';
     
 meta = with lib;{
    description = "A Qt4/5 GUI frontend for ffmpeg";
    homepage = "http://qwinff.github.io/downloads.html";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
