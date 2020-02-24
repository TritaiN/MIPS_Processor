`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 05:13:25 PM
// Design Name: 
// Module Name: pipe_reg_en
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


module pipe_reg_en #(parameter WIDTH = 10) (
    input clk, reset,
    input en, flush,
    input [WIDTH-1:0] x_in, y_in,
    output reg [WIDTH-1:0] x_out, y_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            {x_out, y_out} <= 0;
        else if (flush) 
            {x_out, y_out} <= 0;
        else if (en) 
            x_out <= x_in;
            y_out <= y_in;
    end
    
endmodule
