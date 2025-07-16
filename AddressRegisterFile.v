`timescale 1ns / 1ps

module AddressRegisterFile(
    input wire [31:0] I,                   // input port
    input wire [1:0] FunSel,               // function select
    input wire [2:0] RegSel,               // register select
    input wire [1:0] OutCSel, OutDSel,     // select bits for output
    input wire Clock,                      // clock signal
    output wire [15:0] OutC, OutD,         // output ports
    output wire [15:0] PC_Q, SP_Q, AR_Q    // ports for testbench
);

    // register instances
    Register16bit PC(.I(I[15:0]), .E(RegSel[2]), .FunSel(FunSel), .Clock(Clock), .Q(PC_Q));
    Register16bit SP(.I(I[15:0]), .E(RegSel[1]), .FunSel(FunSel), .Clock(Clock), .Q(SP_Q));
    Register16bit AR(.I(I[15:0]), .E(RegSel[0]), .FunSel(FunSel), .Clock(Clock), .Q(AR_Q));

    // OutC select
    assign OutC = (OutCSel == 2'b00) ? PC_Q :
                  (OutCSel == 2'b01) ? SP_Q :
                                       AR_Q;

    // OutD select
    assign OutD = (OutDSel == 2'b00) ? PC_Q :
                  (OutDSel == 2'b01) ? SP_Q :
                                       AR_Q;

endmodule
