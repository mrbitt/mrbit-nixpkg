{lib, stdenv, fetchurl, makeWrapper, bash, vala, pkg-config, gtk3, libsoup, which, desktop-file-utils, diffutils, psmisc, cron, coreutils, util-linux, vte, json-glib, libgee, rsync }:

stdenv.mkDerivation rec {
  pname = "timeshift";
  version = "21.09.1";
  src = fetchurl {
    url = "https://github.com/teejee2008/${pname}/archive/v${version}.tar.gz";
    sha256 = "0pa5ghvrivpvz0vns407hf74qq8i1yc6nx2g4rh4ha4w8dai7ckh";
  };

    nativeBuildInputs = [ makeWrapper pkg-config vala diffutils coreutils vte];
    buildInputs = [ which makeWrapper gtk3 libgee json-glib ];
    dontConfigure = true;
    enableParallelBuilding = true;
     
  postPatch = '' substituteInPlace src/makefile --replace "SHELL=/bin/bash" "SHELL=${bash}/bin/bash" 
                 substituteInPlace src/makefile --replace '/usr/bin' '$(out)/bin'
                 substituteInPlace src/share/polkit-1/actions/in.teejeetech.pkexec.timeshift.policy --replace '/usr' $out'/' 
                 substituteInPlace src/Utility/Device.vala  --replace /sbin/blkid ${util-linux}/sbin/blkid 
                 substituteInPlace src/Core/Main.vala  --replace /sbin/blkid ${util-linux}/sbin/blkid  '';
                  
                  
   buildPhase = '' cd ./src
            make clean 
            make '';
            
   installFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "A system restore utility for Linux";
    license = licenses.gpl3;
    homepage = "https://github.com/teejee2008/timeshift";
    maintainers = [ ];
    platforms = platforms.linux;
 };
}
