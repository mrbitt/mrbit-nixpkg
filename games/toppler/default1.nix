{
  lib,
  stdenv,
  fetchFromGitLab,
  nix-update-script,
  fontconfig,
  copyDesktopItems,
  makeDesktopItem,
  buildPackages,
  pkg-config,
  gettext,
  povray,
  imagemagick,

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
  enableParallelBuilding = false;

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
    copyDesktopItems
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    zlib
  ];

  patches = [
    # Based on https://gitlab.com
    ./gcc14.patch
  ];

  postPatch = ''
    # 1. Update the convert macro tool definition
    substituteInPlace Makefile --replace-fail "CONVERT = convert" "CONVERT = magick"

    # 2. Patch GCC 14 native loop optimizations that cause segfault 139
    substituteInPlace Makefile --replace-fail "-O2" "-O0 -fno-finite-math-only"

    # 3. Enforce strict 8-bit indexed palette mappings for tower assets
    substituteInPlace Makefile --replace-fail "-colors 256 PNG8:" "-colors 256 -type Palette -define png:color-type=3 png:"

    # 4. Wipe out any line containing the string "gimp" to bypass intermediate failures
    sed -i '/gimp/d' Makefile
  '';
         
  makeFlags = [
    "CXX_NATIVE=$(CXX_FOR_BUILD)"
    "PKG_CONFIG_NATIVE=$(PKG_CONFIG_FOR_BUILD)"
    "PREFIX=${placeholder "out"}"
  ];

  preBuild = ''
    # 1. Compile native helper binaries cleanly before launching asset builds
    mkdir -p _build/tools
    make _build/tools/assembler _build/tools/cross _build/tools/cremission _build/tools/graphics _build/tools/titles _build/tools/sprites CXX=$CXX PKG_CONFIG=$PKG_CONFIG

    # 2. Extract assets inside the _build folder so subshell relative paths match up perfectly
    cd _build

    # Character Assets (Layer 0 = mask, Layer 1 = colors)
    magick convert "../datafile/dude.xcf[0]" -background black -alpha remove -alpha off dude_mask_rgb.png
    magick convert "../datafile/dude.xcf[1]" -background black -alpha remove -alpha off dude_colors_rgb.png
    
    # Interface Font Assets (High contrast white background to make glyphs fully visible)
    magick convert "../datafile/font.xcf[0]" -background white -alpha remove -alpha off font_mask_rgb.png
    magick convert "../datafile/font.xcf[1]" -background white -alpha remove -alpha off font_colors_rgb.png
    
    # UI Title Assets (Layer 0 = mask, Layer 1 = colors)
    magick convert "../datafile/titles.xcf[0]" -background black -alpha remove -alpha off titles_mask_rgb.png
    magick convert "../datafile/titles.xcf[1]" -background black -alpha remove -alpha off titles_colors_rgb.png

    # Parallax Background Scroller Layers (Slices 0 through 5 mapped explicitly)
    magick convert "../datafile/scroller.xcf[0]" -background black -alpha remove -alpha off scr1_colors_rgb.png
    magick convert "../datafile/scroller.xcf[1]" -background black -alpha remove -alpha off scr1_mask_rgb.png
    magick convert "../datafile/scroller.xcf[2]" -background black -alpha remove -alpha off scr2_colors_rgb.png
    magick convert "../datafile/scroller.xcf[3]" -background black -alpha remove -alpha off scr2_mask_rgb.png
    magick convert "../datafile/scroller.xcf[4]" -background black -alpha remove -alpha off scr3_colors_rgb.png
    magick convert "../datafile/scroller.xcf[5]" -background black -alpha remove -alpha off scr3_mask_rgb.png

    # Map Brick Graphics (Flattened into a single explicit index layer)
    magick convert "../datafile/graphics_brick.xcf[0]" -background black -alpha remove -alpha off -colors 256 -type Palette -define png:color-type=3 png:graphics_brick.png
    magick convert "../datafile/graphics_pinacle.xcf[0]" -background black -alpha remove -alpha off -colors 256 -type Palette -define png:color-type=3 png:graphics_pinacle.png

    # 3. Stage the sprite layout descriptor tracking configurations
    cp ../datafile/sprites_torpedo_* ./

    # Return back to root build directory for standard make lifecycle execution
    cd ..

    # FIXED: Re-injected correct environment parameters to avoid --cflags crash
    makeFlagsArray+=(CXX=$CXX PKG_CONFIG=$PKG_CONFIG);
  '';

  env.FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";
  env.XDG_RUNTIME_DIR = "/tmp";
  
  passthru.updateScript = nix-update-script { };

  postInstall = ''
    install -Dvm444 $src/dist/toppler.xpm $out/share/pixmaps/toppler.png 
  '';
   
  desktopItems = makeDesktopItem {
    name = "toppler";
    exec = "toppler";
    terminal = false;
    comment = "Climb the rotating towers";
    desktopName = "Tower Toppler";
    categories = [ "Game" "ArcadeGame" ];
  };
  
  meta = {
    description = "Jump and run game, reimplementation of Tower Toppler/Nebulus";
    homepage = "https://gitlab.com";
    license = with lib.licenses; [ gpl2Plus gpl3Plus ];
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "toppler";
  };
})
