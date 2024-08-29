{ lib
, stdenv
, fetchFromGitHub
, callPackage
, cmake
, allegro5
, libGL
, physfs
, libX11
}:let
  surgescript = callPackage ./surgescript.nix {};
 in
 
stdenv.mkDerivation rec {
  pname = "opensurge";
  version = "0.6.1.2";

  src = fetchFromGitHub {
    owner = "alemart";
    repo = "opensurge";
    rev = "v${version}";
    hash = "sha256-HvpKZ62mYy7XkZOnIn7QRA2rFVREFnKO1NO83aCR76k=";
  };
 
 prePatch = ''
    substituteInPlace src/misc/opensurge.desktop.in \
      --replace "@DESKTOP_ICON_FULLPATH@" "opensurge.png" 
        '';
 
 configurePhase = '' cmake -DCMAKE_BUILD_TYPE=Release -DGAME_BINDIR=${placeholder "out"}/bin '';
 
  nativeBuildInputs = [ cmake ];
  buildInputs = [ allegro5 libGL libX11 surgescript physfs ];
  
 postPatch = ''
  substituteInPlace CMakeLists.txt \
   --replace "/usr/share/pixmaps" "$out/share/pixmaps" \
    --replace "/usr" "$out" 
   '';
      
 enableParallelBuilding = true;
 
 
 meta = with lib; {
    description = "A retro game engine with a fun platformer for making your dreams come true";
    homepage = "https://github.com/alemart/opensurge/archive/refs/tags/v0.6.1.2.tar.gz";
    changelog = "https://github.com/alemart/opensurge/blob/${src.rev}/CHANGES.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "opensurge";
    platforms = platforms.all;
  };
}
