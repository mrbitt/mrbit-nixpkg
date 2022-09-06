{ stdenv, lib, buildPythonPackage, python3Packages, pytestrunner, requests-mock, pytest, pytestcov, fetchPypi, setuptools }:

buildPythonPackage rec {
  pname = "quantiphy";
  version = "2.10.0";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "0db4efac93cea8aff69fd77d6412b3291f0f095afb1389de671e738474223f6f";
  };

   checkInputs = [ pytest pytestrunner requests-mock pytestcov ];
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
