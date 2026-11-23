{
  lib,
  fetchFromGitHub,
  fetchFromGitiles,
  rustPlatform,
  buildGoModule,
  buildPackages,
  zstd,
  pkg-config,
  openssl,
  chromiumSrc,
}:

{
  # Match tools/rust/update_rust.py in Chromium 158.0.8127.36.
  crubit = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "crubit";
    version = "0-unstable-2026-10-15";

    src = fetchFromGitiles {
      url = "https://chromium.googlesource.com/external/github.com/google/crubit.git";
      rev = "d757594f6f7ac27c0cf9c8ea63d9136f8e1f77ae";
      hash = "sha256-0I3zO0Kit6Cu2AuEXJ7Gr1wa5tVlvS+b8kw3NUBfvns=";
    };
    cargoHash = "sha256-yp57PHbCMy4YDXfsqdt9ZPSL5ZDYylM2DQxQYJng7fA=";

    buildInputs = [ buildPackages.rustc.llvmPackages.llvm ];
    cargoBuildFlags = [
      "--bin"
      "cc_bindings_from_rs"
    ];
    cargoTestFlags = finalAttrs.cargoBuildFlags;
    env.RUSTC_BOOTSTRAP = 1;
  });

  gnrt = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "gnrt";
    version = "158.0.8127.36";
    src = chromiumSrc;
    # The Chromium source is no longer recompressed into a tarball since M158.
    sourceRoot = lib.optionalString (!chromiumSrc.unpack or false) "${chromiumSrc.name}/" + "tools/crates/gnrt";

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;
      nativeBuildInputs = [ zstd ];
      hash = "sha256-hb/HSco4PeudjnZFGb2+IHw4rQ7ShI42XWqKOwdgrb4=";
    };

    nativeBuildInputs = [
      zstd
      pkg-config
    ];
    buildInputs = [ openssl ];
    meta.mainProgram = "gnrt";
  });

  # Must match devtools-frontend's vendored node_modules.
  esbuild = buildGoModule (finalAttrs: {
    pname = "esbuild";
    version = "0.28.2";
    src = fetchFromGitHub {
      owner = "evanw";
      repo = "esbuild";
      tag = "v${finalAttrs.version}";
      hash = "sha256-I1u+9U5Oj/KzxSjCxwyitwSuDKimatkbC3R2OtaUsfM=";
    };
    vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
  });
}
