{ mkDerivation, lib, stdenv, fetchpatch, makeWrapper, fetchurl, cmake, extra-cmake-modules
, karchive, kconfig, kwidgetsaddons, kcompletion, kcoreaddons
, kguiaddons, ki18n, kitemmodels, kitemviews, kwindowsystem
, kio, kcrash, breeze-icons
, boost, libraw, fftw, eigen, exiv2, libheif, lcms2, gsl, openexr, giflib
, openjpeg, opencolorio_1, xsimd, poppler, curl, ilmbase, libmypaint, libwebp
, qtmultimedia, qtx11extras, quazip
, python3Packages

, version
, kde-channel
, sha256

, callPackage
}:

mkDerivation rec {
  pname = "krita";
  inherit version;

  src = fetchurl {
    url = "https://download.kde.org/${kde-channel}/${pname}/${version}/${pname}-${version}.tar.gz";
    inherit sha256;
  };
   patches = [
    (fetchpatch {
      name = "exiv2-0.28.patch";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/krita/-/raw/acd9a818660e86b14a66fceac295c2bab318c671/exiv2-0.28.patch";
      hash = "sha256-iD2pyid513ThJVeotUlVDrwYANofnEiZmWINNUm/saw=";
    })
    (fetchpatch {
      name = "krita-opencolorio-2.3-compat.patch";
      url = "https://invent.kde.org/graphics/krita/-/commit/520c633c2c868f2236d8e56eefecdcb6e3ebd840.patch";
      hash = "sha256-eXsgBN8OnKjZOQsOxViPypts6CVh3L+IYKMB/mDUcfQ=";
      includes = [ "plugins/dockers/lut/ocio_display_filter_vfx2021.cpp" ];
    })
  ];


  
  nativeBuildInputs = [ cmake extra-cmake-modules python3Packages.sip makeWrapper ];

  buildInputs = [
    karchive kconfig kwidgetsaddons kcompletion kcoreaddons kguiaddons
    ki18n kitemmodels kitemviews kwindowsystem kio kcrash breeze-icons
    boost libraw fftw eigen exiv2 lcms2 gsl openexr libheif giflib
    openjpeg opencolorio_1 poppler curl ilmbase libmypaint libwebp
    qtmultimedia qtx11extras quazip
    python3Packages.pyqt5
    xsimd
  ];

  NIX_CFLAGS_COMPILE = [ "-I${ilmbase.dev}/include/OpenEXR" ]
    ++ lib.optional stdenv.cc.isGNU "-Wno-deprecated-copy";

  # Krita runs custom python scripts in CMake with custom PYTHONPATH which krita determined in their CMake script.
  # Patch the PYTHONPATH so python scripts can import sip successfully.
  postPatch = let
    pythonPath = python3Packages.makePythonPath (with python3Packages; [ sip setuptools ]);
  in ''
    substituteInPlace cmake/modules/FindSIP.cmake \
      --replace 'PYTHONPATH=''${_sip_python_path}' 'PYTHONPATH=${pythonPath}'
    substituteInPlace cmake/modules/SIPMacros.cmake \
      --replace 'PYTHONPATH=''${_krita_python_path}' 'PYTHONPATH=${pythonPath}'
  '';

  cmakeFlags = [
    "-DPYQT5_SIP_DIR=${python3Packages.pyqt5}/${python3Packages.python.sitePackages}/PyQt5/bindings"
    "-DPYQT_SIP_DIR_OVERRIDE=${python3Packages.pyqt5}/${python3Packages.python.sitePackages}/PyQt5/bindings"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
  ];

  preInstall = ''
    qtWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
  '';

  meta = with lib; {
    description = "A free and open source painting application";
    homepage = "https://krita.org/";
    maintainers = with maintainers; [ abbradar sifmelcara nek0 ];
    platforms = platforms.linux;
    license = licenses.gpl3Only;
  };
}
