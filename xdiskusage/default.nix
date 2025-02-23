{stdenv, lib, fetchgit, fltk13, autoconf}:

stdenv.mkDerivation {
  name = "xdiskusage-1.60";

  src = fetchgit {
    url = "git://git.code.sf.net/p/xdiskusage/git";
    rev = "d8b99e5c4026125f3d31c90a83ebf180f559a036";
    sha256 = "sha256-mQaD/yu0vgpFluzKhT9JbkF2L2lSOgrkFK2vGl1J0Lo=";
  };
 
  preConfigure = ''
    autoconf
  '';
  dontConfigure = true;
  configureFlags = [ "--prefix=${placeholder "out"}"];
  buildInputs = [ fltk13 autoconf  ];

   makeFlags = [
    "PREFIX=$(out)"
    "ICONDIR=$(out)/share/pixmaps" ];
  
 meta = with lib; {
    description = "user-friendly program to show you what is using up all your disk space";
    homepage = "http://xdiskusage.sourceforge.net/";
    license = licenses.gpl2; 
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
