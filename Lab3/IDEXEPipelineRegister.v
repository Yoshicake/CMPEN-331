`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2024 01:14:40 PM
// Design Name: 
// Module Name: IDEXEPipelineRegister
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IDEXEPipelineRegister(wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32, clk,
    ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    
    input wreg;
    input m2reg;
    input wmem;
    input [3:0] aluc;
    input aluimm;
    input [4:0] destReg;
    input [31:0] qa;
    input [31:0] qb;
    input [31:0] imm32;
    input clk;
    
    output reg ewreg;
    output reg em2reg;
    output reg ewmem;
    output reg [3:0] ealuc;
    output reg ealuimm;
    output reg [4:0] edestReg;
    output reg [31:0] eqa;
    output reg [31:0] eqb;
    output reg [31:0] eimm32;
    
    always @ (posedge clk)
    begin
        ewreg = wreg;
        em2reg = m2reg;
        ewmem = wmem;
        ealuc = aluc;
        ealuimm = aluimm;
        edestReg = destReg;
        eqa = qa;
        eqb = qb;
        eimm32 = imm32;
    end
endmodule

