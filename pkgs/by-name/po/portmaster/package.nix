{ lib
, buildGoModule
, fetchFromGitHub
, iptables
}:

buildGoModule rec {
  pname = "portmaster";
  version = "1.6.0";
  CGO_ENABLED = 0;

  ldflags =
    let
      BUILD_PATH = "github.com/safing/portbase/info";
      BUILD_COMMIT = "v${version}";
      BUILD_USER = "nixpkgs";
      BUILD_HOST = "hydra";
      BUILD_DATE = "31.10.2023";
      BUILD_SOURCE = src.gitRepoUrl;
      BUILD_BUILDOPTIONS = "";
    in
    [
      "-X ${BUILD_PATH}.commit=${BUILD_COMMIT}"
      "-X ${BUILD_PATH}.buildOptions=${BUILD_BUILDOPTIONS}"
      "-X ${BUILD_PATH}.buildUser=${BUILD_USER}"
      "-X ${BUILD_PATH}.buildHost=${BUILD_HOST}"
      "-X ${BUILD_PATH}.buildDate=${BUILD_DATE}"
      "-X ${BUILD_PATH}.buildSource=${BUILD_SOURCE}"
    ];

  src = fetchFromGitHub {
    owner = "safing";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-L7jCiXuX9jd/LaRggnPnXBuHqLQ7SfvbyvPM+ePwMYA=";
  };

  vendorHash = "sha256-b8XEF18MLykP9KNziHuvLtiy1ci0sBRdD8WJJ1wrbtA=";

  runtimeDependencies = [ iptables ];

  postPatch = ''
    substituteInPlace updates/main.go --replace 'DisableSoftwareAutoUpdate = false' 'DisableSoftwareAutoUpdate = true'
  '';

  # integration tests require root access
  doCheck = false;

  meta = with lib; {
    description = "A free and open-source application firewall that does the heavy lifting for you";
    homepage = "https://safing.io";
    license = licenses.agpl3;
    maintainers = with maintainers; [ nyanbinary ];
  };
}
