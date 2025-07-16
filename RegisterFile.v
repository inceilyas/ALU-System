`timescale 1ns / 1ps

module RegisterFile(
    input wire [31:0] I,                   // input
    input wire [2:0] FunSel,               // function select bits
    input wire [3:0] RegSel, ScrSel,       // write control signals
    input wire [2:0] OutASel, OutBSel,     // output selects for two different port (OutA and OutB)
    input wire Clock,                      // clock
    output wire [31:0] OutA, OutB,         // output ports
    output wire [31:0] R1_Q, R2_Q, R3_Q, R4_Q,
    output wire [31:0] S1_Q, S2_Q, S3_Q, S4_Q
);

    // additional function, it updates registers for given FunSel value
    function [31:0] ApplyFunction;
        input [31:0] val;
        input [31:0] data;
        input [2:0] fsel;
        begin
            case (fsel)
                3'b000: ApplyFunction = val - 1;
                3'b001: ApplyFunction = val + 1;
                3'b010: ApplyFunction = data;
                3'b011: ApplyFunction = 32'b0;
                3'b100: ApplyFunction = {24'b0, data[7:0]};
                3'b101: ApplyFunction = {16'b0, data[15:0]};
                3'b110: ApplyFunction = {val[23:0], data[7:0]};
                3'b111: ApplyFunction = {{16{data[15]}}, data[15:0]};
                default: ApplyFunction = val;
            endcase
        end
    endfunction

    // Register instances
    Register32bit R1(.I(I), .E(RegSel[3]), .FunSel(FunSel), .Clock(Clock), .Q(R1_Q));
    Register32bit R2(.I(I), .E(RegSel[2]), .FunSel(FunSel), .Clock(Clock), .Q(R2_Q));
    Register32bit R3(.I(I), .E(RegSel[1]), .FunSel(FunSel), .Clock(Clock), .Q(R3_Q));
    Register32bit R4(.I(I), .E(RegSel[0]), .FunSel(FunSel), .Clock(Clock), .Q(R4_Q));
    Register32bit S1(.I(I), .E(ScrSel[3]), .FunSel(FunSel), .Clock(Clock), .Q(S1_Q));
    Register32bit S2(.I(I), .E(ScrSel[2]), .FunSel(FunSel), .Clock(Clock), .Q(S2_Q));
    Register32bit S3(.I(I), .E(ScrSel[1]), .FunSel(FunSel), .Clock(Clock), .Q(S3_Q));
    Register32bit S4(.I(I), .E(ScrSel[0]), .FunSel(FunSel), .Clock(Clock), .Q(S4_Q));

    // OutA select
    assign OutA = (OutASel == 3'b000) ? R1_Q :
                  (OutASel == 3'b001) ? R2_Q :
                  (OutASel == 3'b010) ? R3_Q :
                  (OutASel == 3'b011) ? R4_Q :
                  (OutASel == 3'b100) ? S1_Q :
                  (OutASel == 3'b101) ? S2_Q :
                  (OutASel == 3'b110) ? S3_Q :
                                        S4_Q;

    // OutB select
    assign OutB = (OutBSel == 3'b000) ? R1_Q :
                  (OutBSel == 3'b001) ? R2_Q :
                  (OutBSel == 3'b010) ? R3_Q :
                  (OutBSel == 3'b011) ? R4_Q :
                  (OutBSel == 3'b100) ? S1_Q :
                  (OutBSel == 3'b101) ? S2_Q :
                  (OutBSel == 3'b110) ? S3_Q :
                                        S4_Q;

endmodule