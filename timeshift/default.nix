{stdenv, fetchurl, pkgconfig, gtk3 }:

stdenv.mkDerivation rec {
  pname = "ukopp2";
  version = "1.2";
  src = fetchurl {
    url = "http://www.kornelix.net/downloads/downloads/${pname}-${version}.tar.gz";
    sha256 = "1id6yv356cqj38xpkh744kwkj8i7kn5fa9g7lgj82d7jrqbpmxnq";
  };

    nativeBuildInputs = [ pkgconfig ];
    buildInputs = [ gtk3 ];
    dontConfigure = true;

  makeFlags = [
    "PREFIX=$(out)"
    "ICONDIR=$(out)/share/pixmaps" ];

  postInstall = ''
    mkdir -p $out/share/pixmaps
    rmdir "$out/share/appdata"
    substituteInPlace "$out/share/applications/$pname.desktop" --replace "/usr/share/$pname/icons/" "" '';

  meta = with stdenv.lib; {
    description = "A backup program for USB devices";
    license = licenses.gpl3;
    homepage = "http://www.kornelix.net/ukopp/ukopp.html";
    maintainers = [ ];
    platforms = platforms.linux;
 };
}
