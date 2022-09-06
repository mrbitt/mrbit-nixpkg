{ stdenv, lib, buildPythonPackage, python3Packages, pytestrunner, inform, braceexpand, requests-mock, pytest, pytestcov, fetchPypi, setuptools }:

buildPythonPackage rec {
  pname = "shlib";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "359ab9426ffc4baa224906f43d642040d5fbac2ab3700e20ca2d57f799ae2231";
  };

   checkInputs = [ pytest pytestrunner requests-mock pytestcov inform braceexpand ];
   propagatedBuildInputs = with python3Packages; [ setuptools ];

   postPatch = ''
    # Is in setup_requires but not used in setup.py...
    substituteInPlace setup.py --replace "'pytest-runner'" ""
  '';

  meta = with stdenv.lib; {
    description = "Print and logging utilities for communicating with user";
    homepage    = "https://github.com/KenKundert/inform";
    license     = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}
