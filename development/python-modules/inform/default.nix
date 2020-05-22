{ stdenv, lib, buildPythonPackage, python3Packages, pytestrunner, requests-mock, pytest, pytestcov, fetchPypi, setuptools }:

buildPythonPackage rec {
  pname = "inform";
  version = "1.20.0";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "ad4d767f029d7e48f19383a628d1daaf78cccf5453056e1ff0a6d69ea4d7d37d";
  };

   checkInputs = [ pytest  pytestrunner requests-mock pytestcov ];
   propagatedBuildInputs = with python3Packages; [ six arrow ];

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
