#!/usr/bin/env bash

# Current package version
package_version="$(sed --quiet 's/^  version = \"\(.*\)\";/\1/p' ./package.nix)"

# Current latest version with a - in the version string, as pulled from the api
new_version="$(curl -sL https://mods.vintagestory.at/api/gameversions | jq -r '.gameversions | map(.name | select(contains("-"))) | last')"

# Use the fsaintjacques/semver-tool script to check if the api's reported version is newer than the package version
result="$(curl -s https://raw.githubusercontent.com/fsaintjacques/semver-tool/3c76a6f9d113f4045f693845131185611a62162e/src/semver | bash -s compare "$package_version" "$new_version")"

# Update the package file
function update_package_version() {
  # Replace old package version with new package version
  sed -i "s/$package_version/$new_version/" "./package.nix"

  # Obtain the nix hash for the new game files
  raw_hash="$(nix-prefetch-url "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_$new_version.tar.gz")"
  new_hash="$(nix hash to-sri --type sha256 "$raw_hash")"

  # Replace old package hash with new package hash
  sed -i "s/^    hash = \".*\";/    hash = \"$new_hash\";/" "./package.nix"

  # img.shields.io requires dashes to be escaped with an additional dash
  new_version_number_escaped="${new_version//"-"/"--"}"

  # Add escaped version number to badge
  new_version_badge_url="https:\/\/img.shields.io\/badge\/Flake-Version-$new_version_number_escaped-blue"

  # Replace the Flake Version badge URL in README.md
  sed -i "s/<img alt=\"Flake Version: .*\" src=\"https:\/\/img.shields.io\/badge\/Flake-Version-.*\">/<img alt=\"Flake Version: $new_version\" src=\"$new_version_badge_url\">/" "./README.md"

  # Update the git repo, but don't push to remote
  git add ./package.nix
  git commit -m "Updated to $new_version"

  echo "Update complete, please use 'nix run' inside this repo to test if the game starts up before pushing to GitHub."
}

case "$result" in
  "-1") echo "A newer version is available. Latest version is now $new_version, which is newer than current $package_version."
    update_package_version
    ;;
  "0") echo "Package version is latest unstable game version." ;;
  "1") echo "Package version ($package_version) is somehow newer than latest unstable game version ($new_version)." ;;
  *) echo "Something went wrong." ;;
esac
