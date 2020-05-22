{ stdenv, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "Superpaper";
  version = "2.0.2";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "69917135da110837362c3c20394ccab44eaf4bd2002c88f780fc226f5ff06bb8";
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    #screeninfo
    wxPython
    #xpybutil
    numpy
    #system_hotkey
    #distutils-extra
  ];

  LC_ALL = "en_US.UTF-8";

  meta = with stdenv.lib; {
    homepage = "https://github.com/hhannine/Superpaper";
    description = "Cross-platform multi monitor wallpaper manager";
    license = licenses.mit;
    maintainers = [ ];
  };
}
