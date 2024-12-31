{ fetchFromGitHub }:

{
  qmplay2 =
    let
      self = {
        pname = "qmplay2";
        version = "24.12.23";

        src = fetchFromGitHub {
          owner = "zaps166";
          repo = "QMPlay2";
          rev = self.version;
          hash = "sha256-sFkLxjyn21yzK2MlCTdQn51tY3/WU9cq0JX6w2t+G4s=";
        };
      };
    in
    self;

  qmvk = {
    pname = "qmvk";
    version = "0-unstable-2024-12-21";

    src = fetchFromGitHub {
      owner = "zaps166";
      repo = "QmVk";
      rev = "1d8876c2a74d0045b30bec5466d83f45f90f4114";
      hash = "sha256-u/Jb9Qme6VN4WYH7U1f4Ud/46LZLHiFEzb/P1U9LzvM=";
    };
  };
}
