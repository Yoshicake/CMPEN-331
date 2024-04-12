`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2024 12:42:39 PM
// Design Name: 
// Module Name: testbench
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


module testbench();
    reg clk;
    
    wire [31:0] pc;
    wire [31:0] dinstOut;
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire [3:0] ealuc;
    wire ealuimm;
    wire [4:0] edestReg;
    wire [31:0] eqa;
    wire [31:0] eqb;
    wire [31:0] eimm32;
    
    wire mwreg;
    wire mm2reg;
    wire mwmem;
    wire[4:0] mdestReg;
    wire[31:0] mr;
    wire[31:0] mqb;
    wire[31:0] mdo;
    wire wwreg;
    wire wm2reg;
    wire[4:0] wdestReg;
    wire[31:0] wr;
    wire[31:0] wdo;
    
    initial
    begin
        clk <= 1'b0;
    end
    
    DataPath datapath(clk, pc, dinstOut, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32,
                mwreg, mm2reg, mwmem, mdestReg, mr, mqb, mdo, wwreg, wm2reg, wdestReg, wr, wdo);
    
    always
    begin
        #10;
        clk <= ~clk;
    end
    
endmodule
