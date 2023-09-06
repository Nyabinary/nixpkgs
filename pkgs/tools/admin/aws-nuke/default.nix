{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "aws-nuke";
  version = "2.25.0";

  src = fetchFromGitHub {
    owner = "rebuy-de";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Yc9GXdcSKPvwddh+QU2/pBC0XIqA53wpd0VNKOqppbU=";
  };

  vendorHash = "sha256-FZ92JoyPYysYhl7iQZ8X32BDyNKL1UbOgq7EhHyqb5A=";

  overrideModAttrs = _: {
    preBuild = ''
      go generate ./...
    '';
  };

  doCheck = false;

  subPackages = [ "." ];

  meta = with lib; {
    description = "Nuke a whole AWS account and delete all its resources";
    homepage = "https://github.com/rebuy-de/aws-nuke";
    license = licenses.mit;
    maintainers = with maintainers; [ grahamc ];
  };
}
