{ lib, stdenv, fetchurl, unzip, jre }:

stdenv.mkDerivation rec {
  pname = "tigerjython";
  version = "2.39-2";

  src = fetchurl { 
    url = "https://git.jdmweb2.ch/beat/${pname}_pkg/archive/V${version}.tar.gz";
    sha256 = "sha256-R0PuRC9HsBdWMShBvkzr/D/MCtGacS4lOP+GZCDannI";
  };

  nativeBuildInputs = [ unzip ];
  inherit jre;

  installPhase = ''
    runHook preInstall

    install -Ddm755 "$out/share/${pname}/Lib"
    install -Ddm755 "$out/share/${pname}/TestSamples"
    install -Ddm755 "$out/share/man/man1/"

    install -Dm644 "./TigerJython/tigerjython2.jar" "$out/share/${pname}/."
    install -Dm644 "./TigerJython/Lib/"* "$out/share/${pname}/Lib/."
    install -Dm644 "./TigerJython/TestSamples/"* "$out/share/${pname}/TestSamples/."
    install -Dm644 "./TigerJython/man/tigerjython.1.gz" "$out/share/man/man1/."

    install -Dm755 "./TigerJython/tigerjython" "$out/bin/tigerjython"
    install -Dm755 "./TigerJython/tigerjython.desktop" "$out/share/applications/tigerjython.desktop"
    install -Dm755 "./TigerJython/tigerjython.svg" "$out/share/icons/hicolor/scalable/apps/tigerjython.svg"
    chmod a+x "$out/bin/tigerjython"
    runHook postInstall
  '';

     fixupPhase = ''
    substituteInPlace $out/bin/tigerjython \
      --replace "/usr/bin/java" "${jre}/bin/java" \
      --replace "/opt/" "$out/share/"
   '';


 meta = with lib; {
    homepage = "https://www.tigerjython.ch/";
    description = "TigerJython IDE";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfreeRedistributable; #TODO freedist, libs under BSD-3
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = with maintainers; [ ];
    mainProgram = "tigerjython";
  };
}
