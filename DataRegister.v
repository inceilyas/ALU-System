`timescale 1ns / 1ps

module DataRegister(
    input wire [7:0] I,         // input
    input wire E,               // enable
    input wire [1:0] FunSel,    // function select bits
    input wire Clock,           // clock
    output reg [31:0] DROut     // output for 32bit DROut
);

    always @(posedge Clock) begin
        if (E) begin
            //functions for given table from pdf
            case (FunSel)
                2'b00: DROut <= {{24{I[7]}}, I};           // Sign extend (8-bit signed)
                2'b01: DROut <= {24'b0, I};                // clear upper bits
                2'b10: DROut <= {DROut[23:0], I};          // 8 bit shift left
                2'b11: DROut <= {I, DROut[31:8]};          // 8 bit shift right
            endcase
        end
    end

endmodule
