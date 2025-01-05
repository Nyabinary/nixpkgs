{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  pugixml,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hyprwayland-scanner";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprwayland-scanner";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fktzv4NaqKm94VAkAoVqO/nqQlw+X0/tJJNAeCSfzK4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    pugixml
  ];

  doCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/hyprwm/hyprwayland-scanner";
    description = "Hyprland version of wayland-scanner in and for C++";
    changelog = "https://github.com/hyprwm/hyprwayland-scanner/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      fufexan
      johnrtitor
    ];
    mainProgram = "hyprwayland-scanner";
    platforms = lib.platforms.linux;
  };
})
