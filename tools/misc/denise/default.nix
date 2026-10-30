{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gtk3,
  libpulseaudio,
  nix-update,
  openal,
  libxdmcp,
  libdatrie,
  libxkbcommon,
  lerc,
  xcbutil,
  libsysprof-capture,
  pcre2,
  util-linuxMinimal, # provides libmount
  libselinux,
  libsepol,
  libthai,
  libXtst,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "denise";
  version = "2.9";

  src = fetchFromGitHub {
    owner = "piciji";
    repo = "denise";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-/IrpOeEXwr8X2jlFyjzsWUbHGZFZhLams5KP2/AHT4c=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openal
    libpulseaudio
    gtk3
    libxdmcp
    libdatrie
    libxkbcommon
    lerc
    xcbutil
    libsysprof-capture
    pcre2
    util-linuxMinimal
    libselinux
    libsepol
    libthai
    libXtst
    udev
  ];

  meta = with lib; {
    description = "Highly accurate C64/Amiga emulator";
    mainProgram = "";
    homepage = "https://sourceforge.net/projects/deniseemu/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      jayman2000
      sander
    ];
    platforms = platforms.all;
  };
})
