{ stdenv, lib, fetchFromGitHub, cmake, extra-cmake-modules, pkg-config, lvm2_dmeventd, wrapQtAppsHook, util-linux, rhash ,jsoncpp, libuv, libgpg-error, libsecret, pcre, qtbase, qt5, qttools, libossp_uuid, libuuid, cryptsetup, libpwquality, libgcrypt, libxkbcommon, libselinux, libsepol }:

stdenv.mkDerivation rec {
  pname = "zuluCrypt ";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "mhogomchungu";
    repo = "zuluCrypt";
    rev = "refs/tags/${version}";
    sha256 = "sha256-sCTVmgFXnmsHtFYcIwUnLEleGZ3f6xyAk4AsRf4+5kE=";
  };

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}/usr -DLIB_SUFFIX=${placeholder "out"}/lib -DNOGUI=false -DQT5=true -DHOMEMOUNTPREFIX=false -DUDEVSUPPORT=true -DCMAKE_BUILD_TYPE=release "
     ];

   preConfigure = ''
      export LRELEASE="lrelease"
    sed -i"" \
      -e '/pkg_check_modules( CRYPTSETUP libcryptsetup )/ d' \
      -e '/pkg_check_modules( DEVMAPPER devmapper )/ d' \
      -e '/pkg_check_modules( UUID-OSSP ossp-uuid )/ d' \
      -e '/pkg_check_modules( UUID uuid )/ d' \
      -e '/pkg_check_modules( MCHUNGU_TASK mhogomchungu_task )/ d' \
      -e '/message( FATAL_ERROR "ERROR: could not find devmapper package" )/ d' \
      -e '/message( FATAL_ERROR "ERROR: could not find uuid package" )/ d' \
      -e '/message( FATAL_ERROR "ERROR: could not find cryptsetup package" )/ d' \
      CMakeLists.txt
       
    sed -i"" \
      -e '/pkg_check_modules( CRYPTSETUP libcryptsetup )/ d' \
      -e '/pkg_check_modules( DEVMAPPER devmapper )/ d' \
      -e '/pkg_check_modules( UUID-OSSP ossp-uuid )/ d' \
      -e '/pkg_check_modules( UUID uuid )/ d' \
      -e '/pkg_check_modules( MCHUNGU_TASK mhogomchungu_task )/ d' \
      external_libraries/tcplay/CMakeLists.txt
      
    
         
 #   sed -i 's,share/doc,'$out'/share/doc,' CMakeLists.txt
 #   sed -i 's,share/man,'$out'/share/man,' CMakeLists.txt
 #   sed -i 's,share,'$out'/share,' CMakeLists.txt
 #   sed -i 's,pkg_check_modules( CRYPTSETUP libcryptsetup ), #pkg_check_modules( CRYPTSETUP libcryptsetup  ),' CMakeLists.txt
 #   sed -i 's,pkg_check_modules( DEVMAPPER devmapper ), #pkg_check_modules( DEVMAPPER devmapper ),' CMakeLists.txt
 #   sed -i 's,pkg_check_modules( UUID-OSSP ossp-uuid ), #pkg_check_modules( UUID-OSSP ossp-uuid ),' CMakeLists.txt
 #   sed -i 's,pkg_check_modules( UUID uuid ), #pkg_check_modules( UUID uuid ),' CMakeLists.txt
 #   sed -i 's,pkg_check_modules( MCHUNGU_TASK mhogomchungu_task ), #pkg_check_modules( MCHUNGU_TASK mhogomchungu_task ),' CMakeLists.txt
   '';



  nativeBuildInputs = [
    cmake extra-cmake-modules pkg-config wrapQtAppsHook
  ];

  buildInputs = [ lvm2_dmeventd
    qtbase qttools libsecret pcre libgpg-error rhash jsoncpp libuv libgcrypt libuuid libselinux libsepol libossp_uuid cryptsetup libpwquality
  ];
 
# postPatch = ''
#      for unit in src/zuluCrypt/*; do
#       substituteInPlace "$CMakeLists.txt" \
#        --replace "pkg_check_modules( CRYPTSETUP libcryptsetup  )  #pkg_check_modules( CRYPTSETUP libcryptsetup  )" \
#        --replace "pkg_check_modules( DEVMAPPER devmapper  )  #pkg_check_modules( DEVMAPPER devmapper  )" \
#        --replace "pkg_check_modules( UUID-OSSP ossp-uuid  )  #pkg_check_modules( UUID-OSSP ossp-uuid  )" \
#        --replace "pkg_check_modules( UUID uuid  )  #pkg_check_modules( UUID uuid  )" \
#        --replace "pkg_check_modules( MCHUNGU_TASK mhogomchungu_task  )  #pkg_check_modules( MCHUNGU_TASK mhogomchungu_task  )" 
#       done
#      '';

   
 
 doCheck = false;
 #dontWrapQtApps= true;
}
