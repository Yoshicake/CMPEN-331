`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2024 10:31:44 AM
// Design Name: 
// Module Name: Lab3
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
// Grant Allen
//////////////////////////////////////////////////////////////////////////////////


module ProgramCounter(nextPc, clk, pc);
    input [31:0] nextPc;
    input clk;
    output reg [31:0] pc;
    
    initial
    begin
        pc = 32'd100;
    end
    
    always @(posedge clk)
    begin
        pc <= nextPc;
    end
    
endmodule
/////////////////////////////////////////////////////////////////////////////////
module InstructionMemory(pc, instOut);
    input [31:0] pc;
    output reg [31:0] instOut;
    reg [31:0] memory [0:63];
    
    initial
    begin
        memory[25] = {6'b100011, 5'b00001,5'b00010,16'b0000000000000000}; 
        memory[26] = {6'b100011, 5'b00001,5'b00011,16'b0000000000000100}; 
    end
    
    always @(*)
    begin
        instOut = memory[pc[7:2]];
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////  
module PcAdder(pc, nextPc);
    input [31:0] pc;
    output reg [31:0] nextPc;
    
    always @(*)
    begin
        nextPc = pc + 32'h4;
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////
module ifidPipelineRegister(instOut, clk, dinstOut);
    input [31:0] instOut;
    input clk;
    output reg [31:0] dinstOut;
    
    
    always @ (posedge clk)
    begin
        dinstOut <= instOut;
    end
endmodule

/////////////////////////////////////////////////////////////////////////////////
module ControlUnit(op, func, wreg, m2reg, wmem, aluc, aluimm, regrt);
    input [5:0] op; // bits 31:26 of dinstOut
    input [5:0] func; // bits 5:0 of dinstOut
    output reg wreg;
    output reg m2reg;
    output reg wmem;
    output reg [3:0] aluc;
    output reg aluimm;
    output reg regrt;
    
    always @(*) 
    begin
        case (op)
            6'b000000:
            begin
                case (func)
                // add
                    6'b100000:
                    begin
                        wreg <= 1'b1;
                        m2reg <= 1'b0;
                        wmem <= 1'b0;
                        aluc <= 4'b0010;
                        aluimm <= 1'b0;
                        regrt <= 1'b1;
                    end
                    default:
                    begin
                        wreg <= 1'b0;
                        m2reg <= 1'b0;
                        wmem <= 1'b0;
                        aluc <= 4'b0000;
                        aluimm <= 1'b0;
                        regrt <= 1'b0;
                    end
                endcase
            end
            // lw
            6'b100011:
            begin
                wreg <= 1'b1;
                m2reg <= 1'b1;
                wmem <= 1'b0;
                aluc <= 4'b0010;
                aluimm <= 1'b1;
                regrt <= 1'b1;
            end
            default:
            begin
                wreg <= 1'b0;
                m2reg <= 1'b0;
                wmem <= 1'b0;
                aluc <= 4'b0000;
                aluimm <= 1'b0;
                regrt <= 1'b0;
            end
        endcase
     end    
endmodule
/////////////////////////////////////////////////////////////////////////////////
module RegrtMultiplexer(rt, rd, regrt, destReg);
    input [4:0] rt; // bits 20:16 of dinstOut
    input [4:0] rd; // bits 15:11 of dinstOut
    input regrt;
    output reg [4:0] destReg;
    
    always @(*) 
    begin
        case(regrt)
            1'b0:
                begin
                   destReg = rd; 
                end
            1'b1:
                begin
                    destReg = rt;
                end
        endcase
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////  
module RegisterFile(rs,rt,qa,qb);
    input [4:0] rs;
    input [4:0] rt; 
    output reg [31:0] qa;
    output reg [31:0] qb;
    
    reg [31:0] registers [0:31];
    
    integer i;
    initial 
    begin
        for (i = 0; i <= 31; i = i + 1) 
        begin
            registers[i] = 0;
        end
    end
    
    always @(*) 
    begin
        qa = registers[rs];
        qb = registers[rt];
    end
    
endmodule
/////////////////////////////////////////////////////////////////////////////////
module ImmExtender(imm, imm32);
    input [15:0] imm; // 15:0 from dinstOut
    output reg [31:0] imm32;
    
    always @(*)
    begin
        imm32[31:0] = {{16{imm[15]}},{imm[15:0]}};
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////
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
        ewreg <= wreg;
        em2reg <= m2reg;
        ewmem <= wmem;
        ealuc <= aluc;
        ealuimm <= aluimm;
        edestReg <= destReg;
        eqa <= qa;
        eqb <= qb;
        eimm32 <= imm32;
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////
module DataPath(clk, pc, dinstOut, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    input clk;
    
    output wire [31:0] pc;
    output wire [31:0] dinstOut;
    output wire ewreg;
    output wire em2reg;
    output wire ewmem;
    output wire [3:0] ealuc;
    output wire ealuimm;
    output wire [4:0] edestReg;
    output wire [31:0] eqa;
    output wire [31:0] eqb;
    output wire [31:0] eimm32;
    
    wire[31:0] nextPc;
    wire[31:0] instOut;
    wire wreg;
    wire m2reg;
    wire wmem;
    wire[3:0] aluc;
    wire aluimm;
    wire regrt;
    wire[4:0] destReg;
    wire[31:0] qa;
    wire[31:0] qb;
    wire[31:0] imm32;
    
    ProgramCounter programCounter(nextPc, clk, pc);
    InstructionMemory instructionMemory(pc, instOut);
    PcAdder pcAdder(pc, nextPc);
    ifidPipelineRegister ifid(instOut, clk, dinstOut);
    ControlUnit controlUnit(dinstOut[31:26], dinstOut[5:0], wreg, m2reg, wmem, aluc, aluimm, regrt);
    RegrtMultiplexer regRTMux(dinstOut[20:16], dinstOut[15:11], regrt, destReg);
    RegisterFile registerFile(dinstOut[25:21],dinstOut[20:16],qa,qb);
    ImmExtender immExtender(dinstOut[15:0], imm32);
    IDEXEPipelineRegister IDEXE(wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32, clk,
        ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);   
       
endmodule
