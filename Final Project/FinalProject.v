`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2024 10:31:44 AM
// Design Name: 
// Module Name: Lab5
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


module ProgramCounter(nextPc, clk,wpcir, pc);
    input [31:0] nextPc;
    input clk;
    input wpcir;
    output reg [31:0] pc;
    
    initial
    begin
        pc = 32'd100;
    end
    
    always @(posedge clk)
    begin
    if (1)
        begin
            pc <= nextPc;
        end
    end
    
endmodule
/////////////////////////////////////////////////////////////////////////////////
module InstructionMemory(pc, instOut);
    input [31:0] pc;
    output reg [31:0] instOut;
    reg [31:0] memory [0:31];
    
    initial
    begin
        memory[25] = {6'b000000, 5'b00001, 5'b00010, 5'b00011, 5'b00000, 6'b100000};
        memory[26] = {6'b000000, 5'b01001, 5'b00011, 5'b00100, 5'b00000, 6'b100010};
        memory[27] = {6'b000000, 5'b00011, 5'b01001, 5'b00101, 5'b00000, 6'b100101};
        memory[28] = {6'b000000, 5'b00011, 5'b01001, 5'b00110, 5'b00000, 6'b100110};
        memory[29] = {6'b000000, 5'b00011, 5'b01001, 5'b00111, 5'b00000, 6'b100100};
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
module ControlUnit(op, func, rs, rt, mdestReg, mm2reg, mwreg, edestReg, em2reg, ewreg, wreg, m2reg, wmem, aluc, aluimm, regrt, fwda, fwdb, wpcir);
    input [5:0] op; // bits 31:26 of dinstOut
    input [5:0] func; // bits 5:0 of dinstOut
    input [4:0] rs;   // bits 25:21 pf dinstOut
    input [4:0] rt;   // bits 20:16 of dinstOut
    input [4:0] mdestReg;
    input mm2reg;
    input mwreg;
    input [4:0] edestReg;
    input em2reg;
    input ewreg;
    output reg wreg;
    output reg m2reg;
    output reg wmem;
    output reg [3:0] aluc;
    output reg aluimm;
    output reg regrt;
    output reg [1:0] fwda;
    output reg [1:0] fwdb;
    output reg wpcir;
    
    always @(*) 
    
    begin
        wpcir = 1;
        fwda = 2'b00;
        fwdb = 2'b00;
        
        // forward from mem/wb
        if((mwreg == 1'b1) & (mdestReg == rs)) 
        begin
            fwda = 2'b10;
        end
        if((mwreg == 1'b1) & (mdestReg == rt)) 
        begin
            fwdb = 2'b10;
        end
        
        
        // forward from ex/mem
        if((ewreg == 1'b1) & (edestReg == rs)) 
        begin
            fwda = 2'b01;
        end
        if((ewreg == 1'b1) & (edestReg == rt)) 
        begin
            fwdb = 2'b01;
        end
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
                        regrt <= 1'b0;
                    end
                // sub
                    6'b100010:
                    begin
                        wreg <= 1'b1;
                        m2reg <= 1'b0;
                        wmem <= 1'b0;
                        aluc <= 4'b0110;
                        aluimm <= 1'b0;
                        regrt <= 1'b0; 
                    end  
                // and
                    6'b100100:
                    begin
                        wreg <= 1'b1;
                        m2reg <= 1'b0;
                        wmem <= 1'b0;
                        aluc <= 4'b0000;
                        aluimm <= 1'b0;
                        regrt <= 1'b0; 
                    end
                // or
                    6'b100101:
                    begin
                        wreg <= 1'b1;
                        m2reg <= 1'b0;
                        wmem <= 1'b0;
                        aluc <= 4'b0001;
                        aluimm <= 1'b0;
                        regrt <= 1'b0; 
                    end  
                // xor
                    6'b100110:
                    begin
                        wreg <= 1'b1;
                        m2reg <= 1'b0;
                        wmem <= 1'b0;
                        aluc <= 4'b1111;
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
                     
        endcase
     end    
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module fwdAMux(fwda, qa, r, mr, mdo, da);
    input [1:0] fwda;
    input [31:0] qa;
    input [31:0] r;
    input [31:0] mr;
    input [31:0] mdo;
    output reg [31:0] da;
    
    always @ (*)
    begin
        case(fwda)
            2'b00:
                begin
                    da = qa;
                end
            2'b01:
                begin
                    da = r;
                end
            2'b10:
                begin
                    da = mr;
                end
            2'b11:
                begin
                    da = mdo;
                end
         endcase
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////
module fwdBMux(fwdb, qb, r, mr, mdo, db);
    input [1:0] fwdb;
    input [31:0] qb;
    input [31:0] r;
    input [31:0] mr;
    input [31:0] mdo;
    output reg [31:0] db;
    
    always @(*) 
    begin
        case(fwdb)
            2'b00:
                begin
                    db = qb;
                end
            2'b01:
                begin
                    db = r;
                end
            2'b10:
                begin
                    db = mr;
                end
            2'b11:
                begin
                    db = mdo;
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
module RegisterFile(rs,rt,qa,qb,wdestReg,wbData,wwreg,clk);
    input [4:0] rs;
    input [4:0] rt; 
    input [4:0] wdestReg;
    input [31:0] wbData;
    input wwreg;
    input clk;
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
        registers[0] = 32'h00000000;
        registers[1] = 32'hA00000AA;
        registers[2] = 32'h10000011;
        registers[3] = 32'h20000022;
        registers[4] = 32'h30000033;
        registers[5] = 32'h40000044;
        registers[6] = 32'h50000055;
        registers[7] = 32'h60000066;
        registers[8] = 32'h70000077;
        registers[9] = 32'h80000088;
        registers[10] = 32'h90000099;
        
        
    end
    
    always @(*) 
    begin
        qa = registers[rs];
        qb = registers[rt];
    end
    
    always @(negedge clk)
    begin
        if (wwreg == 1)
        begin
            registers[wdestReg] <= wbData;
        end
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
module IDEXEPipelineRegister(wreg, m2reg, wmem, aluc, aluimm, destReg, da, db, imm32, clk,
    ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    
    input wreg;
    input m2reg;
    input wmem;
    input [3:0] aluc;
    input aluimm;
    input [4:0] destReg;
    input [31:0] da;
    input [31:0] db;
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
        eqa <= da;
        eqb <= db;
        eimm32 <= imm32;
    end
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////
module ALUMux(eqb, eimm32, ealuimm, b);
    input [31:0] eqb;
    input [31:0] eimm32;
    input ealuimm;
    output reg [31:0] b;
    
    always @(*)
    begin
        if (ealuimm == 0)
        begin
            b = eqb;
        end
        else
        begin
            b = eimm32;
        end
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////
module ALU(eqa, b, ealuc, r);
    input [31:0] eqa;
    input [31:0] b;
    input [3:0] ealuc;
    output reg [31:0] r;
    
    always @(*)
    begin
        case(ealuc)
            4'b0010:
            begin
                r = eqa + b;
            end
            4'b0110:
            begin
                r = eqa - b;
            end
            4'b0000:
            begin
                r = eqa & b;
            end
            4'b0001:
            begin
                r = eqa | b;
            end
            4'b1111:
            begin
                r = eqa ^ b;
            end
        endcase
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////
module EXEMEMPipelineRegister(ewreg, em2reg, ewmem, edestReg, r, eqb, 
        clk, mwreg, mm2reg, mwmem, mdestReg, mr, mqb);
        input ewreg;
        input em2reg;
        input ewmem;
        input [4:0] edestReg;
        input [31:0] r;
        input [31:0] eqb;
        input clk;
        output reg mwreg;
        output reg mm2reg;
        output reg mwmem;
        output reg [4:0] mdestReg;
        output reg [31:0] mr;
        output reg [31:0] mqb;
        
        
        always @(posedge clk)
        begin
            mwreg <= ewreg;
            mm2reg <= em2reg;
            mwmem <= ewmem;
            mdestReg <= edestReg;
            mr <= r;
            mqb <= eqb;
        end    
endmodule
/////////////////////////////////////////////////////////////////////////////////
module DataMemory(mr, mqb, mwmem, clk, mdo);
    input [31:0] mr;
    input [31:0] mqb;
    input mwmem;
    input clk;
    output reg [31:0] mdo;
    
    reg [31:0] dataMemory [0:31];
    
    initial
    begin
        dataMemory[0] = 32'hA00000AA;
        dataMemory[1] = 32'h10000011;
        dataMemory[2] = 32'h20000022;
        dataMemory[3] = 32'h30000033;
        dataMemory[4] = 32'h40000044;
        dataMemory[5] = 32'h50000055;
        dataMemory[6] = 32'h60000066;
        dataMemory[7] = 32'h70000077;
        dataMemory[8] = 32'h80000088;
        dataMemory[9] = 32'h90000099;
    end
    
    always @(*)
    begin
        mdo = dataMemory[mr>>2];
    end
    
    always @ (negedge clk)
    begin
        if (mwmem == 1)
        begin
            dataMemory[mr>>2] <= mqb;
        end
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////
module MEMWBPipelineRegister(mwreg, mm2reg, mdestReg, mr, mdo, clk,
    wwreg, wm2reg, wdestReg, wr, wdo);
    
    input mwreg;
    input mm2reg;
    input [4:0] mdestReg;
    input [31:0] mr;
    input [31:0] mdo;
    input clk;
    output reg wwreg;
    output reg wm2reg;
    output reg [4:0] wdestReg;
    output reg [31:0] wr;
    output reg [31:0] wdo;
    
    always @ (posedge clk)
    begin
        wwreg <= mwreg;
        wm2reg <= mm2reg;
        wdestReg <= mdestReg;
        wr <= mr;
        wdo <= mdo;
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////
module WBMux(wr, wdo, wm2reg, wbData);

    input [31:0] wr;
    input [31:0] wdo;
    input wm2reg;
    output reg [31:0] wbData;
    
    always @(*)
    begin
        case(wm2reg)
            1'b0:
            begin
                wbData <= wr;
            end
        
            1'b1:
            begin
                wbData <= wdo;
            end
        endcase
    end

endmodule
/////////////////////////////////////////////////////////////////////////////////
module DataPath(clk, pc, dinstOut, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32,
                mwreg, mm2reg, mwmem, mdestReg, mr, mqb, mdo, wwreg, wm2reg, wdestReg, wr, wdo, qa, qb);
    input clk;
    
    // outputs for IDEXE pipeline
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
    
    // b and r
    wire [31:0] b;
    wire [31:0] r;
    
    // outputs for EXEMEM pipeline
    output wire mwreg;
    output wire mm2reg;
    output wire mwmem;
    output wire[4:0] mdestReg;
    output wire[31:0] mr;
    output wire[31:0] mqb;
    
    // outputs for MEMWB pipeline
    output wire[31:0] mdo;
    output wire wwreg;
    output wire wm2reg;
    output wire[4:0] wdestReg;
    output wire[31:0] wr;
    output wire[31:0] wdo;
    
    // other wires
    wire[31:0] nextPc;
    wire[31:0] instOut;
    wire wreg;
    wire m2reg;
    wire wmem;
    wire[3:0] aluc;
    wire aluimm;
    wire regrt;
    wire[4:0] destReg;
    output wire[31:0] qa;
    output wire[31:0] qb;
    wire[31:0] imm32;
    wire[31:0] wbData;
    wire wpcir;
    wire [31:0] da;
    wire [31:0] db;
    wire [1:0] fwda;
    wire [1:0] fwdb;
    
    ProgramCounter programCounter(nextPc, clk, wpcir, pc);
    InstructionMemory instructionMemory(pc, instOut);
    PcAdder pcAdder(pc, nextPc);
    ifidPipelineRegister ifid(instOut, clk, dinstOut);
    ControlUnit controlUnit(dinstOut[31:26], dinstOut[5:0], dinstOut[25:21], dinstOut[20:16], mdestReg, mm2reg, mwreg, edestReg, em2reg, ewreg, wreg, m2reg, wmem, aluc, aluimm, regrt, fwda, fwdb);
    fwdAMux FA(fwda, qa, r, mr, mdo, da);
    fwdBMux FB(fwdb, qb, r, mr, mdo, db);
    RegrtMultiplexer regRTMux(dinstOut[20:16], dinstOut[15:11], regrt, destReg);
    RegisterFile registerFile(dinstOut[25:21],dinstOut[20:16],qa,qb,wdestReg,wbData,wwreg,clk);
    ImmExtender immExtender(dinstOut[15:0], imm32);
    IDEXEPipelineRegister IDEXE(wreg, m2reg, wmem, aluc, aluimm, destReg, da, db, imm32, clk,
        ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);   
    ALUMux alumux(eqb, eimm32, ealuimm, b);
    ALU alu(eqa, b, ealuc, r);
    EXEMEMPipelineRegister exemem(ewreg, em2reg, ewmem, edestReg, r, eqb, 
        clk, mwreg, mm2reg, mwmem, mdestReg, mr, mqb);
    DataMemory dataMemory(mr, mqb, mwmem, clk, mdo);
    MEMWBPipelineRegister memwb(mwreg, mm2reg, mdestReg, mr, mdo, clk,
        wwreg, wm2reg, wdestReg, wr, wdo);
    WBMux wbmux(wr, wdo, wm2reg, wbData);
    
endmodule
