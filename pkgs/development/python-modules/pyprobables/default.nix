{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyprobables";
  version = "0.6.1";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "barrust";
    repo = "pyprobables";
    rev = "refs/tags/v${version}";
    hash = "sha256-yJUYGfy+d+Xfk1DUDvBeWk0EcNPuW4DcUHx3G3jzEdc=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "probables" ];

  meta = with lib; {
    description = "Probabilistic data structures";
    homepage = "https://github.com/barrust/pyprobables";
    changelog = "https://github.com/barrust/pyprobables/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
