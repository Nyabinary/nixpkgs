{ lib, stdenv, rustPlatform, fetchCrate, pkg-config, udev }:

rustPlatform.buildRustPackage rec {
  pname = "elf2uf2-rs";
  version = "2.0.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-cmiCOykORue0Cg2uUUWa/nXviX1ddbGNC5gRKe+1kYs=";
  };

  cargoHash = "sha256-TBH3pLB6vQVGnfShLtFPNKjciuUIuTkvp3Gayzo+X9E=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optional stdenv.hostPlatform.isLinux udev;

  meta = with lib; {
    description = "Convert ELF files to UF2 for USB Flashing Bootloaders";
    mainProgram = "elf2uf2-rs";
    homepage = "https://github.com/JoNil/elf2uf2-rs";
    license = with licenses; [ bsd0 ];
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ polygon moni ];
  };
}
