{ lib
, stdenv
, fetchurl
, dpkg
, makeWrapper
, electron
, alsa-lib
, gtk3
, nss
, nspr
}:

stdenv.mkDerivation rec {
  pname = "balena-etcher";
  version = "2.1.7";

  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/${pname}_${version}_amd64.deb";
    hash = "sha256-nb6mFl3e4ewfG3o4/pLw0sVMYhdxBDinr2dSwmfRk5U="; # Sostituisci con l'hash reale
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    # Usiamo dpkg-deb -x ma intercettiamo i permessi estraendo manualmente 
    # senza ripristinare i permessi speciali (SUID) del file chrome-sandbox
    dpkg-deb --fsys-tarfile $src | tar --no-same-permissions --no-same-owner -xvf -
    
  '';

  installPhase = ''
    runHook preInstall
   
      mkdir -p $out/share

    # Copia le risorse dell'applicazione se presenti
    if [ -d opt/balena-etcher ]; then
      cp -r opt/balena-etcher $out/share/balena-etcher
    elif [ -d usr/lib/balena-etcher ]; then
      cp -r usr/lib/balena-etcher $out/share/balena-etcher
    fi
    
    # Copia le icone e i file .desktop in modo sicuro
    if [ -d usr/share ]; then
      cp -r usr/share/* $out/share/
    fi

    # Rimuove il binario precompilato nativo per usare l'Electron di Nixpkgs
    rm -f $out/share/balena-etcher/balena-etcher
    rm -f $out/share/balena-etcher/chrome-sandbox

    # Crea il wrapper standard nella cartella bin
    mkdir -p $out/bin
     makeWrapper ${electron}/bin/electron $out/bin/balena-etcher \
      --add-flags "$out/share/balena-etcher/resources/app.asar" \
      --add-flags "--disable-vulkan" \
      --add-flags "--ozone-platform-hint=auto" \
      --prefix LD_LIBRARY_PATH : "${lib.makeBinPath [ alsa-lib gtk3 nss nspr ]}"

    # Fix del file .desktop per conformarsi ai percorsi Nix
    if [ -f $out/share/applications/balena-etcher.desktop ]; then
      substituteInPlace $out/share/applications/balena-etcher.desktop \
        --replace-warn "Exec=/opt/balena-etcher/balena-etcher" "Exec=balena-etcher"
    fi
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Flash OS images to SD cards & USB drives, safely and easily";
    homepage = "https://github.com";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
