{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
  } @ inputs: let
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [(import rust-overlay)];
    };
    toolchain = pkgs.rust-bin.stable.latest.default.override {
      extensions = ["rust-analyzer"];
    };
    dlopenLibraries = with pkgs; [
      libxkbcommon

      vulkan-loader

      wayland
    ];
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [toolchain];
      env.RUSTFLAGS = "-C link-arg=-Wl,-rpath,${nixpkgs.lib.makeLibraryPath dlopenLibraries}";
    };
  };
}
