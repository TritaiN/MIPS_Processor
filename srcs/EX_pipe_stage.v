`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 05:13:25 PM
// Design Name: 
// Module Name: EX_pipe_stage
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

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [1:0] id_ex_alu_op,
    input [31:0] id_ex_reg1, id_ex_reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    wire [31:0] alu_in1, forwardb_output, alu_in2;
    wire [3:0] ALU_Control;
    assign alu_in2_out = forwardb_output;
    
    mux4 #(.mux_width(32)) forwarda_mux (
        .a(id_ex_reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_A),
        .y(alu_in1)
        );
    
    mux4 #(.mux_width(32)) forwardb_mux (
        .a(id_ex_reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_B),
        .y(forwardb_output)
        );
        
    mux2 #(.mux_width(32)) alu_src_mux (
        .a(forwardb_output),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(alu_in2)
        );
    
    ALU alu_instr (
        .a(alu_in1),
        .b(alu_in2),
        .alu_control(ALU_Control),
        .zero(),
        .alu_result(alu_result)
        );    
        
    ALUControl ALU_Control_unit(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control));
        
    
endmodule
    
    