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
    output [31:0] instr
    );
    
    wire [9:0] branch_mux_out;
    reg [9:0] pc;
    wire [9:0] pc_out;
    
    assign pc_plus4 = pc + 10'b0000000100;
    always @(posedge clk or posedge reset)
        begin
            if (reset)
                pc = 10'd0;
            else if (en == 0)
                pc = pc_out - 10'b0000000100;
            else 
                pc = pc_out;
        end
  
    //need to add logic for Data_Hazard 
    mux2 #(.mux_width(10)) branch_mux (
        .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(branch_mux_out)
        );

    mux2 #(.mux_width(10)) jump_mux (
        .a(branch_mux_out),
        .b(jump_address),
        .sel(jump),
        .y(pc_out)
        );

    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr)
        );   

endmodule
