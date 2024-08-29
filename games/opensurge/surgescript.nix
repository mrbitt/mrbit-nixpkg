{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "opensurge-surgescript";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "alemart";
    repo = "surgescript";
    rev = "v${version}";
    hash = "sha256-m6H9cyoUY8Mgr0FDqPb98PRJTgF7DgSa+jC+EM0TDEw=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "SurgeScript: a scripting language for games";
    homepage = "https://github.com/alemart/surgescript/archive/refs/tags/v0.6.1.tar.gz";
    changelog = "https://github.com/alemart/surgescript/blob/${src.rev}/CHANGES.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "surgescript";
    platforms = platforms.all;
  };
}
