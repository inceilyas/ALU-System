`timescale 1ns / 1ps

module Register16bit(
    input wire [15:0] I,        // input
    input wire E,               // enable
    input wire [1:0] FunSel,    // function select bits
    input wire Clock,           // clock signal
    output reg [15:0] Q         // output
);

    always @(posedge Clock) begin
        if (E) begin
            //functions for given table
            case (FunSel)
                2'b00: Q <= Q - 1;       // Decrement
                2'b01: Q <= Q + 1;       // Increment
                2'b10: Q <= I;           // Load
                2'b11: Q <= 16'b0;       // Clear
            endcase
        end
    end

endmodule
