`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2020 04:24:03 AM
// Design Name: 
// Module Name: ALUControl
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


module ALUControl(
    input [1:0] ALUOp, 
    input [5:0] Function,
    output reg[3:0] ALU_Control);  

wire [7:0] ALUControlIn;  
 assign ALUControlIn = {ALUOp,Function};  
 always @(ALUControlIn)  
 casex (ALUControlIn)  
  8'b1x100100: ALU_Control=4'b0000;     //And
  8'b10100101: ALU_Control=4'b0001;     //Or
  8'b00xxxxxx: ALU_Control=4'b0010;     //Add
  8'b10100000: ALU_Control=4'b0010;     //Add
  8'b10100010: ALU_Control=4'b0110;     //Subtract
  8'b11xxxxxx: ALU_Control=4'b0000;     //Addi
  8'b01xxxxxx: ALU_Control=4'b0110;     //Beq                                 
  8'b10101010: ALU_Control=4'b0111;     //SLT
  8'b10000000: ALU_Control=4'b1000;     //SLL
  8'b10000010: ALU_Control=4'b1001;     //SRL 
  8'b10000011: ALU_Control=4'b1010;     //SRA  
  8'b10100111: ALU_Control=4'b1100;     //Nor
  8'b10100110: ALU_Control=4'b0100;     //Xor
  8'b10011000: ALU_Control=4'b0101;     //Mult
  8'b10011010: ALU_Control=4'b1011;     //Divide
  

  
  
  default: ALU_Control=4'b0000;  
  endcase  
 endmodule  



