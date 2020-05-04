{stdenv, fetchurl, pkgconfig, makeWrapper, gsettings-desktop-schemas, gtk3 }:

stdenv.mkDerivation rec {
  pname = "ukopp2";
  name = "${pname}-${version}";
  version = "1.2";
  src = fetchurl {
    url = "http://www.kornelix.net/downloads/downloads/${pname}-${version}.tar.gz";
    sha256 = "1id6yv356cqj38xpkh744kwkj8i7kn5fa9g7lgj82d7jrqbpmxnq";
  };

    nativeBuildInputs = [ pkgconfig makeWrapper ];
    buildInputs = [ gtk3 gsettings-desktop-schemas ];
    dontConfigure = true;

  makeFlags = [
    "PREFIX=$(out)"
    "ICONDIR=$(out)/share/pixmaps" ];

  postInstall = ''
    mkdir -p $out/share/pixmaps
    rmdir "$out/share/appdata"
    substituteInPlace "$out/share/applications/$pname.desktop" --replace "/usr/share/$pname/icons/" "" '';

         #fix: No GSettings schemas are installed on the system
    preFixup = ''
    wrapProgram "$out/bin/$pname" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" '';

 meta = with stdenv.lib; {
    description = "A backup program for USB devices";
    license = licenses.gpl3;
    homepage = "http://www.kornelix.net/ukopp/ukopp.html";
    maintainers = [ ];
    platforms = platforms.linux;
 };
}
