{ lib, buildPythonApplication, setuptools, fetchPypi }:

buildPythonApplication  rec {
  pname = "PyGLM";
  version = "2.5.7";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "sha256-OP3/hOZBbez/4cWHRjKAfVi5jFUIzKNXm7L1My4Jn9g=";
  };
  
   propagatedBuildInputs = [ setuptools ];
   doCheck = false;

 # pythonImportsCheck = [
 #   "glm"
 # ];
 
  
  meta = with lib; {
    description = "OpenGL Mathematics library for Python";
    homepage    = "https://github.com/Zuzu-Typ/PyGLM";
    license     = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}
