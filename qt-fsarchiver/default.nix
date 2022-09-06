{ stdenv, lib, fetchurl, utillinux, e2fsprogs, xz, libgpgerror, libgcrypt, lz4, lzma, zlib, zstd, bzip2, qmake, qtbase, qttools, qttranslations, lsb-release, fsarchiver, samba}:

let inherit (lib) getDev; in

stdenv.mkDerivation rec {
  name = "qt-fsarchiver";
  version = "0.8.5";
  src = fetchurl {
    url = "https://sourceforge.net/projects/${name}/files/source/${name}/${name}-${version}-18.tar.gz";
    sha256 = "1crnwiipsr03khj363ipnchn3yivlyydydn8cdjkvg1cgbdhqc2n";
  };

  postPatch = ''
    substituteInPlace qt-fsarchiver.pro --replace '$$[QT_INSTALL_BINS]/lrelease' '${getDev qttools}/bin/lrelease'
    substituteInPlace qt-fsarchiver.pro --replace  '-llzo2' ' '
    substituteInPlace qt-fsarchiver.pro --replace  '/usr' $out'/'
    substituteInPlace src/sbin/findsmb-qt --replace  '/usr/' $out'/' '';

  nativeBuildInputs = [ qmake lsb-release ];
  buildInputs = [ qtbase qttools samba qttranslations e2fsprogs libgcrypt zlib bzip2 utillinux xz lzma lz4 zstd libgpgerror ];

  postInstall = ''
  rm -fr $out/bin
   for f in $out/sbin/${name}.sh ; do
      substituteInPlace $f --replace "/usr/sbin" "$out/sbin"
    done
  substituteInPlace "$out/share/applications/$name.desktop" --replace "/usr/share/$name/icons/" ""
  substituteInPlace "$out/share/applications/$name.desktop" --replace "Exec=/usr/sbin" "Exec=$out/sbin"
  substituteInPlace "$out/share/applications/$name.desktop" --replace "Icon=/usr" "Icon=$out" '';

  meta = with stdenv.lib; {
    description = "Qt5 frontend for fsarchiver";
    homepage = "http://qt4-fsarchiver.sourceforge.net/";
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = [ ];
    broken = false;
  };
}

