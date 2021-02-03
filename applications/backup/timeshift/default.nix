{stdenv, fetchurl, makeWrapper, bash, vala, gtk3, libsoup, desktop-file-utils, diffutils, coreutils, vte, json-glib, libgee, rsync }:

stdenv.mkDerivation rec {
  pname = "timeshift";
  version = "20.03";
  src = fetchurl {
    url = "https://github.com/teejee2008/${pname}/archive/v${version}.tar.gz";
    sha256 = "14dk6n9v2xl0j5l66i29b41i17frhmp449gzj306jgpwh421a5k5";
  };

    nativeBuildInputs = [ vala diffutils coreutils vte];
    buildInputs = [ makeWrapper gtk3 ];
    dontConfigure = true;

  #makeFlags = [
   # "PREFIX=$(out)"
    #"ICONDIR=$(out)/share/pixmaps" ];

 # some hardcodeism
 patchPhase = ''
    for f in $(find src/ -type f); do
      substituteInPlace $f --replace "/bin/bash" "${bash}/bin/bash"
    done '';

  buildPhase = '' cd ./src
            make '';
  #postInstall = ''
  #  mkdir -p $out/share/pixmaps
  #  rmdir "$out/share/appdata"
  #  substituteInPlace "$out/share/applications/$pname.desktop" --replace "/usr/share/$pname/icons/" "" '';

  meta = with stdenv.lib; {
    description = "A system restore utility for Linux";
    license = licenses.gpl3;
    homepage = "https://github.com/teejee2008/timeshift";
    maintainers = [ ];
    platforms = platforms.linux;
 };
}
