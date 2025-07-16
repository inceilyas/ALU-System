`timescale 1ns / 1ps

module Register32bit(
    input wire [31:0] I,         // input
    input wire E,                // enable
    input wire [2:0] FunSel,     // function select bits
    input wire Clock,            // clock, it triggers for rising edge
    output reg [31:0] Q          // output
);

    always @(posedge Clock) begin
        if (E) begin
            //functions depend on informations from given table
            case (FunSel)
                3'b000: Q <= Q - 1;                                       // Decrement
                3'b001: Q <= Q + 1;                                       // Increment
                3'b010: Q <= I;                                           // Load
                3'b011: Q <= 32'b0;                                       // Clear
                3'b100: Q <= {24'b0, I[7:0]};                             // Lower 8-bit load
                3'b101: Q <= {16'b0, I[15:0]};                            // Lower 16-bit load
                3'b110: Q <= {Q[23:0], I[7:0]};                           // 8-bit left shift + I[7:0]
                3'b111: Q <= {{16{I[15]}}, I[15:0]};                      // Sign-extend I[15:0]
            endcase
        end
    end

endmodule
