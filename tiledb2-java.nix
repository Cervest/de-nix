with (import <nixpkgs> {});

stdenv.mkDerivation rec {
  pname = "tiledb2_java";

  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "TileDB-Inc";
    repo = "TileDB-Java";
    rev = version;
    sha256 = "01kda42fhwsf6mbz5zfwd7csg1r1jxbdadp1wavwi29k5g7hh2ml";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DTILEDB_S3=ON"
    "-DTILEDB_GIT_TAG=2.0.7"
  ];

  enableParallelBuilding = true;

  tiledb2 = import(./tiledb2.nix);

  buildInputs = [
    jdk11
    tiledb2
  ];

  installTargets = [ "tiledb_jni" ];

  postInstall = ''
    cp tiledb_jni/libtiledbjni.so $out
  '';

}
