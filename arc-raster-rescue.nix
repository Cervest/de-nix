with (import <nixpkgs> {});

stdenv.mkDerivation rec {
  pname = "arc_raster_rescue";

  version = "v1.0.0";

  src = fetchFromGitHub {
    owner = "r-barnes";
    repo = "ArcRasterRescue";
    rev = version;
    sha256 = "010x159k96qm6m9bz198yivkxsshd8iqpfg9hzas3p3sbkncb31b";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
  ];

  enableParallelBuilding = true;

  buildInputs = [
    zlib
    gdal
  ];

  installTargets = [ "arc_raster_rescue" ];

  postInstall = ''
    cp arc_raster_rescue.exe $out
  '';


}
