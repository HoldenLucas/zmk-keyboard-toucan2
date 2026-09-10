# AGENTS.md

ZMK user-config for beekeeb Toucan2. Builds via GitHub Actions; local build
works with rootless podman since this box has no Docker.

## Build & flash

CI (`.github/workflows/build.yml`) builds 3 targets from `build.yaml`:
left (with ZMK Studio), right, and `settings_reset`.

### Local build (verified working)

Workspace cached at `~/.cache/zmk-workspace` (west sources), wrappers in
`~/.cache/zmk/run`, full log at `~/.cache/zmk/run/build.log`:

```sh
./build.sh
```

`build.sh` (launcher) mounts the repo into the zmk-build-arm container and runs
`container-build.sh`, which holds the west build steps and runs inside the
container with cwd `/workspace` (persistent west cache in
`~/.cache/zmk-workspace`).

The wrapper re-copies the repo into the workspace, then runs the same west
commands as CI. Output `.uf2` files land in `artifacts/`. Image needed:
`zmkfirmware/zmk-build-arm:3.5` (west 1.2.0 + Zephyr SDK 0.16.3).

Requires `~/.config/containers/policy.json` (podman pull insists on it):

```json
{ "default": [ { "type": "insecureAcceptAnything" } ] }
```

Note: this repo deviates from the ZMK template — `boards/` is at the repo
root, not inside `config/`. Mount/copy the repo root, init with
`west init -l config`, and pass `-DZMK_CONFIG=<workdir>`.

### Flashing (seeeduino_xiao_ble)

1. Double-press XIAO reset to enter Adafruit nRF52 bootloader (XIAO-SENSE
   drive appears).
2. Drag `.uf2` onto it. Left half ← left firmware, right half ← right
   firmware.
3. Bluetooth issues: flash `settings_reset`, then re-flash normal firmware.