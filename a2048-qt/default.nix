{ stdenv, fetchurl, qtbase, qttools, qtdeclarative, qtquickcontrols, qmake, qt5, mkDerivation}:

mkDerivation  rec{
  pname = "2048-qt";
  version = "0.1.6";

   src = fetchurl {
    url = "https://github.com/xiaoyong/${pname}/archive/v${version}.tar.gz";
    sha256 = "14pqx2cmhcq8398y3kgnyawql9zhfpqk79z5npkcmswqjwnlfjwr";
   };

  nativeBuildInputs = [ qmake ];

  buildInputs = [ qtbase qttools qtquickcontrols qtdeclarative ];
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    mkdir -p "$out/share/icons"
    cp -pr ${pname} "$out/bin"
    install -D -m644 res/$pname.desktop "$out/share/applications/$pname.desktop"

    # Install icons
	  for i in 16 32 48 256
     do
      iconDirectory=$out/share/icons/hicolor/"$i"x"$i"/apps
      mkdir -p $iconDirectory
      install -D -m644 res/icons/"$i"x"$i"/apps/$pname.png "$out/share/icons/hicolor/"$i"x"$i"/apps/$pname.png"
     done
      install -D -m644 res/icons/scalable/apps/$pname.svg "$out/share/icons/hicolor/scalable/apps/$pname.svg"

   runHook postInstall
  '';
  #enableParallelBuilding = false;
    # dontStrip = true;
  meta = with stdenv.lib;{
    description = "The 2048 number game implemented in Qt";
    homepage = "https://github.com/xiaoyong/2048-Qt";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
