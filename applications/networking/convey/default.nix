{ lib
, stdenv
, fetchurl
, meson
, ninja
, pkg-config
, vala
, gobject-introspection
, wrapGAppsHook4
, glib
, gtk4
, libadwaita
, gmime3
, sqlite
, cmake 
, webkitgtk_6_0
, enchant
, folks
, gcr_4
, gnome-online-accounts
, gst_all_1
, icu
, isocodes
, json-glib
, libpeas2
, libsecret
, libstemmer
, libunwind
, libxml2
, libytnef
, appstream              
, desktop-file-utils    
, ayatana-indicator-messages
, python3
, itstool
, gettext  
}:

stdenv.mkDerivation rec {
  pname = "convey";
  version = "50.2-1";

  src = fetchurl {
    url = "https://gitlab.gnome.org/donnybeelo/convey/-/archive/50.2-1/convey-50.2-1.tar.bz2";
    hash = "sha256-sUjqiTm9nLqVAebmd0eyv5n7bw3ODrWewkyFrDySe4w=";
  };

 mesonFlags = [
    "-Dprofile=release"
  ];

   postPatch = ''
    patchShebangs build-aux/git_version.py
    
    # Sostituisce la riga di esecuzione di git_version.py con una stringa statica
    # Nota: Modifica la regex interna in base a come è strutturata la riga 149 se fallisce.
    sed -i "149s/run_command(.*)/'${version}'/" meson.build || \
    sed -i "s/run_command(python, 'build-aux\/git_version.py'.*)/'${version}'/g" meson.build || \
    sed -i "s/run_command('build-aux\/git_version.py'.*)/'${version}'/g" meson.build
    
    # 2. Disabilita la compilazione del plugin legacy messaging-menu che fallisce su Vala
    # Cerca il file meson.build dentro src/client/plugin/ per commentare la subdir
    if [ -f src/client/plugin/meson.build ]; then
      sed -i "s/subdir('messaging-menu')/# subdir('messaging-menu')/g" src/client/plugin/meson.build
    fi
  '';

  nativeBuildInputs = [
    meson 
    cmake
    ninja
    pkg-config
    vala
    gobject-introspection
    wrapGAppsHook4
    python3
    itstool
    gettext
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    gmime3  
    sqlite
    webkitgtk_6_0
    enchant
    folks
    gcr_4
    gnome-online-accounts
    gst_all_1.gstreamer        
    gst_all_1.gst-plugins-base 
    gst_all_1.gst-plugins-bad
    icu
    isocodes
    json-glib
    libpeas2
    libsecret
    libstemmer
    libunwind
    libxml2
    libytnef
    appstream              
    desktop-file-utils    
    ayatana-indicator-messages 
  ];

  meta = with lib; {
    description = "Applicazione Convey di GNOME";
    homepage = "https://gitlab.gnome.org/donnybeelo/convey";
    license = licenses.gpl3Plus; # Modificare in base alla licenza effettiva del progetto
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
