{ stdenv, lib, borgbackup, python3Packages, inform, quantiphy, shlib, fetchurl, python-setup-hook }:

python3Packages.buildPythonApplication rec {
  pname = "emborg";
  version = "1.17";

  src = fetchurl {
    url = "https://github.com/KenKundert/${pname}/archive/v${version}.tar.gz";
    sha256 = "1vd4maxix00dc7b7y0ix8zj7p4i01gsymzlsn1h4i5zwvmclm5kp";
  };

  doCheck = false;
   propagatedBuildInputs = with python3Packages; [ appdirs arrow docopt inform quantiphy shlib ];

    # This enables accessing modules stored in cwd
  #makeWrapperArgs = ["--prefix PYTHONPATH . :"];

  meta = with lib; {
    homepage = "https://github.com/KenKundert/emborg";
    description = "Front-end to Borg backup";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}
