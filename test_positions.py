#!/usr/bin/env python3
"""Check KEYS_L/KEYS_R in the keymap match this board's row-major halves.

Position numbering (toucan.dtsi transform, row-major):
0-11 top row, 12-23 home row, 24-35 bottom row; thumbs 36-41 appended at call sites.
Left half = cols 0-5 of each row; right half = cols 6-11.
"""

import re
from pathlib import Path

KEYMAP = Path("config/toucan.keymap").resolve()

expected_left = set(range(0, 6)) | set(range(12, 18)) | set(range(24, 30))
expected_right = set(range(6, 12)) | set(range(18, 24)) | set(range(30, 36))


def parse(name):
    m = re.search(rf"#define {name} (.+?)(//|$)", KEYMAP.read_text())
    assert m, f"{name} not found in {KEYMAP}"
    return set(map(int, m.group(1).split()))


left, right = parse("KEYS_L"), parse("KEYS_R")

assert left == expected_left, f"KEYS_L wrong: {left ^ expected_left}"
assert right == expected_right, f"KEYS_R wrong: {right ^ expected_right}"
assert not (left & right), "KEYS_L and KEYS_R overlap"
print("OK: KEYS_L/KEYS_R match the row-major halves.")
