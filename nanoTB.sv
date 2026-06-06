module nanoCPU_TB;

  timeunit 1ns;
  timeprecision 1ps;

  logic ck, rst;
  logic [15:0] dataR, dataW;
  logic [7:0] address;
  logic we, ce;

  // Memory array signal for 256 x 16-bit positions
  typedef logic [15:0] memory_array_t [0:255];
  typedef logic [15:0] memory_array_1 [0:255];
  typedef logic [15:0] memory_array_2 [0:255];

  memory_array_1 memory1 = '{ // nanoCPU
    0: 'h01E0, // R0 = PMEM[30]
    1: 'h01F1, // R1 = PMEM[31]
    2: 'h0202, // R2 = PMEM[32]
    3: 'h0213, // R3 = PMEM[33]
    4: 'h6003,
    5: 'h5101,
    6: 'h4300,
    7: 'h7210,
    8: 'h10F0,
    9: 'h1101,
    10: 'h1112, // store R2 in 11
    11: 'h3FF2, // branch to 255 (hFF) if R2=1
    20: 'h8000, // INC R0
    21: 'h8110, // INC R1
    22: 'h9220, // DEC R2
    23: 'h9330, // DEC R3
    24: 'hF000, // FIM
    30: 'h1111,
    31: 'h2222,
    32: 'h3333,
    33: 'h4444,
    255: 'h2140, // unconditional jump to 20 (h14)
    default: 'h0000 
  };

  memory_array_2 memory2 = '{ // do while (i < 10)
    0:  'h4000,
    1:  'h4111,
    2:  'h0093,
    3:  'h6110,
    4:  'h8000,
    5:  'h7203,
    6:  'h3032,
    7:  'h10A1,
    8:  'hF000,
    9:  'h000A,
    default: 'h0000
  };

  memory_array_t memory = '{
    0:  'h0231, // R1 <- PMEM(35) Le o dividendo
    1:  'h0242, // R2 <- PMEM(36) Le o divisor
    2:  'h4311, // R3 <- RS1 xor RS1 (0)
    3:  'h8330, // R3 <- R3 + 1 (1)
    4:  'h7023, // R0 <- 1 if R2 < R3 (R2 < 1)
    5:  'h31A0, // branch to 34 (end) if R0 = 1
    6:  'h0250, // R0 <- PMEM(37) quociente recebe 0

    // LOOP
    7:  'h0253, // R3 <- PMEM(37) recebe 0
    8:  'h5112, // R1 <- R1 - R2
    9:  'h7313, // R3 <- 1 if R1 < R3 (R1 < 0)
    10: 'h3173, // branch to 23 (save) if R3 = 1
    11: 'h8000, // INC R0
    12: 'h2070, // jump to 7 (loop)

    // SAVE
    23: 'h6112, // R1 <- R1 + R2
    24: 'h1200, // grava o quociente no endereço 32
    25: 'h1211, // grava o resto no endereço 33
    26: 'hF000, // FIM

    32: 'h0000, // quociente
    33: 'h0000, // resto
    35: 'd100, // dividendo
    36: 'd22, // divisor
    37: 'd0, // 0
    default: 'h0000
  };

  always #1 ck = ~ck;

  NanoCPU CPU ( .ck(ck), .rst(rst), .address(address), .dataR(dataR), .dataW(dataW), .ce(ce), .we(we) );

  always_ff @(posedge ck) begin  // Write to memory
    if (we) begin
      memory[address] <= dataW;
    end
  end
  
  assign dataR = memory[address];   // Read from memory

    // Generate clock and reset signals
  initial begin
    ck = 1'b0;
    rst = 1'b1;
    #2 rst = 1'b0;
  end

endmodule