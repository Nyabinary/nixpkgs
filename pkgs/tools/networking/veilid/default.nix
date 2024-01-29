{ lib
, stdenv
, AppKit
, Security
, fetchFromGitLab
, rustPlatform
, protobuf
, capnproto
}:

rustPlatform.buildRustPackage rec {
  pname = "veilid";
  version = "0.2.5";

  src = fetchFromGitLab {
    owner = "veilid";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-jcSoZhAAoiKn3Jsov4Q0vunPRC+JwX8O0vYZDT5uO0I=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "async-tls-0.12.0" = "sha256-SAirarvQKsYLftr3u29czQFBwVZgl2cSCUqC0/Qgye0=";
      "cursive-0.20.0" = "sha256-jETyRRnzt7OMkTo4LRfeRr37oPJpn9R2soxkH7tzGy8=";
      "cursive-flexi-logger-view-0.5.0" = "sha256-zFpfVFNZNNdNMdpJbaT4O2pMYccGEAGnvYzpRziMwfQ=";
      "cursive_buffered_backend-0.6.1" = "sha256-+sTJnp570HupwaJxV2x+oKyLwNmqQ4HqOH2P1s9Hhw8=";
    };
  };

  nativeBuildInputs = [
    capnproto
    protobuf
  ];

  buildInputs = lib.optionals stdenv.isDarwin [ AppKit Security ];

  cargoBuildFlags = [
    "--workspace"
  ];

  doCheck = false;

  outputs = [ "out" "lib" "dev" ];

  postInstall = ''
    moveToOutput "lib" "$lib"
  '';

  meta = with lib; {
    description = "An open-source, peer-to-peer, mobile-first, networked application framework";
    homepage = "https://veilid.com";
    license = licenses.mpl20;
    maintainers = with maintainers; [ bbigras qbit ];
  };
}
