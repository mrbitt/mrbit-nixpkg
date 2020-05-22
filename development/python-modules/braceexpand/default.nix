{ stdenv, lib, buildPythonPackage, python3Packages, pytestrunner, requests-mock, pytest, pytestcov, fetchPypi, setuptools }:

buildPythonPackage rec {
  pname = "braceexpand";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "d3d932030c3ab4740b33df68a58d70f3a10368f33b3a56eb951da649bec0bb52";
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
