`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 05:13:25 PM
// Design Name: 
// Module Name: ID_pipe_stage
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

module ID_pipe_stage (
    input clk, reset,
    input [9:0] if_id_pc_plus4,
    input [31:0] if_id_instr,
    input mem_wb_reg_write,
    input [4:0] mem_wb_write_reg_addr,
    input [31:0] mem_wb_write_back_data,
    input Data_Hazard,
    input IF_Flush,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg,
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    wire eq_test_out;
    wire branch;
    wire control_hazard;
    wire reg_dst;
    assign jump_address = if_id_instr[25:0] << 2'b10;
    assign branch_taken = branch & eq_test_out;
    assign eq_test_out = (reg1 ^ reg2 == 32'd0) ? 1'b1 : 1'b0;
    assign branch_address = if_id_pc_plus4 + (imm_value << 2'b10);
    
    // set control signals to 0 if have control hazard
    assign control_hazard = ~Data_Hazard | IF_Flush;
//    always @ (Data_Hazard, IF_Flush) 
//        begin
//        if (control_hazard == 1'b1)
//            begin
//                {mem_to_reg, mem_read, mem_write, 
//                alu_src, reg_write, jump} <= 0;
//            end
//        end
 
    
    sign_extend sign_ex_inst (
        .sign_ex_in(if_id_instr[15:0]),
        .sign_ex_out(imm_value)
        );
    
    control control_unit(
        .reset(reset),
        .opcode(if_id_instr[31:26]),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),  
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump),         // jump instruction
        .branch(branch)    // branch instruction
        );
        
        
//    mux2 #(.mux_width(32)) control_mux (
//        .a(),
//        .b(if_id_instr[20:16]),
//        .sel(control_hazard),  
//        .y(destination_reg)
//        );
        
    register_file reg_file (
        .clk(clk),  
        .reset(reset),  
        .reg_write_en(mem_wb_reg_write),  
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),  
        .reg_read_addr_1(if_id_instr[25:21]), 
        .reg_read_addr_2(if_id_instr[20:16]), 
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2)
        ); 
    
    mux2 #(.mux_width(5)) destination_mux (
        .a(if_id_instr[20:16]),
        .b(if_id_instr[15:11]),
        .sel(reg_dst),  //output from control unit
        .y(destination_reg)
        );
    
endmodule

