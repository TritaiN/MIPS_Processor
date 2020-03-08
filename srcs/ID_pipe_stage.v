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
    output mem_to_reg, //
    output [1:0] alu_op, //
    output mem_read, //
    output mem_write, //
    output alu_src, //
    output reg_write, //
    output jump //
    );
    
    wire eq_test_out;
    wire branch;
    wire control_hazard;
    wire reg_dst;
    wire cntr_mem_to_reg;
    wire [1:0] cntr_alu_op;
    wire cntr_mem_read;
    wire cntr_mem_write;
    wire cntr_alu_src;
    wire cntr_reg_write;

    
    assign jump_address = if_id_instr[9:0] << 2;
    assign branch_taken = branch & eq_test_out;
    assign eq_test_out = (reg1 ^ reg2 == 32'd0) ? 1'b1 : 1'b0;
    assign branch_address = if_id_pc_plus4 + (imm_value[9:0] << 2);
    
    // set control signals to 0 if have control hazard
    assign control_hazard = ~Data_Hazard | IF_Flush;
    
    sign_extend sign_ex_inst (
        .sign_ex_in(if_id_instr[15:0]),
        .sign_ex_out(imm_value)
        );
    
    control control_unit(
        .reset(reset),
        .opcode(if_id_instr[31:26]),
        .reg_dst(reg_dst),
        .mem_to_reg(cntr_mem_to_reg),
        .alu_op(cntr_alu_op),
        .mem_read(cntr_mem_read),  
        .mem_write(cntr_mem_write),
        .alu_src(cntr_alu_src),
        .reg_write(cntr_reg_write),
        .jump(jump),         // jump instruction
        .branch(branch)    // branch instruction
        );
        
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
        
    mux2 #(.mux_width(1)) mem_to_reg_mux (
        .b(1'b0),
        .a(cntr_mem_to_reg),
        .sel(control_hazard),  
        .y(mem_to_reg)
        );
        
    mux2 #(.mux_width(2)) alu_op_mux (
        .b(2'b00),
        .a(cntr_alu_op),
        .sel(control_hazard),  
        .y(alu_op)
        );            
    
    mux2 #(.mux_width(1)) mem_read_mux (
        .b(1'b0),
        .a(cntr_mem_read),
        .sel(control_hazard),  
        .y(mem_read)
        );
        
    mux2 #(.mux_width(1)) mem_write_mux (
        .b(1'b0),
        .a(cntr_mem_write),
        .sel(control_hazard),  
        .y(mem_write)
        );        
        
    mux2 #(.mux_width(1)) alu_src_mux(
        .b(1'b0),
        .a(cntr_alu_src),
        .sel(control_hazard),  
        .y(alu_src)
        );         
        
    mux2 #(.mux_width(1)) reg_write_mux (
        .b(1'b0),
        .a(cntr_reg_write),
        .sel(control_hazard),  
        .y(reg_write)
        );        
        
endmodule

