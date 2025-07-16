`timescale 1ns / 1ps

module InstructionRegister(
    input wire [7:0] I,         // input
    input wire Write,           // write signal
    input wire LH,              // 0->LSB, 1->MSB
    input wire Clock,           // clock
    output reg [15:0] IROut     // output for 16 IRout
);

    always @(posedge Clock) begin
        if (Write) begin
            if (LH == 0)
                IROut[7:0] <= I;         // load LSB
            else
                IROut[15:8] <= I;        // load MSB
        end
    end

endmodule
