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


module pipe_reg_en #(parameter WIDTH = 32) (
    input clk, reset,
    input en, flush,
    input [WIDTH-1:0] instr_in,
    input [WIDTH-23:0] addr_in,
    output reg [WIDTH-1:0] instr_out,
    output reg [WIDTH-23:0] addr_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            instr_out <=0; addr_out <= 0;
        end
        else if (flush) 
            begin
            instr_out <= 0; addr_out <= 0;
            end
        else if (en) 
            begin
            instr_out <= instr_in; addr_out <= addr_in;
            end
    end
    
endmodule
