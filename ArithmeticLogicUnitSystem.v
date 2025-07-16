`timescale 1ns / 1ps

module ArithmeticLogicUnitSystem(

    // RF control
    input  wire [2:0]  RF_OutASel,
    input  wire [2:0]  RF_OutBSel,
    input  wire [2:0]  RF_FunSel,
    input  wire [3:0]  RF_RegSel,
    input  wire [3:0]  RF_ScrSel,

    // ALU control
    input  wire [4:0]  ALU_FunSel,
    input  wire        ALU_WF,

    // ARF control
    input  wire [1:0]  ARF_OutCSel,
    input  wire [1:0]  ARF_OutDSel,
    input  wire [1:0]  ARF_FunSel,
    input  wire [2:0]  ARF_RegSel,

    // IR/Mem control
    input  wire        IR_LH,
    input  wire        IR_Write,
    input  wire        Mem_WR,
    input  wire        Mem_CS,

    // DR control
    input  wire [1:0]  DR_FunSel,
    input  wire        DR_E,

    // Mux selects
    input  wire [1:0]  MuxASel,
    input  wire [1:0]  MuxBSel,
    input  wire [1:0]  MuxCSel,
    input  wire        MuxDSel,

    // Shared clock
    input  wire        Clock,

    // Outputs
    output wire [31:0] OutA,
    output wire [31:0] OutB,
    output wire [31:0] ALUOut,
    output wire [31:0] MuxAOut,
    output wire [31:0] MuxBOut,
    output wire [7:0]  MuxCOut,
    output wire [31:0] MuxDOut,
    output wire [15:0] OutC,
    output wire [15:0] Address,
    output wire [7:0]  MemOut,
    output wire [15:0] IROut,
    output wire [31:0] DROut
);

    // Internal connections
    wire [31:0] RF_OutA, RF_OutB;
    wire [15:0] ARF_OutC, ARF_OutD;
    wire [31:0] ALU_WireOut;
    wire [3:0]  ALU_Flags;
    wire [7:0]  MemInt;

    // Mux logics depend on the informations from given pdf
    assign MuxAOut = (MuxASel==2'b00) ? ALU_WireOut            
                     : (MuxASel==2'b01) ? {16'd0, ARF_OutC}      
                     : (MuxASel==2'b10) ? DROut                  
                     : {24'd0, IROut[7:0]};                     

    assign MuxBOut = (MuxBSel==2'b00) ? ALU_WireOut            
                     : (MuxBSel==2'b01) ? {16'd0, ARF_OutC}      
                     : (MuxBSel==2'b10) ? DROut                  
                     : {24'd0, IROut[7:0]};                     

    assign MuxCOut = (MuxCSel==2'b00) ? ALU_WireOut[7:0]      
                     : (MuxCSel==2'b01) ? ALU_WireOut[15:8]     
                     : (MuxCSel==2'b10) ? ALU_WireOut[23:16]    
                     : ALU_WireOut[31:24];                    

    assign MuxDOut = (MuxDSel==1'b0)   ? RF_OutA               
                     : {16'd0, ARF_OutC};                  

    // Component instantiations
    RegisterFile         RF  (
        .I      (MuxAOut),
        .RegSel (RF_RegSel),
        .ScrSel (RF_ScrSel),
        .FunSel (RF_FunSel),
        .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),
        .OutA   (RF_OutA),
        .OutB   (RF_OutB),
        .Clock  (Clock)
    );

    AddressRegisterFile  ARF (
        .I      (MuxBOut),
        .RegSel (ARF_RegSel),
        .FunSel (ARF_FunSel),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .OutC   (ARF_OutC),
        .OutD   (ARF_OutD),
        .Clock  (Clock)
    );

    InstructionRegister  IR  (
        .I      (MemInt),
        .LH     (IR_LH),
        .Write  (IR_Write),
        .Clock  (Clock),
        .IROut  (IROut)
    );

    DataRegister         DR  (
        .I      (MuxCOut),
        .E      (DR_E),
        .FunSel (DR_FunSel),
        .Clock  (Clock),
        .DROut  (DROut)
    );

    Memory               MEM (
        .Address(ARF_OutD),
        .Data   (MuxCOut),
        .WR     (Mem_WR),
        .CS     (Mem_CS),
        .Clock  (Clock),
        .MemOut (MemInt)
    );

    // Instantiate ALU without Cin(carry in)
    ArithmeticLogicUnit  ALU (
        .A       (MuxDOut),
        .B       (RF_OutB),
        .FunSel  (ALU_FunSel),
        .WF      (ALU_WF),
        .Clock   (Clock),
        .ALUOut  (ALU_WireOut),
        .FlagsOut(ALU_Flags)
    );

    // Expose outputs
    assign OutA   = RF_OutA;
    assign OutB   = RF_OutB;
    assign ALUOut = ALU_WireOut;
    assign OutC   = ARF_OutC;
    assign Address= ARF_OutD;
    assign MemOut = MemInt;
endmodule
