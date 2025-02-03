{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, libX11
, SDL2
, libGL
, libGLU
, clang
, pulseaudio
}:

stdenv.mkDerivation rec {
  pname = "open-lara";
  version = "latest";

  src = fetchFromGitHub {
    owner = "XProger";
    repo = "OpenLara";
    rev = version;
    hash = "sha256-tH/p8QURJMczmEQaiw08V27J8qc7BhsxBF7bkk7sCTQ=";
  };
    
    
   #sourceRoot = ".src/platform/nix";
preConfigure = ''
    ls -l ./src/platform
    cd ./src/platform/nix  #"$(ls -d dhewm3-*.src)"/neo
    ./build.sh
  '';
      

nativeBuildInputs = [
    pkg-config clang
    ];

  buildInputs = [
    libX11 SDL2 libGL libGLU pulseaudio
  ];

    installPhase = ''
    runHook preInstall
       mkdir -p $out/share/applications
       mkdir -p $out/share/pixmaps
       mkdir -p $out/bin 
       mkdir -p $out/lib/openlara
        ls -l 
    install -m 755 "./OpenLara" "$out/lib/openlara/OpenLara"
    runHook postInstall
  '';

 meta = with lib; {
    description = "Classic Tomb Raider open-source engine";
    homepage = "https://github.com/XProger/OpenLara";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
    mainProgram = "open-lara";
    platforms = platforms.all;
  };
}
