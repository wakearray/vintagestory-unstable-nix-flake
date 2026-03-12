{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  gtk2,
  sqlite,
  openal,
  cairo,
  libGLU,
  SDL2,
  freealut,
  libglvnd,
  pipewire,
  libpulseaudio,
  dotnet-runtime_10,
  x11Support ? true,
  libxi,
  libxcursor,
  libx11,
  waylandSupport ? false,
  wayland ? null,
  libxkbcommon ? null,
}:

assert x11Support || waylandSupport;
assert waylandSupport -> wayland != null;
assert waylandSupport -> libxkbcommon != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "vintagestory-unstable";
  version = "1.22.0-rc.2";

  src = fetchurl {
    url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${finalAttrs.version}.tar.gz";
    hash = "sha256-ey9xJIWJrK4orYtsE9Bzfwuy7Ngal2shkoU62HLKvpc=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  runtimeLibs = [
    gtk2
    sqlite
    openal
    cairo
    libGLU
    SDL2
    freealut
    libglvnd
    pipewire
    libpulseaudio
  ]
  ++ lib.optionals x11Support [
    libx11
    libxi
    libxcursor
  ]
  ++ lib.optionals waylandSupport [
    wayland
    libxkbcommon
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "vintagestory-unstable";
      desktopName = "Vintage Story Unstable";
      exec = "vintagestory-unstable";
      icon = "vintagestory";
      comment = "Innovate and explore in an unstable sandbox world";
      categories = [ "Game" ];
    })

    (makeDesktopItem {
      name = "vsumodinstall-handler";
      desktopName = "Vintage Story Unstable 1-click Mod Install Handler";
      comment = "Handler for vintagestorymodinstall:// URI scheme";
      exec = "vintagestory -i %u";
      mimeTypes = [ "x-scheme-handler/vintagestorymodinstall" ];
      noDisplay = true;
      terminal = false;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/vintagestory $out/bin $out/share/icons/hicolor/512x512/apps $out/share/fonts/truetype
    cp -r * $out/share/vintagestory
    cp $out/share/vintagestory/assets/gameicon.png $out/share/icons/hicolor/512x512/apps/vintagestory.png
    cp $out/share/vintagestory/assets/game/fonts/*.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  preFixup =
    let
      runtimeLibs' = lib.strings.makeLibraryPath finalAttrs.runtimeLibs;
    in
    ''
      makeWrapper ${lib.meta.getExe dotnet-runtime_10} $out/bin/vintagestory-unstable \
        --prefix LD_LIBRARY_PATH : "${runtimeLibs'}" \
        --set-default mesa_glthread true \
        ${lib.strings.optionalString waylandSupport ''
          --set-default OPENTK_4_USE_WAYLAND 1 \
        ''} \
        --add-flags $out/share/vintagestory/Vintagestory.dll

      makeWrapper ${lib.meta.getExe dotnet-runtime_10} $out/bin/vintagestory-server-unstable \
        --prefix LD_LIBRARY_PATH : "${runtimeLibs'}" \
        --set-default mesa_glthread true \
        --add-flags $out/share/vintagestory/VintagestoryServer.dll

      find "$out/share/vintagestory/assets/" -not -path "*/fonts/*" -regex ".*/.*[A-Z].*" | while read -r file; do
        local filename="$(basename -- "$file")"
        ln -sf "$filename" "''${file%/*}"/"''${filename,,}"
      done
    '';

  meta = {
    description = "Unstable branch of the in-development indie sandbox game about innovation and exploration";
    homepage = "https://www.vintagestory.at/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.linux;
    mainProgram = "vintagestory-unstable";
  };
})

