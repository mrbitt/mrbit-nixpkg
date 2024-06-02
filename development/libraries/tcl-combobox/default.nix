{ lib, stdenv, fetchurl, tcl, tcllib, tk, itk}:

tcl.mkTclDerivation rec {
  pname = "tcl-combobox";
  version = "2.3";

  src = fetchurl {
    url = "https://github.com/Geballin/tcl-combobox/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-GdnM6RL0fb1kqPr0YX20kcDLbTZEzr8fHkoq9m5pUcw=";
  };
 
  buildInputs = [ tk tcllib tcl itk ];
  
  installPhase = ''
    mkdir -pv $out/lib
    cp -rfp ./*.{tcl,html} $out/lib/
    '';

  meta = {
    homepage = "https://github.com/Geballin/tcl-combobox";
    description = "A combobox megawidget for TK written in pure TCL";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "tcl-combobox";
    platforms = lib.platforms.all;
  };
}
