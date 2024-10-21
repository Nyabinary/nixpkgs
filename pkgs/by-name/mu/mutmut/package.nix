{
  lib,
  fetchFromGitHub,
  mutmut,
  python3Packages,
  testers,
}:
python3Packages.buildPythonApplication rec {
  pname = "mutmut";
  version = "2.2.0";

  src = fetchFromGitHub {
    repo = pname;
    owner = "boxed";
    rev = "refs/tags/${version}";
    hash = "sha256-G+OL/9km2iUeZ1QCpU73CIWVWMexcs3r9RdCnAsESnY=";
  };

  postPatch = ''
    substituteInPlace requirements.txt --replace 'junit-xml==1.8' 'junit-xml==1.9'
  '';

  disabled = python3Packages.pythonOlder "3.7";

  doCheck = false;

  propagatedBuildInputs = with python3Packages; [
    click
    glob2
    parso
    pony
    junit-xml
  ];

  passthru.tests.version = testers.testVersion { package = mutmut; };

  meta = with lib; {
    description = "mutation testing system for Python, with a strong focus on ease of use";
    mainProgram = "mutmut";
    homepage = "https://github.com/boxed/mutmut";
    changelog = "https://github.com/boxed/mutmut/blob/${version}/HISTORY.rst";
    license = licenses.bsd3;
    maintainers = with maintainers; [ synthetica ];
  };
}
