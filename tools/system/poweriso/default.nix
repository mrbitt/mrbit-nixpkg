{ lib
, stdenv
, fetchurl 
, copyDesktopItems
, makeDesktopItem
, libX11, libxcb, wayland
, freetype
, hicolor-icon-theme
, libbsd
, libsForQt5
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

nativeBuildInputs = [ copyDesktopItems ];

installPhase = ''
 
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/scalable $out/share/poweriso-gui
    cp -r ./* $out/share/poweriso-gui/
    rm -f "$out/share/poweriso-gui/poweriso.sh"
    install -Dm644 "${./poweriso-gui.svg}" "$out/share/icons/hicolor/scalable/poweriso-gui.svg"    
        cat >> $out/bin/poweriso-gui << EOF
         #!${runtimeShell}
         export LD_LIBRARY_PATH="$out/share/poweriso-gui:\$LD_LIBRARY_PATH"
         export QT_QPA_PLATFORM=wayland
         export QT_QPA_PLATFORM_PLUGIN_PATH="$out/share/poweriso-gui"
         cd $out/share/poweriso-gui
         exec $out/share/poweriso-gui/poweriso "\$@"
         unset LD_LIBRARY_PATH
  EOF
         chmod +x $out/bin/poweriso-gui
      '';

 desktopItems = [ (makeDesktopItem {
    name = "${pname}-gui";
    exec = "${pname}-gui";
    icon = "${pname}-gui.svg";
    desktopName = "${pname}-gui";
    comment     = meta.description;
    categories  = [ "System" ];
  }) ];

 meta = with lib; {
    description = "free GUI program which runs on Linux";
    homepage    = "http://www.poweriso.com/download-poweriso-for-linux.htm";
    platforms   = platforms.all;
    license     = with licenses; [ gpl2Plus
      bsd2 # tix
      gpl2 # patches from portage
    ];
  };
}
