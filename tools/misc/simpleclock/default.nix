{ lib, stdenv, fetchgit, cmake, ncurses, pkg-config }:

stdenv.mkDerivation rec {
  pname = "simpleclock";
  version = "1";

  src = fetchgit {
     url = "https://git.ologantr.xyz/simple-clock";
    sha256 = "sha256-yOvwjx1sxrkGl8l2wPd2OsyTOLeBkXCPn9li9L46iac=";
  };

  
  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ ncurses ];

  makeFlags = [ "PREFIX=$(out)" ];
    
   installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
   # install -m 0775 simple-clock $out/bin/
    install simple-clock $out/bin/
    chmod +x $out/bin/simple-clock
    '';
    
  
  meta = with lib; {
    homepage = "https://git.ologantr.xyz/gitweb/";
    license = licenses.free;
    description = "Digital clock in ncurses";
    platforms = platforms.all;
    maintainers = [ ];
  };
}
