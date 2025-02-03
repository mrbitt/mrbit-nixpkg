{
  lib,
  stdenv,
  qmake,
  qtwebengine,
  qttools,
  pkg-config,
  clang,
  wrapQtAppsHook,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "quiterss2";
  version = "unstable-2020-05-17";

  src = fetchFromGitHub {
    owner = "QuiteRSS";
    repo = "quiterss2";
    rev = "4b3434f9f0324a7b4d825ce2d1a76c772ea8d701";
    hash = "sha256-MlHCuy6ahgHderCoDz47CjD72iPcrNDZ26wuX5hHpRo=";
  };

  qmakeFlags = [ "quiterss2.pro" "prefix=$(out)" "CONFIG+=release" "CONFIG+=WITH_I18N"
                "QMAKE_CC=clang" "QMAKE_CXX=clang++" "QMAKE_LINK=clang++" "QMAKE_LINK_C=clang"
               ]; 

   nativeBuildInputs = [
        pkg-config clang
        qmake
  ];

   buildInputs = [
    wrapQtAppsHook
    qtwebengine
    qttools
  ];

  meta = {
    description = "News feed reader";
    homepage = "https://github.com/QuiteRSS/quiterss2";
    changelog = "https://github.com/QuiteRSS/quiterss2/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "quiterss2";
    platforms = lib.platforms.all;
  };
}
