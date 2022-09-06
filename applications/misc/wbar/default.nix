{ fetchurl, stdenv, pkgconfig, libintl, autoreconfHook, libtool, imlib2, gtk2, gettext, glib, libX11, gnome2, freetype, gdk-pixbuf, intltool }:

stdenv.mkDerivation rec {
  version = "2.3.4";
  name = "wbar-${version}";
  pname = "wbar";
		
  src = fetchurl {
    url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/wbar/${name}.tgz";
    sha256  = "1qwkgbwnfzr0j0xpgrrpq99mml10nna2ryswzfp2jra3wi4ri9j6";
  };
  
  patches = [ ./wbar-2.3.4-c++11.patch ./wbar-2.3.4-gtk.patch ./wbar-2.3.3-nowerror.patch ./wbar-2.3.4-automake-1.13.patch ./wbar-2.3.4-completion.patch ];
	
  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ gtk2 gettext imlib2 glib gnome2.libglade freetype gdk-pixbuf libX11 intltool libtool libintl ];
  
	postPatch = ''
    # Hard-coded root paths, hard-coded root paths everywhere...
    for file in {src,share,pixmaps,etc,doc}/Makefile.in; do
      substituteInPlace $file \
        --replace "@DATADIRNAME@" "/share" \
        --replace "DESTDIR" "out" \
        --replace "/usr" "$out"
    done
		#sed "s|@DATADIRNAME@|@datadir@|" -i Makefile.in
		#sed "s|@DATADIRNAME@|@datadir@|" -i share/Makefile.in
		#sed "s|@DATADIRNAME@|@datadir@|" -i src/Makefile.in
		#sed "s|@DATADIRNAME@|@datadir@|" -i pixmaps/Makefile.in
		#sed "s|@DATADIRNAME@|$(out)/share|" -i etc/Makefile.in
		sed "s|@DATADIRNAME@|$(out)/share|" -i po/Makefile.in.in
		'';
	
	installFlags = [ "PREFIX=$(out)" "DESTDIR=$(out)"  "datadir=\${out}/share" ];

	
  meta = with stdenv.lib; {
    description = "A fast, lightweight quick launch bar";
    longDescription= "Cairo-Dock is a desktop interface that takes the shape of docks, desklets, panel, etc";
    homepage = "https://github.com/rodolf0/wbar";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = stdenv.lib.platforms.linux;
   };
}