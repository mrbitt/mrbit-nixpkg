{ lib
, stdenv
, fetchFromGitHub
, qtbase
, qttools
, cmake
, wrapQtAppsHook
, gtk3
, pkg-config
, dmidecode
, fwupd
, iperf3
, lm_sensors
, lsscsi
, mesa-demos ,pciutils ,sysbench ,udisks2 ,usbutils ,vulkan-tools ,xdg-utils ,xorg
, libsoup_3
, json-glib
}:
let
  tools = {
    dmidecode = lib.getExe' dmidecode "dmidecode";
    vulkaninfo = lib.getExe' vulkan-tools "vulkaninfo";
  };
in
stdenv.mkDerivation rec {
  pname = "hardinfo2";
  version = "2.1.17";

  src = fetchFromGitHub {
    owner = "hardinfo2";
    repo = "hardinfo2";
    rev = "release-${version}";
    hash = "sha256-qdJ2l1Cx/czQFIjJXY6UlxaI07dqJWyW9Avldql0V4o=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace gio-2.0 gio-unix-2.0
  '';


 cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
    "-DCMAKE_INSTALL_FULL_SYSCONDIR=$out/etc"
    "-DCMAKE_INSTALL_SYSCONFDIR=$out/etc"
    "-DSYSTEMD_DIR=$out/lib/systemd/system"
  ];


  nativeBuildInputs = [
    qtbase qttools wrapQtAppsHook gtk3 pkg-config
  ];

  buildInputs = [
    cmake
    libsoup_3 json-glib vulkan-tools dmidecode
  ];

  postConfigure = ''
    substituteInPlace cmake_install.cmake \
      --replace "/var/empty" "${placeholder "out"}" \
      --replace "/usr" "${placeholder "out"}"
  '';

  runtimeDeps = [ dmidecode mesa-demos vulkan-tools ];
  binPath = lib.makeBinPath runtimeDeps;


 #  PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";
 # NIX_LDFLAGS = "-lgio-2.0";

  meta = with lib; {
    description = "System Information and Benchmark for Linux Systems";
    homepage = "https://github.com/hardinfo2/hardinfo2/archive/refs/tags/release-2.1.17.tar.gz";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "hardinfo2";
    platforms = platforms.all;
  };
}
