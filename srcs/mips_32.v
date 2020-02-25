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
    wire [9:0] if_id_pc_plus4;
    wire [31:0] if_id_instr;
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
    wire [4:0] ex_mem_write_reg_addr, mem_wb_write_reg_addr;
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
        .if_id_rs(if_id_instr[25:21]),
        .if_id_rt(if_id_instr[20:16]),
        .branch_taken(branch_taken),
        .jump(jump),
        .Data_Hazard(Data_Hazard),
        .IF_Flush(IF_Flush)
        );
                           
    //instantiate IF/ID pipeline register here
    pipe_reg_en #(.WIDTH(32)) ID_pipeline_reg (
        .clk(clk),
        .reset(reset),
        .en(en),
        .flush(IF_Flush),
        .instr_in(instr), 
        .addr_in(pc_plus4),
        .instr_out(if_id_instr),
        .addr_out(if_id_pc_plus4)
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
        .instr_in(if_id_instr),   //data = 32 bits
        .imm_in(imm_value),
        .reg1_in(reg1),
        .reg2_in(reg2),
        .destination_reg_in(destination_reg),  //addr = 5 bits
        .instr_rs_in(if_id_instr[25:21]),  
        .instr_rt_in(if_id_instr[20:16]),
        .mem_to_reg_in(mem_to_reg),   //control wires
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .alu_src_in(alu_src),
        .reg_write_in(reg_write),
        .aluop_in(alu_op),
        .instr_out(id_ex_instr),
        .imm_out(id_ex_imm_value),
        .reg1_out(id_ex_reg1),    //don't know if should name reg1 or id_ex_reg1
        .reg2_out(id_ex_reg2),
        .destination_reg_out(id_ex_destination_reg),
        .instr_rs_out(),   //not sure what to name these, rs and rt for forwarding unit
        .instr_rt_out(),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .alu_src_out(id_ex_alu_src),
        .reg_write_out(id_ex_reg_write),
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
        .id_ex_instr_rs(id_ex_instr[26:21]),
        .id_ex_instr_rt(id_ex_instr[20:16]),
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
        .instr_in(id_ex_instr),   //why does ex_mem need instr?
        .alu_result_in(alu_result),
        .alu_in2_in(alu_in2_out),
        .destination_reg_in(id_ex_destination_reg),  //addr = 5 bits
        .mem_to_reg_in(id_ex_mem_to_reg),   //control wires
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .reg_write_in(id_ex_reg_write),
        //outputs
        .instr_out(ex_mem_instr),
        .alu_result_out(ex_mem_alu_result),
        .alu_in2_out(ex_mem_alu_result),    
        .destination_reg_out(ex_mem_destination_reg),
        .mem_to_reg_out(ex_mem_mem_to_reg),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .reg_write_out(ex_mem_reg_write)
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
        .alu_result_in(ex_mem_alu_result),
        .read_data_in(mem_read_data),
        .destination_reg_in(ex_mem_destination_reg),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .reg_write_in(ex_mem_reg_write),
        //outputs
        .alu_result_out(mem_wb_alu_result),
        .read_data_out(mem_wb_mem_read_data),
        .destination_reg_out(mem_wb_destination_reg),
        .mem_to_reg_out(mem_wb_mem_to_reg),
        .reg_write_out(mem_wb_reg_write)
        );
    
     mux2 #(.mux_width(32)) writeback_mux (
        .a(mem_wb_alu_result),
        .b(mem_wb_mem_read_data),
        .sel(mem_wb_mem_to_reg),
        .y(write_back_data)
        );  
        
endmodule