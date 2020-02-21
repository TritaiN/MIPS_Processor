`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2020 02:31:52 PM
// Design Name: 
// Module Name: datapath
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


module datapath(
    input clk, reset, 
    input reg_dst, reg_write,
    input alu_src, pc_src, 
    input mem_read, mem_write,
    input mem_to_reg,
    input jump, branch, branchsel,  //
    input [3:0] ALU_Control, 
    output [31:0] datapath_result,
    output [5:0] inst_31_26, 
    output [5:0] inst_5_0,
    output [25:0] inst_25_0  //
    
    );
    
    reg [31:0] pc; 
    wire [31:0] pc_plus4;// = 6'b000000;
    wire [31:0] instr;
    wire [4:0] write_reg_addr;
    wire [31:0] write_back_data;
    wire [31:0] reg1, reg2;
    wire [31:0] imm_value;
    wire [31:0] alu_in2;
    wire [31:0] alu_result;
    wire [31:0] adder_result;  // for branch
    wire [31:0] jump_mux_out;    //
    wire [31:0] mem_read_data;
    wire [31:0] pc_jump;      //
    wire [27:0] shifted_25;
    wire [31:0] temppc;
    wire [31:0] shifted_imm;

    always @(posedge clk or posedge reset)  
 begin   
      if(reset)   
            pc <= 32'b00000000000000000000000000000000; 
      //else if (jump)
      //     pc <= temppc;
     // else if (branchsel)
     //      pc <= adder_result;
      else  
            pc <=temppc;
          //pc <= pc_plus4;  
 end  
 
 assign pc_jump = { pc_plus4[31:28] , shifted_25[27:0] };
 assign pc_plus4 = pc + 32'b00000000000000000000000000000100;
 assign branchsel = branch & zero;
 assign shifted_imm = imm_value << 2;
 
    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));
        
    assign inst_25_0 = instr[25:0];       
    assign inst_31_26 = instr[31:26];
    assign inst_5_0 = instr[5:0];
    assign shifted_25 = inst_25_0 << 2;
    
    mux2 #(.mux_width(5)) reg_mux 
    (   .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(write_reg_addr));
        
    register_file reg_file (
        .clk(clk),  
        .reset(reset),  
        .reg_write_en(reg_write),  
        .reg_write_dest(write_reg_addr),  
        .reg_write_data(write_back_data),  
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]), 
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2));  
        
    sign_extend sign_ex_inst (
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value));
        
    mux2 #(.mux_width(32)) alu_mux 
    (   .a(reg2),
        .b(imm_value),
        .sel(alu_src),
        .y(alu_in2));
        
    ALU alu_inst (
        .a(reg1),
        .b(alu_in2),
        .alu_control(ALU_Control),
        .zero(zero),
        .alu_result(alu_result));
        
    data_memory data_mem (
        .clk(clk),
        .mem_access_addr(alu_result),
        .mem_write_data(reg2),
        .mem_write_en(mem_write),
        .mem_read_en(mem_read),
        .mem_read_data(mem_read_data));
        
     mux2 #(.mux_width(32)) writeback_mux 
    (   .a(alu_result),
        .b(mem_read_data),
        .sel(mem_to_reg),
        .y(write_back_data));  
        
     ALU alu_imm (
        .a(pc_plus4),
        .b(shifted_imm),
        .alu_control(4'b0010),    //do i need this?
        .zero(),                  //do i need this?
        .alu_result(adder_result));           
        
     mux2 #(.mux_width(32)) branch_mux 
    (   .a(pc_plus4),
        .b(adder_result),        
        .sel(branchsel),
        .y(jump_mux_out));  
        
     mux2 #(.mux_width(32)) jump_mux 
    (   .a(jump_mux_out),       
        .b( pc_jump ),   
        .sel(jump),   
        .y(temppc));  
        
    assign datapath_result = write_back_data;
endmodule
