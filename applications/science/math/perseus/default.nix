{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation {
  pname = "perseus";
  version = "4-beta";
  nativeBuildInputs = [ unzip ];

  hardeningDisable = [ "stackprotector" ];

  src = fetchurl {
    url = "http://people.maths.ox.ac.uk/nanda/source/perseus_4_beta.zip";
    sha256 = "sha256-cnkJEIC4tu+Ni7z0cKdjmLdS8QLe8iKpdA8uha2MeSU=";
  };

  sourceRoot = ".";

  NIX_CFLAGS_COMPILE = [ "-std=c++14" ];

 postPatch = ''
   # 1. Correzione per ptcomplex in Cells/Point.h
  substituteInPlace Cells/Point.h \
    --replace-fail "bool operator ()(Point<PS>* p, Point<PS>* q)" "bool operator ()(Point<PS>* p, Point<PS>* q) const"

  # 2. Correzione per decnum in Global/Combinatorics.h
  if [ -f Global/Combinatorics.h ]; then
    substituteInPlace Global/Combinatorics.h \
      --replace-fail "bool operator() (num n1, num n2)" "bool operator() (num n1, num n2) const"
  elif [ -f Global/Combinatorics.hpp ]; then
    substituteInPlace Global/Combinatorics.hpp \
      --replace-fail "bool operator() (num n1, num n2)" "bool operator() (num n1, num n2) const"
  fi

  # 3. Correzione per addcomp in Complexes/CToplex.h (Risolve l'errore corrente)
  substituteInPlace Complexes/CToplex.h \
    --replace-fail "bool operator () (vector<num>* v1, vector<num>* v2)" "bool operator () (vector<num>* v1, vector<num>* v2) const"
 '';

  buildPhase = ''
    g++ Pers.cpp -O3 -fpermissive -o perseus
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp perseus $out/bin
    strip --strip-all $out/bin/perseus
  '';

  meta = {
    description = "The Persistent Homology Software";
    longDescription = ''
      Persistent homology - or simply, persistence - is an algebraic
      topological invariant of a filtered cell complex. Perseus
      computes this invariant for a wide class of filtrations built
      around datasets arising from point samples, images, distance
      matrices and so forth.
    '';
    homepage = "http://people.maths.ox.ac.uk/nanda/perseus/index.html";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ erikryb ];
    platforms = lib.platforms.linux;
  };
}
