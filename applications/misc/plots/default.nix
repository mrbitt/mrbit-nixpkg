{ stdenv, fetchurl, lib, buildPythonApplication, jinja2, numpy, lark, PyGLM, pygobject3, pyopengl, freetype-py, lmmath, gtk3, xdotool }:

buildPythonApplication rec {
  pname = "plots";
  version = "0.6.2";
  format = "setuptools";

  src = fetchurl {
    url = "https://github.com/alexhuntley/Plots/archive/v${version}.tar.gz";
    sha256 = "sha256-9rcgKYJx6+j4y6c/31KK2MSZzhKglq2Zc+I5+lFasUs=";
    };
  
 propagatedBuildInputs = [
    # install_requires
    jinja2
    freetype-py
    lark
    numpy
    PyGLM
    pygobject3
    pyopengl
  ];

  meta = with lib; {
    description = "A graph plotting app for GNOME";
    homepage = "https://github.com/alexhuntley/Plots/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ mrbit ];
  };
}
