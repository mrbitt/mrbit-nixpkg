{stdenv, fetchurl, autoreconfHook, asciidoc, libxml2,
  libxslt, docbook_xsl, docbook_xml_dtd_44 }:

stdenv.mkDerivation rec {
  pname = "tinyproxy";
  version = "1.10.0";

  src = fetchurl {
    url = "https://github.com/tinyproxy/tinyproxy/releases/download/${version}/${pname}-${version}.tar.xz";
    sha256 = "10jnk6y2swld25mm47mjc0nkffyzsfysnsxwr7cs0ns1kil8ggjr";
  };
  buildInputs = [ autoreconfHook asciidoc libxml2 libxslt docbook_xsl ];

   configureFlags = [
    "--disable-debug"      # Turn off debugging
    "--enable-xtinyproxy"  # Compile in support for the XTinyproxy header, which is sent to any web server in your domain.
    "--enable-filter"      # Allows Tinyproxy to filter out certain domains and URLs.
    "--enable-upstream"    # Enable support for proxying connections through another proxy server.
    "--enable-transparent" # Allow Tinyproxy to be used as a transparent proxy daemon.
    "--enable-reverse"     # Enable reverse proxying.
  ] ++

  # See: https://github.com/tinyproxy/tinyproxy/issues/1
  stdenv.lib.optional stdenv.isDarwin "--disable-regexcheck";

  A2X_ARGS = "-d manpage -f manpage -L";

  postPatch = ''
    substituteInPlace Makefile.in \
      --replace @A2X@ "@A2X@ -L"
  '';

 meta = with stdenv.lib; {
    homepage = "https://tinyproxy.github.io/";
    description = "A light-weight HTTP/HTTPS proxy daemon for POSIX operating systems";
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = [ maintainers.carlosdagos ];
  };
}
