{ lib
, stdenv
, fetchurl 
, copyDesktopItems
, makeDesktopItem
, autoPatchelfHook
, libX11
, libxcb
, wayland
, freetype
, hicolor-icon-theme
, libbsd
, glib
, qt5
, runtimeShell
}:

stdenv.mkDerivation rec {
   version = "1.1";
   pname = "poweriso";
   src = fetchurl {
     url = "https://www.${pname}.com/${pname}-x64-${version}.tar.gz";
     sha256 = "sha256-0wy/abaz9lJBuQnn4mrLoTOZP0QPPb34bzYoiRCKq0Q=";
  };

  dontConfigure = true;
  dontBuild = true;
  
  # DISABILITA IL WRAPPER AUTOMATICO QT: Evita il blocco d'errore nel ciclo qtPreHook
  dontWrapQtApps = true;

  nativeBuildInputs = [ copyDesktopItems autoPatchelfHook ];

  buildInputs = [ 
    libX11 
    libxcb 
    wayland 
    freetype 
    libbsd 
    glib
    qt5.qtbase 
  ];

  installPhase = ''
     mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/scalable $out/share/poweriso-gui
    
    # Move files safely into the target build environment
    if [ -d "poweriso-x64" ]; then
      cp -r poweriso-x64/* $out/share/poweriso-gui/
    else
      cp -r ./* $out/share/poweriso-gui/
    fi
    
    rm -f "$out/share/poweriso-gui/poweriso.sh"
    
    # AGGRESSIVE PURGE: Automatically search and destroy ANY bundled library 
    # that is part of the standard glibc core stack to isolate the binary.
    find $out/share/poweriso-gui/ -type f \( \
      -name "ld-linux*" -o \
      -name "libc.so*" -o \
      -name "libpthread*" -o \
      -name "libm.so*" -o \
      -name "libdl.so*" -o \
      -name "librt.so*" -o \
      -name "libresolv.so*" -o \
      -name "libutil.so*" -o \
      -name "libgcc_s.so*" -o \
      -name "libstdc++.so*" \
    \) -delete

    if [ -f "${./poweriso-gui.svg}" ]; then
      install -Dm644 "${./poweriso-gui.svg}" "$out/share/icons/hicolor/scalable/poweriso-gui.svg"
    fi

    # Generate the wrapper shell binding mapping to Xwayland
    cat >> $out/bin/poweriso-gui << EOF
#!${runtimeShell}
export LD_LIBRARY_PATH="$out/share/poweriso-gui:\$LD_LIBRARY_PATH"
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORM_PLUGIN_PATH="$out/share/poweriso-gui"

# SUPPRESS WAYLAND WARNING: Unset this variable for PowerISO so Qt doesn't print the warning
unset XDG_SESSION_TYPE

cd $out/share/poweriso-gui
exec $out/share/poweriso-gui/poweriso "\$@"
EOF

    chmod +x $out/bin/poweriso-gui
  '';

  desktopItems = [ (makeDesktopItem {
    name = "${pname}-gui";
    exec = "${pname}-gui";
    # CORREZIONE SPECIFICA ICONA: Rimosso ".svg" per assecondare la Icon Theme Specification
    icon = "poweriso-gui";
    desktopName = "PowerISO GUI";
    comment     = "Create, extract, edit and convert disc images";
    categories  = [ "System" ];
  }) ];

  meta = with lib; {
    description = "Graphical program to create, extract, edit, and convert disk image files";
    homepage    = "http://poweriso.com";
    platforms   = [ "x86_64-linux" ];
    license     = licenses.unfree;
  };
}
