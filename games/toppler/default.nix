{
  lib,
  stdenv,
  fetchFromGitLab,
  nix-update-script,
  writableTmpDirAsHomeHook,
  fontconfig,
  copyDesktopItems,
  makeDesktopItem,
  buildPackages,
  pkg-config,
  gettext,
  povray,
  imagemagick,
  gimp,

  SDL2,
  SDL2_mixer,
  SDL2_image,
  libpng,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "toppler";
  version = "1.3";

  src = fetchFromGitLab {
    owner = "roever";
    repo = "toppler";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ecEaELu52Nmov/BD9VzcUw6wyWeHJcsKQkEzTnaW330=";
  };

  strictDeps = true;
  enableParallelBuilding = true;

  depsBuildBuild = [
    buildPackages.stdenv.cc
    pkg-config
    SDL2
    SDL2_image
    libpng
    zlib
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    povray
    imagemagick
    fontconfig
    gimp 
    copyDesktopItems
    # GIMP needs a writable home
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    zlib
  ];

  patches = [
      # Based on https://gitlab.com/roever/toppler/-/merge_requests/3
    ./gcc14.patch
  ];

    postPatch = ''
        substituteInPlace Makefile --replace-fail "CONVERT = convert" "CONVERT = magick"
         '';
         
  makeFlags = [
    "CXX_NATIVE=$(CXX_FOR_BUILD)"
    "PKG_CONFIG_NATIVE=$(PKG_CONFIG_FOR_BUILD)"
    "PREFIX=${placeholder "out"}"
  ];

  preBuild = ''
    # The `$` is escaped in `makeFlags` so using it for these parameters results in infinite recursion
    makeFlagsArray+=(CXX=$CXX PKG_CONFIG=$PKG_CONFIG);
  '';

   # fix: 'Fontconfig error: Cannot load default config file: No such file: (null)'
  env.FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";
  
    # fix: error: XDG_RUNTIME_DIR is invalid or not set in the environment.
   env.XDG_RUNTIME_DIR = "/tmp";
  
  passthru.updateScript = nix-update-script { };

   postInstall = ''
    install -Dvm444 $src/dist/toppler.xpm $out/share/pixmaps/toppler.png 
   '';
   
   desktopItems = makeDesktopItem {
      name = "toppler";
      exec = "toppler";
      terminal=false;
      comment="Climb the rotating towers";
      desktopName = "Tower Toppler";
      categories = [ "Game" "ArcadeGame"];
    };
  
  meta = {
    description = "Jump and run game, reimplementation of Tower Toppler/Nebulus";
    homepage = "https://gitlab.com/roever/toppler";
    license = with lib.licenses; [gpl2Plus gpl3Plus ];
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "toppler";
  };
})
