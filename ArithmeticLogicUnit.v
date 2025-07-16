`timescale 1ns / 1ps
module ArithmeticLogicUnit(
    input  [31:0] A, //input A
    input  [31:0] B, //input B
    input  [4:0]  FunSel, //function select
    input         WF, //WF
    input         Clock, //clock
    output reg [31:0] ALUOut, //Out port for ALU
    output reg [3:0]  FlagsOut  // {Z, C, N, O} //defined flags as register
);

// extended result for carry/overflow detection -it will help us to write rest of the code
reg [32:0] ext;

always @(*) begin
    // default to unknown to avoid errors
    ALUOut = 32'hxxxx_xxxx;
    case (FunSel)
        // 16-bit operations: zero-extend to 32 bits
        5'b00000: ALUOut = {16'h0000, A[15:0]};            // lower bits - half A
        5'b00001: ALUOut = {16'h0000, B[15:0]};            // lower bits - half B
        5'b00010: ALUOut = {16'h0000, ~A[15:0]};           // NOT A low
        5'b00011: ALUOut = {16'h0000, ~B[15:0]};           // NOT B low
        5'b00100: begin                                     // lower bits - A+B
            ext    = {1'b0, A[15:0]} + {1'b0, B[15:0]};
            ALUOut = {16'h0000, ext[15:0]};
        end
        5'b00101: begin                                     // A+B+carry low
            ext    = {1'b0, A[15:0]} + {1'b0, B[15:0]} + FlagsOut[2];
            ALUOut = {16'h0000, ext[15:0]};
        end
        5'b00110: begin                                     // A-B low 
            ext    = {1'b0, A[15:0]} + {1'b0, ~B[15:0]} + 1;
            ALUOut = {16'h0000, ext[15:0]};
        end
        5'b00111: ALUOut = {24'h000000, A[7:0] & B[7:0]};  // AND low
        5'b01000: ALUOut = {24'h000000, A[7:0] | B[7:0]};  // OR low
        5'b01001: ALUOut = {24'h000000, A[7:0] ^ B[7:0]};  // XOR low
        5'b01010: ALUOut = {24'h000000, ~(A[7:0] & B[7:0])}; // NAND low
        5'b01011: ALUOut = {24'h000000, A[7:0] << 1};      // LSL low (carry bit handled in flags)
        5'b01100: ALUOut = {24'h000000, A[7:0] >> 1};      // LSR low
        5'b01101: ALUOut = {24'h000000, A[7:0] >>> 1};     // ASR low
        5'b01110: ALUOut = {24'h000000, {A[6:0], FlagsOut[2]}}; // CSL low
        5'b01111: ALUOut = {24'h000000, {FlagsOut[2], A[7:1]}}; // CSR low

        // 32-bit operations
        5'b10000: ALUOut = A;
        5'b10001: ALUOut = B;
        5'b10010: ALUOut = ~A;
        5'b10011: ALUOut = ~B;
        5'b10100: begin                                   // A+B 32-bit
            ext    = {1'b0, A} + {1'b0, B};
            ALUOut = ext[31:0];                          
        end
        5'b10101: begin                                   // A+B+carry 32-bit
            ext    = {1'b0, A} + {1'b0, B} + FlagsOut[2];
            ALUOut = ext[31:0];                          
        end
        5'b10110: begin                                   // A-B 32-bit
            ext    = {1'b0, A} + {1'b0, ~B} + 1;
            ALUOut = ext[31:0];                          
        end
        5'b10111: ALUOut = A & B;
        5'b11000: ALUOut = A | B;
        5'b11001: ALUOut = A ^ B;
        5'b11010: ALUOut = ~(A & B);
        5'b11011: ALUOut = A << 1;
        5'b11100: ALUOut = A >> 1;
        5'b11101: ALUOut = A >>> 1;
        5'b11110: ALUOut = {A[30:0], FlagsOut[2]};
        5'b11111: ALUOut = {FlagsOut[2], A[31:1]};
    endcase
end

// Flag calculation on clock
always @(posedge Clock) begin
    if (WF) begin
        // default - no change for C and O unless arithmetic
        case (FunSel)
            // update only C and Z 
            5'b00000,5'b00001,5'b00010,5'b00011,
            5'b00111,5'b01000,5'b01001,5'b01010,
            5'b01100,5'b01101,5'b01110,5'b01111,
            5'b10000,5'b10001,5'b10010,5'b10011: begin
                FlagsOut[3] <= (ALUOut == 0);
                FlagsOut[1] <= ALUOut[31];
            end
            // addition/substraction for 16-bit
            5'b00100,5'b00101,5'b00110: begin
                FlagsOut[3] <= ((ALUOut & 32'h0000_FFFF) == 0);
                FlagsOut[1] <= ALUOut[15];
                FlagsOut[2] <= ext[16];
                FlagsOut[0] <= (FunSel!=5'b00110) ?
                                (A[15]==B[15] && A[15]!=ALUOut[15]) :
                                (A[15]!=B[15] && B[15]==ALUOut[15]);
            end
            // addition/substraction 32-bit
            5'b10100,5'b10101,5'b10110: begin
                FlagsOut[3] <= (ALUOut == 0);
                FlagsOut[1] <= ALUOut[31];
                FlagsOut[2] <= ext[32];
                FlagsOut[0] <= (A[31]==B[31] && A[31]!=ALUOut[31]);
            end
            // shifts: update Z, N, C flags
            5'b01011,5'b01110,5'b11011,5'b11110: begin
                FlagsOut[3] <= (ALUOut == 0);
                FlagsOut[1] <= ALUOut[31];
                // capture bit shifted out (MSB for left)
                FlagsOut[2] <= FunSel[3] ? A[7] : A[31];
                FlagsOut[0] <= 0;
            end
            // logical right
            5'b01100,5'b11100: begin
                FlagsOut[3] <= (ALUOut == 0);
                FlagsOut[1] <= ALUOut[31];
                FlagsOut[2] <= A[0];
                FlagsOut[0] <= 0;
            end
            // arithmetic right
            5'b01101,5'b11101: begin
                FlagsOut[3] <= (ALUOut == 0);
                FlagsOut[1] <= ALUOut[31];
                FlagsOut[2] <= A[0];
                FlagsOut[0] <= 0;
            end
        endcase
    end
end
endmodule
