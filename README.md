# Vintage Story Unstable

<p>
<img alt="Flake Version: 1.22.0-rc.2" src="https://img.shields.io/badge/Flake_Version-1.22.0--rc.2-blue?style=flat-square">
<img alt="Current Release Version: " src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmods.vintagestory.at%2Fapi%2Fgameversions&query=%24.gameversions%5B-1%3A%5D.name&label=Released%20Version&style=flat-square">
</p>

This flake exists to make it easier for nix and NixOS users to play the most up to date unstable releases from the Vintage Story team.

## How to run

Assuming you have flakes enabled, all you need to do is enter:

```bash
nix run github:wakearray/vintagestory-unstable-nix-flake
```

If you don't have flakes enabled and don't want to enable them permanently, you can use:

```bash
nix --extra-experimental-features 'nix-command flakes' run github:wakearray/vintagestory-unstable-nix-flake
```

You may also wish to set a different data path using the `--dataPath` flag to avoid an unstable version of the game from having access to your normal files:
```bash
nix run github:wakearray/vintagestory-unstable-nix-flake -- --dataPath "$HOME/.config/VintagestoryUnstableData/"
```

## Updates

I'll try to keep this up to date with new releases within 24 hours of a new release, but I don't yet have experience with CI tools so I'll be doing it somewhat manually for the time being. If there's more than 24 hours since a new release has dropped, feel free to submit an issue and I'll do my best to push an update.

Thanks for your patience

## Extra thanks to

- Vintage Story devs who made it possible to check for new versions with a JSON based API
- The nixpkgs maintainers of the stable release of Vintage Story as I only slightly modified their package file to support the unstable releases
