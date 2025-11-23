{ pkgs, ... }: {
	# Which nixpkgs channel to use.
	channel = "unstable"; # or "stable-23.11"

	# Use https://search.nixos.org/packages to find packages
	packages = [
		pkgs.flutter
		pkgs.cmake
		pkgs.clang
		pkgs.ninja
		pkgs.pkg-config
	];

	# Sets environment variables in the workspace
	env = {};

	# For more information, see https://devenv.sh/basics/
	# and https://devenv.sh/reference/options/
}
