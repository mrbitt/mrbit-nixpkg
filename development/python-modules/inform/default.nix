{ lib, buildPythonPackage, fetchPypi, pytestCheckHook, arrow, six, hypothesis, pytest, pytest-cov }:

buildPythonPackage rec {
  pname = "inform";
  version = "1.26.0";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "sha256-fVgAtVb0VKG3XGBNYhq84KPhzdQ6kDjo4U85qCEdfoI=";
  };

   postPatch = ''
    # Is in setup_requires but not used in setup.py...
    substituteInPlace setup.py --replace "pytest-runner>=2.0" ""
  '';
  
  propagatedBuildInputs = [ six arrow pytest-cov hypothesis pytest ];
  
  meta = with lib; {
    description = "Print and logging utilities for communicating with user";
    homepage    = "https://github.com/KenKundert/inform";
    license     = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}
