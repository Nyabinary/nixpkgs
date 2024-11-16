{
  lib,
  buildPythonPackage,
  cwl-upgrader,
  cwlformat,
  fetchFromGitHub,
  packaging,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  rdflib,
  requests,
  ruamel-yaml,
  schema-salad,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cwl-utils";
  version = "0.35";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "common-workflow-language";
    repo = "cwl-utils";
    rev = "refs/tags/v${version}";
    hash = "sha256-Lr74msVlpKJGjUWCCaWTH8F0IUk8yIX4FOJHGBkoGL8=";
  };

  build-system = [ setuptools ];

  dependencies = [
    cwl-upgrader
    packaging
    rdflib
    requests
    ruamel-yaml
    schema-salad
  ];

  nativeCheckInputs = [
    cwlformat
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ];

  pythonImportsCheck = [ "cwl_utils" ];

  disabledTests = [
    # Don't run tests which require Node.js
    "test_context_multiple_regex"
    "test_value_from_two_concatenated_expressions"
    "test_graph_split"
    "test_caches_js_processes"
    "test_load_document_with_remote_uri"
    # Don't run tests which require network access
    "test_remote_packing"
    "test_remote_packing_github_soft_links"
  ];

  meta = with lib; {
    description = "Utilities for CWL";
    homepage = "https://github.com/common-workflow-language/cwl-utils";
    changelog = "https://github.com/common-workflow-language/cwl-utils/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
