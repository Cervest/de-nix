with (import <nixpkgs> {});

stdenv.mkDerivation rec {
  pname = "tiledb2";

  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "TileDB-Inc";
    repo = "TileDB";
    rev = version;
    sha256 = "00g8ibsbnl4wjfx3qg4qy6s7z6dsj898j0yqfhw1gjr1pb5dsapb";
  };

  nativeBuildInputs = [
    clang-tools
    cmake
    python
    doxygen
  ];

  checkInputs = [
    gtest
  ];

  cmakeFlags = [
    "-DTILEDB_S3=ON"
  ];

  enableParallelBuilding = true;

  buildInputs = [
    catch2
    zlib
    lz4
    bzip2
    zstd
    spdlog_0
    tbb
    openssl
    boost
    libpqxx
    aws-c-event-stream
    aws-checksums
    aws-c-common
    curl
    aws-sdk-cpp
  ];

  patches = [
    ./fix-sdk-cmake.patch
  ];

  installTargets = [ "install-tiledb" "doc" ];

}
