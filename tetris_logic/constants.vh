`ifndef CONSTANTS_VH
`define CONSTANTS_VH

`define BOARD_WIDTH 10
`define BOARD_HEIGHT 12 // 2 extra layers for spawning tetriminos

`define SPAWN_STATE 2'b00
`define MOVE_STATE 2'b01
`define CLEAR_STATE 2'b10
`define GAMEOVER_STATE 2'b11

`define EMPTY_BLOCK 2'b00
`define DEAD_TETRIMINO_BLOCK 2'b01
`define ACTIVE_TETRIMINO_BLOCK 2'b10

`define IID 3'b000
`define JID 3'b001
`define LID 3'b010
`define OID 3'b011
`define SID 3'b100
`define ZID 3'b101
`define TID 3'b110
`define INVALID_ID 3'b111

`endif
