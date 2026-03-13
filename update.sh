#!/bin/bash

package_version="$(sed --quiet 's/^  version = \"\(.*\)\";/\1/p' ./package.nix)"
new_version="$(curl -sL https://mods.vintagestory.at/api/gameversions | jq -r '.gameversions | map(.name | select(contains("-"))) | last')"

result="$(nix-shell -p semver-tool --run "semver compare \"$package_version\" \"$new_version\"")"

function update_package_version() {
  statement="s/$package_version/$new_version/"
  sed -i "$statement" "./package.nix"
  raw_hash="$(nix-prefetch-url "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_$new_version.tar.gz")"
  new_hash="$(nix hash to-sri --type sha256 "$raw_hash")"
  old_hash="$(sed --quiet 's/^    hash = \"\(.*\)\";/\1/p' ./package.nix)"
  statement="s/$old_hash/$new_hash/"
  sed -i "$statement" "./package.nix"
  git add ./package.nix
  git commit -m "Updated to $new_version"
  echo "Update complete"
}

case "$result" in
  "-1") echo "A newer version is available. Latest version is now $new_version, which is newer than current $package_version."
    update_package_version
    ;;
  "0") echo "Package version is latest unstable game version." ;;
  "1") echo "Package version ($package_version) is somehow newer than latest unstable game version ($new_version)." ;;
  *) echo "Something went wrong." ;;
esac
