{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  docbook-xsl-nons,
  libxslt,
  pkg-config,
  alsa-lib,
  faac,
  faad2,
  ffmpeg,
  fuse3,
  glib,
  openh264,
  openssl,
  pcre2,
  pkcs11helper,
  uriparser,
  zlib,
  libX11,
  libXcursor,
  libXdamage,
  libXdmcp,
  libXext,
  libXi,
  libXinerama,
  libXrandr,
  libXrender,
  libXtst,
  libXv,
  libxkbcommon,
  libxkbfile,
  wayland,
  wayland-scanner,
  icu,
  libunwind,
  orc,
  cairo,
  cjson,
  libusb1,
  libpulseaudio,
  cups,
  pcsclite,
  SDL2,
  SDL2_ttf,
  SDL2_image,
  systemd,
  libjpeg_turbo,
  libkrb5,
  libopus,
  buildServer ? true,
  nocaps ? false,
  AudioToolbox,
  AVFoundation,
  Carbon,
  Cocoa,
  CoreMedia,
  withUnfree ? false,

  # tries to compile and run generate_argument_docbook.c
  withManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,

  gnome,
  remmina,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freerdp";
  version = "3.10.3";

  src = fetchFromGitHub {
    owner = "FreeRDP";
    repo = "FreeRDP";
    rev = finalAttrs.version;
    hash = "sha256-qFjR1Z2GZsNpgjlbHw+o+dLCBLZQ9D9c93FFqFGM8T4=";
  };

  postPatch =
    ''
      export HOME=$TMP

      # skip NIB file generation on darwin
      substituteInPlace "client/Mac/CMakeLists.txt" "client/Mac/cli/CMakeLists.txt" \
        --replace-fail "if(NOT IS_XCODE)" "if(FALSE)"

      substituteInPlace "libfreerdp/freerdp.pc.in" \
        --replace-fail "Requires:" "Requires: @WINPR_PKG_CONFIG_FILENAME@"
    ''
    + lib.optionalString (pcsclite != null) ''
      substituteInPlace "winpr/libwinpr/smartcard/smartcard_pcsc.c" \
        --replace-fail "libpcsclite.so" "${lib.getLib pcsclite}/lib/libpcsclite.so"
    ''
    + lib.optionalString nocaps ''
      substituteInPlace "libfreerdp/locale/keyboard_xkbfile.c" \
        --replace-fail "RDP_SCANCODE_CAPSLOCK" "RDP_SCANCODE_LCONTROL"
    '';

  nativeBuildInputs = [
    cmake
    libxslt
    docbook-xsl-nons
    pkg-config
    wayland-scanner
  ];

  buildInputs =
    [
      cairo
      cjson
      cups
      faad2
      ffmpeg
      glib
      icu
      libX11
      libXcursor
      libXdamage
      libXdmcp
      libXext
      libXi
      libXinerama
      libXrandr
      libXrender
      libXtst
      libXv
      libjpeg_turbo
      libkrb5
      libopus
      libpulseaudio
      libunwind
      libusb1
      libxkbcommon
      libxkbfile
      openh264
      openssl
      orc
      pcre2
      pcsclite
      pkcs11helper
      SDL2
      SDL2_ttf
      SDL2_image
      uriparser
      zlib
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      fuse3
      systemd
      wayland
      wayland-scanner
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      AudioToolbox
      AVFoundation
      Carbon
      Cocoa
      CoreMedia
    ]
    ++ lib.optionals withUnfree [
      faac
    ];

  # https://github.com/FreeRDP/FreeRDP/issues/8526#issuecomment-1357134746
  cmakeFlags =
    [
      "-Wno-dev"
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (lib.cmakeFeature "DOCBOOKXSL_DIR" "${docbook-xsl-nons}/xml/xsl/docbook")
    ]
    ++ lib.mapAttrsToList lib.cmakeBool {
      BUILD_TESTING = false; # false is recommended by upstream
      WITH_CAIRO = cairo != null;
      WITH_CUPS = cups != null;
      WITH_FAAC = withUnfree && faac != null;
      WITH_FAAD2 = faad2 != null;
      WITH_FUSE = stdenv.hostPlatform.isLinux && fuse3 != null;
      WITH_JPEG = libjpeg_turbo != null;
      WITH_KRB5 = libkrb5 != null;
      WITH_OPENH264 = openh264 != null;
      WITH_OPUS = libopus != null;
      WITH_OSS = false;
      WITH_MANPAGES = withManPages;
      WITH_PCSC = pcsclite != null;
      WITH_PULSE = libpulseaudio != null;
      WITH_SERVER = buildServer;
      WITH_WEBVIEW = false; # avoid introducing webkit2gtk-4.0
      WITH_VAAPI = false; # false is recommended by upstream
      WITH_X11 = true;
    }
    ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
      (lib.cmakeBool "SDL_USE_COMPILED_RESOURCES" false)
    ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-DTARGET_OS_IPHONE=0"
      "-DTARGET_OS_WATCH=0"
      "-include AudioToolbox/AudioToolbox.h"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "-Wno-error=incompatible-function-pointer-types"
    ]
  );

  env.NIX_LDFLAGS = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-framework AudioToolbox"
    ]
  );

  passthru.tests = {
    inherit remmina;
    inherit (gnome) gnome-remote-desktop;
  };

  meta = with lib; {
    description = "Remote Desktop Protocol Client";
    longDescription = ''
      FreeRDP is a client-side implementation of the Remote Desktop Protocol (RDP)
      following the Microsoft Open Specifications.
    '';
    homepage = "https://www.freerdp.com/";
    license = licenses.asl20;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
})
