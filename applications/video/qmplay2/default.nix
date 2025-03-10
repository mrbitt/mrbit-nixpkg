{
  lib,
  alsa-lib,
  callPackage,
  cmake,
  fetchpatch2,
  ffmpeg,
  fribidi,
  game-music-emu,
  libXdmcp,
  libXv,
  libass,
  libcddb,
  libcdio,
  libpulseaudio,
  libsidplayfp,
  libva,
  libxcb,
  ninja,
  pkg-config,
  qt5,
  qt6,
  stdenv,
  taglib,
  vulkan-headers,
  vulkan-tools,
  # Configurable options
  qtVersion ? "6", # Can be 5 or 6
}:

let
  sources = callPackage ./sources.nix { };
in
assert lib.elem qtVersion [
  "5"
  "6"
];
stdenv.mkDerivation (finalAttrs: {
  pname = sources.qmplay2.pname + "-qt" + qtVersion;
  inherit (sources.qmplay2) version src;

  postPatch = ''
    pushd src
    cp -va ${sources.qmvk.src}/* qmvk/
    chmod --recursive 744 qmvk
    popd
  '';

patches = [
    # TODO: Remove this patch at the next update
    # https://github.com/marzer/tomlplusplus/pull/233
    (fetchpatch2 {
      name = "QMPlay2.patch";
      url = "https://github.com/zaps166/QMPlay2/commit/04e1c2ed09e6edb47c9c0951eceb9055d410f504.patch";
      hash = "sha256-Hd5P/vc/ruCUR/nMplSmSJqw7fXfERgHQh7UIKBgmqQ=";
    })
  ];

  nativeBuildInputs =
    [
      cmake
      ninja
      pkg-config
    ]
    ++ lib.optionals (qtVersion == "6") [ qt6.wrapQtAppsHook ]
    ++ lib.optionals (qtVersion == "5") [ qt5.wrapQtAppsHook ];

 env.NIX_CFLAGS_COMPILE = toString [ "--std=c++17" ];
 CXXFLAGS = lib.optionals stdenv.cc.isClang ["-std=c++17"];
 
  buildInputs =
    [
      alsa-lib
      ffmpeg
      fribidi
      game-music-emu
      libXdmcp
      libXv
      libass
      libcddb
      libcdio
      libpulseaudio
      libsidplayfp
      libva
      libxcb
      taglib
      vulkan-headers
      vulkan-tools
    ]
    ++ lib.optionals (qtVersion == "6") [
      qt6.qt5compat
      qt6.qtbase
      qt6.qtsvg
      qt6.qttools
    ]
    ++ lib.optionals (qtVersion == "5") [
      qt5.qtbase
      qt5.qttools
    ];

  strictDeps = true;

  # Because we think it is better to use only lowercase letters!
  # But sometimes we come across case-insensitive filesystems...
  postInstall = ''
    [ -e $out/bin/qmplay2 ] || ln -s $out/bin/QMPlay2 $out/bin/qmplay2
  '';

  passthru = {
    inherit sources;
  };

  meta = {
    homepage = "https://github.com/zaps166/QMPlay2/";
    description = "Qt-based Multimedia player";
    longDescription = ''
      QMPlay2 is a video and audio player. It can play all formats supported by
      FFmpeg and libmodplug (including J2B and SFX). It also supports Audio CD,
      raw files, Rayman 2 music, and chiptunes. It also contains YouTube and
      MyFreeMP3 browser.
    '';
    license = lib.licenses.lgpl3Plus;
    mainProgram = "qmplay2";
    maintainers = with lib.maintainers; [
      AndersonTorres
      kashw2
    ];
    platforms = lib.platforms.linux;
  };
})
