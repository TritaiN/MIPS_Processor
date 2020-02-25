`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 05:13:25 PM
// Design Name: 
// Module Name: pipe_reg
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

module pipe_reg #(parameter WIDTH = 32) (
    
    //inputs
    input clk, reset,
    input [WIDTH-1:0] instr_in, imm_in, reg1_in, reg2_in, 
    alu_result_in, alu_in2_in, read_data_in,
    input [WIDTH-28:0] destination_reg_in, instr_rs_in, instr_rt_in,
    input mem_to_reg_in, mem_read_in, mem_write_in, alu_src_in, reg_write_in,
    input [WIDTH-31:0] aluop_in,
    // outputs
    output reg [WIDTH-1:0] instr_out, imm_out, reg1_out, reg2_out, alu_result_out, alu_in2_out, read_data_out,
    output reg [WIDTH-28:0] destination_reg_out, instr_rs_out, instr_rt_out,
    output reg mem_to_reg_out, mem_read_out, mem_write_out, alu_src_out, reg_write_out,
    output reg [WIDTH-31:0] aluop_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        //set all outputs to 0
        if(reset)
            {instr_out, imm_out, reg1_out, reg2_out, destination_reg_out,
            instr_rs_out, instr_rt_out, mem_to_reg_out, mem_read_out, alu_result_out, 
            alu_in2_out, read_data_out, mem_write_out, alu_src_out, reg_write_out, 
            aluop_out} <= 0;
        else 
            instr_out <= instr_in;
            imm_out <= imm_in; 
            reg1_out <= reg1_in;
            reg2_out <= reg2_in;    
            alu_result_out <= alu_result_in;
            alu_in2_out <= alu_in2_in;
            read_data_out <= read_data_in;
  
            destination_reg_out <= destination_reg_in;
            instr_rs_out <= instr_rs_in; 
            instr_rt_out <= instr_rt_in;
            
            mem_to_reg_out <= mem_to_reg_in;     
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            alu_src_out <= alu_src_in;
            reg_write_out <= reg_write_in;
            
            aluop_out <= aluop_in;
                       
    end
endmodule