{ fetchgit, stdenv, pkgconfig, libtool, autoconf, libXrender
, curl, ncurses, cmake, zlib, glib, alsaLib, dbus, dbus_glib, gtk3, atk, libpthreadstubs, mesa_glu, gettext, libxml2, librsvg, libXdmcp, libxshmfence, libXtst, intltool }:

stdenv.mkDerivation rec {
  version = "3.4.1";
  name = "cairo-dock-core-${version}";

  src = fetchgit {
    url = "https://github.com/Cairo-Dock/cairo-dock-core.git";
    rev = "17edf3fe3fe263b5444daa918ea78fb4257f6631";
    sha256  = "1c7rqp7xxfhgp97bzbdjgfs4ysz3aw8ijwsdk11qdcr6ayh93xsc";
  };
  
  nativeBuildInputs = [ pkgconfig intltool libtool ];
  buildInputs = [
    curl cmake ncurses zlib glib alsaLib dbus dbus_glib gtk3 atk libXrender libpthreadstubs mesa_glu gettext libxml2 librsvg libXdmcp libxshmfence libXtst 
  ];
  
  configurePhase = ''
    cmake -DCMAKE_INSTALL_PREFIX=$out  '';

  NIX_LDFLAGS = "-lpthread";
  
  postPatch = ''
      sed "s|3.4.0|3.4.1|" -i CMakeLists.txt
        #substituteInPlace CMakeLists.txt --subst-var-by 3.4.0 3.4.1
   '';
  
  meta = with stdenv.lib; {
    description = "Cairo-Dock a desktop dock";
    longDescription= "Cairo-Dock is a desktop interface that takes the shape of docks, desklets, panel, etc";
    homepage = "http://glx-dock.org";
    license = licenses.gpl2;
    maintainers = [ maintainers.offline ];
    platforms = stdenv.lib.platforms.linux;
    hydraPlatforms = [];
  };
}