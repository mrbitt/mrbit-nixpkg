{ stdenv 
, ccacheStdenv
, lib
, fetchurl
, python3
, glib
, itstool
, libunique
, gettext
, samba
, yelp-tools
, gsettings-desktop-schemas
, appstream-glib
, desktop-file-utils
, gexiv2
, gtest
, pkg-config
, gobject-introspection
, flex
, meson
, ninja
, makeWrapper
, wrapGAppsHook4
, exiv2
, libgsf
, poppler
, taglib
, shared-mime-info
, gtk2
}:
 
 #ccacheStdenv.mkDerivation {
 stdenv.mkDerivation rec {
  pname = "gnome-commander";
  version = "1.16.2";

  src = fetchurl {
    url ="https://download.gnome.org/sources/${pname}/1.16/${pname}-${version}.tar.xz";
    sha256 = "sha256-fPXVbHepXYKPJUBylDEquq4g3GtVbOr9lCTb/iCeXtM=";
  };

   preConfigure = ''
    export CCACHE_DIR=/nix/var/cache/ccache
    export CCACHE_UMASK=007
  '';


postPatch = '' substituteInPlace data/org.gnome.gnome-commander.gschema.xml --replace  '/usr/local' $out'/'
             for f in doc/{C/${pname},cs/${pname},de/${pname},el/${pname},es/${pname},fr/${pname},ru/${pname},sl/${pname},sv/${pname}}*.xml;do
               substituteInPlace $f --replace  '/usr' $out'/'
             done
              '';

  nativeBuildInputs = [
    itstool
    pkg-config
    flex
    glib
    gtk2
    gobject-introspection
    makeWrapper
    wrapGAppsHook4
    meson ninja samba gtest desktop-file-utils appstream-glib
  ];

  buildInputs = [
    yelp-tools
    gsettings-desktop-schemas
    gettext
    libunique
    glib
    libgsf
    poppler
    exiv2
    taglib
  ];

preFixup = ''
   mkdir -p "$out/share/glib-2.0/schemas"
   install -Dm644 $out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/* "$out/share/glib-2.0/schemas"
   
    #substituteInPlace $out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/org.gnome.gnome-commander.gschema.xml --replace /usr/local $out/share
    #glib-compile-schemas "$out/share/glib-2.0/schemas"
    #cp -f $out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/* "$out/share/glib-2.0/schemas"
   # gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
   # gappsWrapperArgs+=(--prefix GSETTINGS_SCHEMA_DIR : "$out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/")
   # glib-compile-schemas $out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas
   #  gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share/gsettings-schemas/${pname}-${version}")
   #  makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
   '';
   
    dontWrapQtApps = true;
   
postInstall = ''
    rm -f $out/lib/${pname}/*.la $out/lib/${pname}/plugins/*.la 
       '';
#postInstall = ''
#  substituteInPlace "$out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/org.gnome.gnome-commander.gschema.xml" --replace "/usr/local" "$out/share"
#  substituteInPlace "$out/share/glib-2.0/schemas/org.gnome.gnome-commander.gschema.xml" --replace "/usr/local" "$out/share
#    '';
 
   meta = with lib; {
    homepage = "http://gcmd.github.io/";
    description = "Graphical two-pane filemanager for Gnome";
    maintainers = [ ];
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
