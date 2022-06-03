{ stdenv
, lib
, fetchurl
, python3
, glib
, itstool
, libunique
, gettext
, yelp-tools
, gsettings-desktop-schemas
, gexiv2
, pkg-config
, gobject-introspection
, flex
, autoreconfHook
, makeWrapper
, wrapGAppsHook
, exiv2
, libgsf
, poppler
, taglib
, shared-mime-info
, gtk2
}:

stdenv.mkDerivation rec {
  pname = "gnome-commander";
  version = "1.14.2";

  src = fetchurl {
    url ="https://download.gnome.org/sources/${pname}/1.14/${pname}-${version}.tar.xz";
    sha256 = "E3jv0k+K8YoJAx2D2Rj5Zio/Xrpab535/FWHDy5vDuk=";
  };

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
    wrapGAppsHook
    autoreconfHook
  ];

  buildInputs = [
    yelp-tools
    gsettings-desktop-schemas
    gettext
    glib
    libgsf
    poppler
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
