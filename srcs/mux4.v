`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 07:32:17 PM
// Design Name: 
// Module Name: mux4
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


module mux4 #(parameter mux_width= 32)
(   input [mux_width-1:0] a,b,c,d,
    input [1:0] sel,
    output [mux_width-1:0] y
    );
    // if 1X, then check LSB -> d if 1, c if 0
    // else, check if LSB -> b if 1, a if 0
    assign y = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);
endmodule
