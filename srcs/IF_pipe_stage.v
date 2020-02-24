`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 05:13:25 PM
// Design Name: 
// Module Name: IF_pipe_stage
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


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output[31:0] instr
    );
    
    wire [9:0] branch_mux_out;
    reg pc;
    
    always @(en == 1'b0)
        begin
            pc = 32'd0;
        end
    
    //need to add logic for Data_Hazard 
    mux2 #(.mux_width(32)) branch_mux (
        .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(branch_mux_out)
        );

    mux2 #(.mux_width(32)) jump_mux (
        .a(branch_mux_out),
        .b(jump_address),
        .sel(jump),
        .y(pc)
        );

    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr)
        );

     ALU pc_plus4_alu (
        .a(pc),
        .b(3'b100),             //4
        .alu_control(4'b0010),  //add
        .zero(),           
        .alu_result(pc_plus4)
        );     

endmodule
