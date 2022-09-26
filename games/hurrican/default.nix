{ lib, stdenv, fetchFromGitHub, fetchurl, cmake, SDL, SDL_image, SDL_mixer, libepoxy, libGLU, libmodplug, makeDesktopItem }:

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
  nativeBuildInputs = [ cmake ];
  buildInputs = [ SDL SDL_image SDL_mixer libepoxy libmodplug libGLU ];
  #makeFlags = [ "PREFIX=$(out)" ];
  NIX_CFLAGS_COMPILE = [
    #"-I${SDL}/include/SDL"
    "-I${SDL_image}/include/SDL"
    "-I${SDL_mixer}/include/SDL"
    #"-I${SDL_ttf}/include/SDL"
    #"-I${gtk2.dev}/include/gtk-2.0"
    #"-I${glib.dev}/include/glib-2.0"
  ];

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
