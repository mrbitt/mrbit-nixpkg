{ lib
, stdenv
, fetchFromGitLab
, cmake
, SDL2, SDL2_image, SDL2_mixer ,libpng 
}:

stdenv.mkDerivation rec {
  pname = "cavestory-nx";
  version = "1.3.0";

  src = fetchFromGitLab {
    owner = "coringao";
    repo = "cavestory-nx";
    rev = version;
    hash = "sha256-x3yNXL/IH8Qflzc091cikAqYEcGFCKz2hf6wBUpDkL4=";
  };
  
   env.NIX_CFLAGS_COMPILE = "-I${lib.getDev SDL2_mixer}/include/SDL2";
   
   nativeBuildInputs = [cmake ];
   buildInputs = [ libpng SDL2 SDL2_mixer];

   installPhase = ''
   runHook preInstall

    cd ..
    mkdir -p $out/{bin,share}
    #mkdir -p $out/share/cavestory-nx/data
    mkdir -p $out/bin/data
    cp ./cavestory-nx $out/bin
    cp -r data/* $out/bin/data
   # cp -r data/* $out/share/cavestory-nx/data
   # install -Dm755 cavestory-nx -t $out/bin
      
    runHook postInstall
     '';

 meta = with lib; {
    description = "Nostalgic side action adventure game to jump and shoot";
    homepage = "https://gitlab.com/coringao/cavestory-nx/";
    changelog = "https://gitlab.com/coringao/cavestory-nx/-/blob/${src.rev}/CHANGELOG";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
    mainProgram = "cavestory-nx";
    platforms = platforms.all;
  };
}
