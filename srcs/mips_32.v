`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2020 02:10:56 PM
// Design Name: 
// Module Name: mips_32
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


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
    wire reg_dst, reg_write, alu_src, pc_src, mem_read, mem_write, mem_to_reg;  //name control wires here and input into datapath
    wire [3:0] ALU_Control;
    wire [5:0] inst_31_26, inst_5_0;
    wire [25:0] inst_25_0;
    wire [1:0] alu_op;
    wire branch, jump, branchsel;
    // pipelining
    wire Data_Hazard;
    wire [9:0] branch_address, jump_address;
    wire branch_taken;
    wire [31:0] instr;
    wire [9:0] pc_plus4;
    // hazard detection
    wire id_ex_mem_read, IF_Flush;
    wire [4:0] id_ex_destination_reg, if_id_rs, if_id_rt;
    // if_id pipeline reg
    wire en;
    wire [9:0] if_id_pc_plus4, if_id_instr;
    // id_pipeline stage
    wire mem_wb_reg_write, Control_Hazard;
    wire [4:0] mem_wb_destination_reg, destination_reg;
    wire [31:0] write_back_data, reg1,reg2, imm_value; 
    // id_ex_pipeline reg
    wire [31:0] id_ex_instr, id_ex_imm_value, id_ex_reg1, id_ex_reg2;
    wire id_ex_mem_to_reg, id_ex_mem_write, id_ex_alu_src, id_ex_reg_write;
    wire [1:0] id_ex_alu_op;   
    // ex pipeline stage
    wire [31:0] ex_mem_alu_result, write_back_result, alu_in2_out, alu_result;
    wire [1:0] Forward_A, Forward_B; 
    // forwarding unit
    wire ex_mem_reg_write;
    wire [4:0] ex_mem_write_reg_addr, id_ex_instr_rs, mem_wb_write_reg_addr;
    // ex_mem pipeline reg
    wire [31:0] ex_mem_instr;
    wire [4:0] ex_mem_destination_reg;
    wire ex_mem_mem_to_reg, ex_mem_mem_read, ex_mem_mem_write; 
	// data memory    
    wire [31:0] mem_read_data;
    // mem_wb pipeline reg
    wire [31:0] mem_wb_alu_result, mem_wb_mem_read_data;
    wire mem_wb_mem_to_reg;    
    
    
    //instantiating module by name    
    IF_pipe_stage instruction_fetch(
        .clk(clk),
        .reset(reset),
        .en(Data_Hazard),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_plus4(pc_plus4),
        .instr(instr)
        );
        
    Hazard_detection hazard_detection_unit(
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_destination_reg(id_ex_destination_reg),
        .if_id_rs(if_id_rs),
        .if_id_rt(if_id_rt),
        .branch_taken(branch_taken),
        .jump(jump),
        .Data_Hazard(Data_Hazard),
        .IF_Flush(IF_Flush)
        );
                           
    //instantiate IF/ID pipeline register here
    pipe_reg_en ID_pipeline_reg (
        .clk(clk),
        .reset(reset),
        .en(en),
        .flush(IF_Flush),
        .x_in(pc_plus4), 
        .y_in(instr),
        .x_out(if_id_pc_plus4),
        .y_out(if_id_instr)
        );

    ID_pipe_stage instruction_decode(
        .clk(clk),
        .reset(reset),
        .if_id_pc_plus4(if_id_pc_plus4),
        .if_id_instr(if_id_instr),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .mem_wb_write_back_data(write_back_data),
        .Data_Hazard(Data_Hazard),
        .Control_Hazard(Control_Hazard),
        .reg1(reg1),
        .reg2(reg2),
        .imm_value(imm_value),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .destination_reg(destination_reg),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump)
        );             
                   
    //instantiate ID/EX pipeline register here    
    pipe_reg ID_EX_pipeline_reg (
        .clk(clk),
        .reset(reset),
        .data_a_in(if_id_instr),   //data = 32 bits
        .data_b_in(imm_value),
        .data_c_in(reg1),
        .data_d_in(reg2),
        .addr_a_in(destination_reg),  //addr = 5 bits
        .addr_b_in(if_id_instr[25:21]),  
        .addr_c_in(if_id_instr[20:16]),
        .control_a_in(mem_to_reg),   //control wires
        .control_b_in(mem_read),
        .control_c_in(mem_write),
        .control_d_in(alu_src),
        .control_e_in(reg_write),
        .aluop_in(alu_op),
        .data_a_out(id_ex_instr),
        .data_b_out(id_ex_imm_value),
        .data_c_out(id_ex_reg1),    //don't know if should name reg1 or id_ex_reg1
        .data_d_out(id_ex_reg2),
        .addr_a_out(id_ex_destination_reg),
        .addr_b_out(),   //not sure what to name these, rs and rt for forwarding unit
        .addr_c_out(),
        .control_a_out(id_ex_mem_to_reg),
        .control_b_out(id_ex_mem_read),
        .control_c_out(id_ex_mem_write),
        .control_d_out(id_ex_alu_src),
        .control_e_out(id_ex_reg_write),
        .aluop_out(id_ex_alu_op)
        );
      
    EX_pipe_stage execution_stage(
        .id_ex_instr(id_ex_instr),
        .id_ex_reg1(id_ex_reg1),
        .id_ex_reg2(id_ex_reg2),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_imm_value(id_ex_imm_value),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_back_result(write_back_result),
        .id_ex_alu_src(id_ex_alu_src),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B),
        .alu_in2_out(alu_in2_out),
        .alu_result(alu_result)
        );
                  
    Forwarding_unit Forwarding_unit(
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_write_reg_addr(ex_mem_write_reg_addr),
        .id_ex_instr_rs(id_ex_instr_rs),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_write_reg_addr),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B)
        );                       
        
    //instantiate EX/MEM pipeline register here
    pipe_reg ex_mem_pipeline_reg (
        .clk(clk),
        .reset(reset),
        //inputs
        .data_a_in(id_ex_instr),   //why does ex_mem need instr?
        .data_b_in(alu_result),
        .data_c_in(alu_in2_out),
        .addr_a_in(id_ex_destination_reg),  //addr = 5 bits
        .control_a_in(id_ex_mem_to_reg),   //control wires
        .control_b_in(id_ex_mem_read),
        .control_c_in(id_ex_mem_write),
        .control_d_in(id_ex_reg_write),
        //outputs
        .data_a_out(ex_mem_instr),
        .data_b_out(ex_mem_alu_result),
        .data_c_out(ex_mem_alu_result),    
        .addr_a_out(ex_mem_destination_reg),
        .control_a_out(ex_mem_mem_to_reg),
        .control_b_out(ex_mem_mem_read),
        .control_c_out(ex_mem_mem_write),
        .control_d_out(ex_mem_reg_write)
        );
                   
    data_memory data_memory(
        .clk(clk),
        .mem_access_addr(ex_mem_alu_result),
        .mem_write_en(ex_mem_mem_write),
        .mem_read_en(ex_mem_mem_read),
        .mem_read_data(mem_read_data)
        );
                        
    //instantiate MEM/WB pipeline register here
    pipe_reg mem_wb_pipeline_reg(
        .clk(clk),
        .reset(reset),
        //inputs
        .data_a_in(ex_mem_alu_result),
        .data_b_in(mem_read_data),
        .addr_a_in(ex_mem_destination_reg),
        .control_a_in(ex_mem_mem_to_reg),
        .control_b_in(ex_mem_reg_write),
        //outputs
        .data_a_out(mem_wb_alu_result),
        .data_b_out(mem_wb_mem_read_data),
        .addr_a_out(mem_wb_destination_reg),
        .control_a_out(mem_wb_mem_to_reg),
        .control_b_out(mem_wb_reg_write)
        );
    
     mux2 #(.mux_width(32)) writeback_mux (
        .a(mem_wb_alu_result),
        .b(mem_wb_mem_read_data),
        .sel(mem_wb_mem_to_reg),
        .y(write_back_data)
        );  
        
endmodule