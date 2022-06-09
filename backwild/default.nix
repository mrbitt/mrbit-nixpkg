{stdenv, lib, fetchurl, pkgconfig, json-glib, cogl, clutter, clutter-gtk, gtk3 }:

let 
    libpath = lib.makeLibraryPath [ clutter-gtk.dev ];
in

stdenv.mkDerivation rec {
  pname = "backwild";
  name = "${pname}-${version}";
  version = "2.4";
  src = fetchurl {
    url = "http://www.kornelix.net/downloads/downloads/${pname}-${version}.tar.gz";
    sha256 = "knqPkQWednpak1mWlaQ8Xr7ipuevasEPV3PKXZjk9AE=";
  };

    nativeBuildInputs = [ pkgconfig ];
    buildInputs = [ gtk3 json-glib cogl clutter clutter-gtk ];
    dontConfigure = true;

 patchPhase = ''
   sed -i -e "s|/usr/include/clutter-gtk-1.0/ |${clutter-gtk.dev}/include/clutter-gtk-1.0|g" Makefile;
   sed -i -e "s|/usr/include/clutter|${clutter.dev}/include/clutter|g" Makefile;
   sed -i -e "s|/usr/include/cogl|${cogl.dev}/include/cogl|g" Makefile;
   sed -i -e "s|/usr/include/json-glib|${json-glib.dev}/include/json-glib|g" Makefile;
  '';

  makeFlags = [
    "PREFIX=$(out)"
    "ICONDIR=$(out)/share/pixmaps" ];

  postInstall = ''
    mkdir -p $out/share/pixmaps
    substituteInPlace "$out/share/applications/$pname.desktop" --replace "/usr/share/$pname/icons/" "" '';

meta = with lib; {
    description = "A backup program for USB devices";
    license = licenses.gpl3;
    homepage = "http://www.kornelix.net/ukopp/ukopp.html";
    maintainers = [ ];
    platforms = platforms.linux;
 };
}
