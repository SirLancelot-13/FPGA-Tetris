#!/usr/bin/env bash
# Compile and run every testbench with Icarus Verilog.
# Usage: ./run_all.sh [name ...]   (e.g. ./run_all.sh uart_tx line_clear)
set -u
cd "$(dirname "$0")"

ROOT=..
LOGIC=$ROOT/tetris_logic
BUILD=${BUILD_DIR:-build}
mkdir -p "$BUILD"

# testbench name -> design sources
declare -A SRC=(
    [uart_tx]="$ROOT/uart_proto/uart_tx.v"
    [uart_rx]="$ROOT/uart_proto/uart_rx.v"
    [uart_loopback]="$ROOT/uart_proto/uart_tx.v $ROOT/uart_proto/uart_rx.v"
    [packetizer]="$LOGIC/packetizer.v $ROOT/uart_proto/uart_tx.v"
    [clock_gen]="$LOGIC/clock_gen.v"
    [lfsr]="$LOGIC/spawn_tetrimino/lfsr.v"
    [spawn_tetrimino]="$LOGIC/spawn_tetrimino/spawn_tetrimino.v $LOGIC/spawn_tetrimino/lfsr.v"
    [tetrimino_gravity]="$LOGIC/move_tetrimino/tetrimino_gravity.v"
    [move_tetrimino_down]="$LOGIC/move_tetrimino/move_tetrimino_down.v"
    [move_tetrimino_sideways]="$LOGIC/move_tetrimino/move_tetrimino_sideways.v"
    [rotate_tetrimino]="$LOGIC/move_tetrimino/rotate_tetrimino.v"
    [line_clear]="$LOGIC/line_clear.v"
    [main]="$BUILD/main_iverilog.v $LOGIC/clock_gen.v $LOGIC/line_clear.v $LOGIC/packetizer.v $LOGIC/spawn_tetrimino/spawn_tetrimino.v $LOGIC/spawn_tetrimino/lfsr.v $LOGIC/move_tetrimino/tetrimino_gravity.v $LOGIC/move_tetrimino/move_tetrimino_down.v $LOGIC/move_tetrimino/move_tetrimino_sideways.v $LOGIC/move_tetrimino/rotate_tetrimino.v $ROOT/uart_proto/uart_tx.v"
)
ORDER=(uart_tx uart_rx uart_loopback packetizer clock_gen lfsr spawn_tetrimino \
       tetrimino_gravity move_tetrimino_down move_tetrimino_sideways rotate_tetrimino line_clear main)

# Icarus rejects a net list that mixes plain names with `name = expr` items, e.g.
#   wire game_clk, wkey = pb[0], ...
# which other tools accept. Compile a patched copy of main.v rather than touch the design.
sed 's/^wire game_clk, wkey = /wire game_clk; wire wkey = /' "$LOGIC/main.v" > "$BUILD/main_iverilog.v"

names=("$@")
[ ${#names[@]} -eq 0 ] && names=("${ORDER[@]}")

failed=()
for n in "${names[@]}"; do
    if [ -z "${SRC[$n]+x}" ]; then echo "unknown testbench: $n"; failed+=("$n"); continue; fi
    tb=${n}_tb.v
    if ! iverilog -g2012 -Wall -Wno-timescale -Wno-sensitivity-entire-array -I . -I "$LOGIC" -I "$LOGIC/move_tetrimino" -I "$LOGIC/spawn_tetrimino" \
            -o "$BUILD/$n.vvp" "$tb" ${SRC[$n]} 2>"$BUILD/$n.compile.log"; then
        echo "COMPILE ERROR: $n"; cat "$BUILD/$n.compile.log"; failed+=("$n"); continue
    fi
    out=$(cd "$BUILD" && timeout 300 vvp -n "$n.vvp" 2>&1)
    echo "$out"
    echo "$out" | grep -q "^PASS: " || failed+=("$n")
done

echo
if [ ${#failed[@]} -eq 0 ]; then echo "All testbenches passed."; else echo "FAILED: ${failed[*]}"; exit 1; fi
