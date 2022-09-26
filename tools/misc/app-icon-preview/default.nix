{ config
, lib
, stdenv
, fetchurl
, json-glib
, glib
, rustc
, gobject-introspection
, gsettings-desktop-schemas
, pkg-config
, ninja
, cargo
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
  pname = "app-icon-preview";
  version = "3.1.0";

  src = fetchurl {
    url = "https://gitlab.gnome.org/World/design/app-icon-preview/-/archive/master/app-icon-preview-master.tar.bz2";
    sha256 = "sha256-x1aBaZn+s43AtTjxiLSHLBbCs/3i68RgzjlxUgXuFao=";
  };

  nativeBuildInputs = [
    cargo 
    json-glib
    desktop-file-utils # For update-desktop-database
    gobject-introspection
    meson
    ninja
    pkg-config
    rustc
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
    #substituteInPlace meson.build --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';
 
   
meta = with lib; {
    description = "Tool for designing applications icons ";
    longDescription = '' '';
    homepage = "https://gitlab.gnome.org/World/design/app-icon-preview";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}
