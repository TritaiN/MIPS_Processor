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
    input [WIDTH-1:0] data_a_in, data_b_in, data_c_in, data_d_in,
    input [WIDTH-29:0] addr_a_in, addr_b_in, addr_c_in,
    input control_a_in, control_b_in, control_c_in, control_d_in, control_e_in,
    input [WIDTH-31:0] aluop_in,
    // outputs
    output reg [WIDTH-1:0] data_a_out, data_b_out, data_c_out, data_d_out,
    output reg [WIDTH-29:0] addr_a_out, addr_b_out, addr_c_out,
    output reg control_a_out, control_b_out, control_c_out, control_d_out, control_e_out,
    output reg [WIDTH-31:0] aluop_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        //set all outputs to 0
        if(reset)
            {data_a_out, data_b_out, data_c_out, data_d_out,addr_a_out, addr_b_out, addr_c_out,control_a_out, 
            control_b_out, control_c_out, control_d_out, control_e_out, aluop_out} <= 0;
        else 
            data_a_out <= data_a_in;
            data_b_out <= data_b_in; 
            data_c_out <= data_c_in;
            data_d_out <= data_d_in;    
             
            addr_a_out <= addr_a_in;
            data_b_out <= addr_b_in; 
            addr_c_out <= addr_c_in;
            
            control_a_out <= control_a_in;     
            control_b_out <= control_b_in;
            control_c_out <= control_c_in;
            control_d_out <= control_d_in;
            control_e_out <= control_e_in;
            
            aluop_out <= aluop_in;
                       
    end
endmodule