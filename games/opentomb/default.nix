{ lib
, stdenv
, fetchFromGitHub
, libpng
, openal
, SDL2
, zlib
, freetype
, cmake
, extra-cmake-modules
, pkg-config
, itstool
, lua5
}:

stdenv.mkDerivation rec {
  pname = "open-tomb";
  version = "32-2018-02-04_alpha";

  src = fetchFromGitHub {
    owner = "opentomb";
    repo = "OpenTomb";
    rev = "win${version}";
    hash = "sha256-UMZaCRzgSlA7tFAYeXrsRm450IRHlYFRFqY1IKd2kgM=";
  };
  
  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}/usr -DLIB_SUFFIX=${placeholder "out"}/lib -DFORCE_SYSTEM_FREETYPE=$(usex system-freetype ON OFF "
     ];

    buildInputs = [ SDL2 zlib libpng openal freetype ];

  nativeBuildInputs = [ cmake extra-cmake-modules pkg-config itstool lua5 ];

installPhase = ''
    ls ../ -l
    runHook preInstall
    mkdir -p $out/{bin,share/pixmaps,share/applications,share/OpenTomb,share/OpenTomb/data}
    mkdir -p $out/share/OpenTomb/scripts 
    mkdir -p $out/share/OpenTomb/shaders
    mkdir -p $out/share/OpenTomb/resource
    cp -rfp ../*{scripts,shaders,resource} $out/share/OpenTomb/
    install -m 644 ../config.lua $out/share/OpenTomb/
    
    install -m 755 ./OpenTomb $out/bin
    #install -m 644 ./res/MainLogo.png $out/share/pixmaps/ffqueue.png
    #install -m 644 ./res/ffqueue.desktop $out/share/applications/
   runHook postInstall
  '';

 # outputs = [ "out" ];

  enableParallelBuilding = true;



  meta = with lib; {
    description = "An open-source Tomb Raider 1-5 engine remake";
    homepage = "https://github.com/opentomb/OpenTomb";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "open-tomb";
    platforms = platforms.all;
  };
}
