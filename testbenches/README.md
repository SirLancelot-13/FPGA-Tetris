# Testbenches

All tests in this directory are generated completely by AI, since these don't have much to do with synthesis and implementation, rather with simulation.

Self-checking [Icarus Verilog](https://steveicarus.github.io/iverilog/) benches. Each prints `PASS: <name>` or `FAIL: ...` lines.

```sh
./run_all.sh                 # everything (~1 s)
./run_all.sh line_clear uart_rx   # just some
```

Build output goes to `build/` (git-ignored). `gtkwave` is in the devenv if you want waveforms: add `$dumpfile`/`$dumpvars` to a bench.

| Bench | Covers |
| --- | --- |
| `uart_tx_tb` | framing, LSB-first bit order, bit timing, one `tx_done` pulse per byte |
| `uart_rx_tb` | frames, glitch rejection, back-to-back bytes, async reset |
| `uart_loopback_tb` | all 256 byte values `uart_tx` -> `uart_rx` |
| `packetizer_tb` | 37-byte packet layout, CRC-16, send-on-change, heartbeat (real `uart_tx`, decoded off the wire) |
| `clock_gen_tb` | 25M-clock half period constant, toggle timing (divider forced short) |
| `lfsr_tb` | never emits the invalid id, all 7 ids appear |
| `spawn_tetrimino_tb` | exact cells + centre for every piece, game-over rows, pass-through |
| `tetrimino_gravity_tb` | falling, locking on floor / dead blocks, state hand-off |
| `move_tetrimino_down_tb`, `move_tetrimino_sideways_tb` | movement, walls, dead-block collisions |
| `rotate_tetrimino_tb` | rotation results, 4x rotation identity, floor/wall/ceiling/dead-block rejection |
| `line_clear_tb` | 0-4 line clears, score table, gaps, pass-through states |
| `main_tb` | whole game through `main`: spawn, gravity, buttons, line clear, game over, UART stream |

`tb_util.vh` holds the shared `check`/grid helpers.

## Simulator notes

- `main.v` has `wire game_clk, wkey = pb[0], ...`, which Icarus rejects; `run_all.sh` compiles a patched copy from `build/`.
- `packetizer_tb` still re-times `tx_done` on the falling edge; this is no longer needed now that `uart_tx` uses a nonblocking `tx_done`, but it is harmless.
