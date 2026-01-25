{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:/hercules-ci/flake-parts";
    wit-bindgen = {
      url = "github:/bytecodealliance/wit-bindgen";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:/ipetkov/crane";
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    wit-bindgen,
    rust-overlay,
    crane,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [(import rust-overlay)];
        };
        craneLib = crane.mkLib pkgs;
        src = wit-bindgen;
        commonArgs = {
          inherit src;
          strictDeps = true;
        };
        wit-bindgen-package = craneLib.buildPackage (
          commonArgs
          // {
            pname = "wit-bindgen";
            cargoArtifacts = craneLib.buildDepsOnly commonArgs;
            cargoExtraArgs = "--no-default-features --features rust";
            doCheck = false;
          }
        );

        toolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-analyzer"];
        };
        dlopenLibraries = with pkgs; [
          libxkbcommon
          vulkan-loader
          wayland
        ];
      in {
        packages.wit-bindgen = wit-bindgen-package;
        devShells.default = pkgs.mkShell {
          buildInputs = [toolchain wit-bindgen-package];
          env.RUSTFLAGS = "-C link-arg=-Wl,-rpath,${nixpkgs.lib.makeLibraryPath dlopenLibraries}";
        };
      };
    };
}
