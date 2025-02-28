{
  lib,
  stdenv,
  fetchFromGitHub,
  autogen,
  autoconf,
  automake,
  autoreconfHook,
  gettext,
  which,
  pkg-config,
  python3,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  pango
}:

stdenv.mkDerivation rec {
  pname = "starfighter";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "pr-starfighter";
    repo = "starfighter";
    rev = "v${version}";
    hash = "sha256-lluZ7f/GgAVMcGNhjtnPDVHrOr6TfZOkkg3+eNeHaaM=";
  };

preAutoreconf = ''
    patchShebangs ./autogen.sh ./locale/build.py
    ./autogen.sh 
  '';
  
 propagatedBuildInputs = [ autoreconfHook gettext python3
    pkg-config
    which 
    autoconf
    automake
    ];
   
    
   env.NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev SDL2_image}/include/SDL2"
    "-I${lib.getDev SDL2_mixer}/include/SDL2"
  ];

  enableParallelBuilding = true;

       
 buildInputs = [
     SDL2_image SDL2_mixer SDL2_ttf pango gettext SDL2
  ];
  
  #  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "";
    homepage = "https://github.com/pr-starfighter/starfighter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "starfighter";
    platforms = lib.platforms.all;
  };
}
