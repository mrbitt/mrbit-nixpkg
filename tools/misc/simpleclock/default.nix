{ lib, stdenv, fetchgit, cmake, ncurses, pkg-config }:

stdenv.mkDerivation rec {
  pname = "simpleclock";
  version = "1";

  src = fetchgit {
     url = "https://git.ologantr.xyz/r/simple-clock.git";
    sha256 = "sha256-PRd8G9clzu25+RAwUIarR18ze2k5hXkXqP/zLZWnlpo=";
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
