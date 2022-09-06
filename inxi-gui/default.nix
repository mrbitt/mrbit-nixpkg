{ stdenv, fetchurl, yad, glib, inxi, makeDesktopItem }:

stdenv.mkDerivation rec {
  pname = "inxi-gui";
  version = "0.1.2";

  src = fetchurl {
    url = "https://dllb2.pling.com/api/files/download/j/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjE1NTcwNjQzMDAiLCJ1IjpudWxsLCJsdCI6ImRvd25sb2FkIiwicyI6IjEyYTc5OWQxZWVmZjQzZDQzYzU3ZWNkYzhkZjk1YjhkM2NmNThmZDBjYmQ3OTE4ZWU3MmFmYjg4N2JmNTQ0Y2JhOWY2MDdmZWRhYTEzZWRhMTkyYTg0ZTE1ZmJiOGIzOWJjODFmOGIwOGY3MTU0ODJmNjc3ZDUxNzg0ZGI2OGZjIiwidCI6MTU4ODMzOTI2Nywic3RmcCI6IjkyMWY3MTI0YjU2MDIzMzRhYzY2NDQwNWFhNzY0Zjc2Iiwic3RpcCI6IjEwOS4xMTQuOTguNjYifQ.wdqxfqO3RqNFgMLUdsz0Th4v6HLxMwKL54CrkEY7bjc/${pname}/${version}.tar.xz";
    sha256 = "11srjzv10vhwf41d73ypgrqs8srgyayqa639lb8z0i7cjcz9p140";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps
    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/48x48/apps
    mkdir -p $out/share/icons/hicolor/16x16/apps
    mkdir -p $out/share/${pname}

    cp -r data $out/share/${pname}
    install -m 0644 icon/inxi-gui.svg $out/share/pixmaps
	  install -m 0644 inxi-gui.svg $out/share/icons/hicolor/16x16/apps
	  install -m 0644 icon/inxi-gui.svg $out/share/icons/hicolor/48x48/apps
	  install -m 0775 'Inxi Gui'.desktop $out/share/applications
    install -m 0775 inxi-gui $out/bin/

    for f in $out/share/${pname}/data/{A*,about,man,kill,save} ; do
      substituteInPlace $f --replace "/usr/share" "$out/share"
    done

    for f in $out/bin/${pname} ; do
      substituteInPlace $f --replace "/usr/share" "$out/share"
      substituteInPlace $f --replace "svg!About" "svg!"
    done
      substituteInPlace $out/share/applications/'Inxi Gui'.desktop --replace "Categories=GTK;" "Categories="
  '';

  meta = with stdenv.lib; {
    description = "Simple GUI frontend to inxi script bash";
    homepage = "https://www.linux-apps.com/p/1303949/";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
