{lib, stdenv, fetchurl, itstool, wrapGAppsHook, gnome, gettext, libgcrypt, gtk3, nettle, libb2, librsvg, dconf, glib, intltool ,xdg-utils ,automake ,autoconf ,libtool ,pkg-config }:

stdenv.mkDerivation rec {
  pname = "gtkhash";
  version = "1.4";

  src = fetchurl {
    url = "https://github.com/tristanheaven/gtkhash/releases/download/v1.4/${pname}-${version}.tar.xz";
    sha256 = "1i1pvi51x6540arsg7az5i13lq202shi3hbkylip6vbciyxpvd90";
  };
  
  patchPhase = ''
    substituteInPlace configure.ac \
      --replace -Wformat=0 ""
  '';

  nativeBuildInputs = [ pkg-config autoconf automake libtool
    
    intltool
    itstool
    gettext 
    wrapGAppsHook
  ];
  
  
  buildInputs = [ gnome.nautilus automake  nettle libb2 intltool libgcrypt glib gtk3 (lib.getLib dconf) ];
  
   enableParallelBuilding = true;
  
 
  
  
   configureFlags = [
    #"--disable-debug"       # Turn off debugging
    "--disable-schemas-compile"
    "--enable-gtkhash"      # Compile in support for the XTinyproxy header, which is sent to any web server in your domain.
    "--enable-linux-crypto" # Allows Tinyproxy to filter out certain domains and URLs.
    "--enable-nettle"       # Enable support for proxying connections through another proxy server.
    "--enable-blake2"       # Allow Tinyproxy to be used as a transparent proxy daemon.
    "--enable-mhash"
    "--enable-nautilus"
    "--with-gtk=3.0"        # Enable reverse proxying.
  ] ;

   PKG_CONFIG_LIBNAUTILUS_EXTENSION_EXTENSIONDIR = "${placeholder "out"}/lib/nautilus/extensions-3.0";
    
 meta = with lib; {
    homepage = "https://github.com/tristanheaven/gtkhash";
    description = "A GTK+ utility for computing message digests or checksums";
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = [ maintainers.mrbitt ];
  };
}
