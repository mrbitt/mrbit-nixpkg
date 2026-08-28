{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  glib,
  gtk3,
  webkitgtk_4_1,
  openssl,
  libsoup_3,
  libX11,
  libdbusmenu-gtk3,
  rpm,
  cpio,
  libayatana-appindicator,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation rec {
  pname = "chaski-app";
  version = "0.7.0"; # Asegúrate de que coincida con la versión disponible

  # Descargamos directamente el binario compilado por el desarrollador para Linux x86_64
  src = fetchurl {
    url = "https://github.com/a-chacon/chaski-app/releases/download/app-v${version}/Chaski-${version}-1.x86_64.rpm";
    # Si la firma cambia o da error, Nix te dará el hash correcto en pantalla
    hash = "sha256-dWekEhZ8MAbopJqIutqA3nGV3YvIiiMuLw0PUf38U3U="; 
  };

  # Herramientas nativas para inyectar las librerías dinámicas al binario precompilado
  nativeBuildInputs = [
    autoPatchelfHook
    rpm
    cpio
    copyDesktopItems
  ];

  # Librerías de sistema que necesita Chaski/Tauri en Linux para abrir la interfaz gráfica
  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
    openssl
    libsoup_3
    libX11
    libdbusmenu-gtk3
    libayatana-appindicator
  ];

  # 1. Programmatically define a dedicated desktop item profile matrix
  desktopItems = [
    (makeDesktopItem {
      name = "chaski-app";
      exec = "chaski-app";
      icon = "chaski";
      comment = "A calmer way to read the web (RSS/Atom Client)";
      desktopName = "Chaski App";
      genericName = "Feed Aggregator";
      categories = [ "Network" "News" ];
      keywords = [ "RSS" "Atom" "Feed" "Reader" ];
    })
  ];

 # 2. Tell autoPatchelfHook to bundle dynamic-loaded libraries inside the runtime RPATH
  runtimeDependencies = [
    libayatana-appindicator
  ];
  
  # Desempaquetamos el contenido del RPM (que es un archivo comprimido cpio)
  unpackPhase = ''
    rpm2cpio $src | cpio -idmv
  '';

  # Instalamos el binario ya parcheado en el almacén de Nix
  installPhase = ''
    runHook preInstall
  
  # 1. Safely install the binary executable using loose wildcard mappings
    mkdir -p $out/bin
    cp usr/bin/chaski* $out/bin/chaski-app
    chmod +x $out/bin/chaski-app

    # 2. Extract and copy the desktop lunch shortcut correctly
    mkdir -p $out/share/applications
    cp usr/share/applications/*.desktop $out/share/applications/chaski-app.desktop

    # 3. Defensive substitution rewriting that accepts both name variants gracefully
    sed -i "s|^Exec=.*|Exec=$out/bin/chaski-app|g" $out/share/applications/chaski-app.desktop
    sed -i "s|^Icon=.*|Icon=chaski|g" $out/share/applications/chaski-app.desktop

    # 4. Copy the icon theme layouts natively to the share path
    if [ -d usr/share/icons ]; then
      mkdir -p $out/share/icons
      cp -r usr/share/icons/* $out/share/icons/
    fi
    
    runHook postInstall
  '';

  meta = {
    description = "A calmer way to read the web (Precompiled Binary)";
    homepage = "https://github.com";
    license = lib.licenses.gpl3Only;
    mainProgram = "chaski-app";
    platforms = [ "x86_64-linux" ];
  };
}
