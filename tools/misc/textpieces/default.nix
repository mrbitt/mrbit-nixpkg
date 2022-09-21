{ config
, lib
, stdenv
, fetchurl
, json-glib
, glib
, vala
, gobject-introspection
, gsettings-desktop-schemas
, python3
, pkg-config
, ninja
, libgee
, meson
, gtksourceview5
, libadwaita
, gjs
, gtk4
, cmake
, desktop-file-utils
, appstream-glib
, libxml2
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "textpieces";
  version = "3.1.0";

  src = fetchurl {
    url = "https://github.com/liferooter/textpieces/archive/refs/tags/v3.1.0.tar.gz";
    sha256 = "sha256-Cpdq4fuUdH7TkdXl6W/oYySjPN/D4CSJ0nHfRhVv/Fo=";
  };

  nativeBuildInputs = [
    libgee 
    json-glib
    desktop-file-utils # For update-desktop-database
    gobject-introspection
    meson
    ninja
    pkg-config
    python3
    python3.pkgs.pyaml
    vala
    libxml2  
    appstream-glib
    wrapGAppsHook # For GLib-GIO-ERROR **: 14:42:46.572: Settings schema
 ];

  buildInputs = [
    gsettings-desktop-schemas
    cmake
    glib
    gtk4
    gtksourceview5
    libadwaita
    gjs
];
 
  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py data/meson.build
    #substituteInPlace build-aux/meson/postinstall.py --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
    substituteInPlace meson.build --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';
 
   preFixup = ''
   mkdir -p "$out/share/glib-2.0/schemas"
   install -Dm644 $out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/*.xml "$out/share/glib-2.0/schemas"
   
   for i in $out/share/${pname}/scripts/*; do
      substituteInPlace $i --replace '/usr/bin/env python3' '${python3.interpreter}'
    done
  
  '';

meta = with lib; {
    description = "Transform text without using random websites ";
    longDescription = '' '';
    homepage = "https://github.com/liferooter/textpieces";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}
