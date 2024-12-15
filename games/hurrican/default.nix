{ lib, stdenv, fetchFromGitHub, fetchurl, cmake, pkg-config, SDL, SDL_image, SDL_mixer, libepoxy, libGLU, libmodplug, makeDesktopItem }:

stdenv.mkDerivation rec {
  pname = "Hurrican";
  version = "1.0.9.3";

 src = fetchFromGitHub {
    owner = "HurricanGame";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-J1niXh+JEhTUIMIQqaidSgZ+No6Q9NpIaq2rIBCIMAs=";
    fetchSubmodules = true;
  };
 
  sourceRoot = "${src.name}/Hurrican";
 
  env.NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev SDL}/include/SDL"
    "-I${lib.getDev SDL_image}/include/SDL"
    "-I${lib.getDev SDL_mixer}/include/SDL"
  ];
   
  nativeBuildInputs = [ cmake pkg-config  ];
  buildInputs = [ SDL SDL_image SDL_mixer libepoxy libmodplug libGLU ];
  #makeFlags = [ "PREFIX=$(out)" ];
 

    # Create "hurrican.desktop" file
     fname="hurrican";
  DesktopItem = makeDesktopItem {
    desktopName = "hurrican";
    name = pname;
    exec = fname;
    icon = fname;
    comment = meta.description;
    categories = [ "Game" "AdventureGame" ];
    genericName = fname;
    };
     
   postInstall = ''
      install -Dm644 ${DesktopItem}/share/applications/Hurrican.desktop -t  $out/share/applications/
      #mkdir -p $out/share/pixmaps
      install -Dvm444 $src/Hurrican/Hurrican.ico $out/share/pixmaps/hurrican.png
      rm -rf $out/share/hurrican/data/textures/pvr
     '';

  meta = with lib; {
    description = "Freeware jump and shoot game created by Poke53280";
    homepage = "https://github.com/HurricanGame/Hurrican";
    license = licenses.mit0;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
