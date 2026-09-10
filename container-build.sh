#!/bin/bash
# Runs inside the zmk-build-arm container, cwd = /workspace (persistent west volume).
# Repo is mounted at /src (read-only); artifacts at /output.
set -euo pipefail
cd /workspace
export ZEPHYR_SDK_INSTALL_DIR=${ZEPHYR_SDK_INSTALL_DIR:-/opt/zephyr-sdk-0.16.3}

# /workspace is a persistent volume. Refresh both repo inputs from /src every
# run, otherwise a stale config/ or boards/ is compiled silently.
rm -rf /workspace/config /workspace/toucan-module
mkdir -p /workspace/config /workspace/toucan-module
cp -r /src/config/. /workspace/config/
cp -r /src/boards /src/zephyr /workspace/toucan-module/

if [ ! -d .west ]; then
  west init -l config
fi
west update --fetch-opt=--filter=tree:0
west zephyr-export
# Flags mirror CI (zmk build-user-config.yml): the repo is a ZMK module
# (zephyr/module.yml -> board_root: .) and config/ is the user config dir, so
# config/toucan.keymap is the keymap that gets compiled.
ZMK_ARGS=(-DZMK_CONFIG=/workspace/config -DZMK_EXTRA_MODULES=/workspace/toucan-module)
west build -s zmk/app -d build/left -b seeeduino_xiao_ble -S studio-rpc-usb-uart -- \
  -DSHIELD="toucan_left rgbled_adapter nice_view_gem" "${ZMK_ARGS[@]}" -DCONFIG_ZMK_STUDIO=y
west build -s zmk/app -d build/right -b seeeduino_xiao_ble -- \
  -DSHIELD="toucan_right rgbled_adapter" "${ZMK_ARGS[@]}"
west build -s zmk/app -d build/settings_reset -b seeeduino_xiao_ble -- \
  -DSHIELD="settings_reset" "${ZMK_ARGS[@]}"
cp build/left/zephyr/zmk.uf2        /output/toucan_left-seeeduino_xiao_ble-zmk.uf2
cp build/right/zephyr/zmk.uf2       /output/toucan_right-seeeduino_xiao_ble-zmk.uf2
cp build/settings_reset/zephyr/zmk.uf2 /output/settings_reset-seeeduino_xiao_ble-zmk.uf2
echo BUILD_DONE