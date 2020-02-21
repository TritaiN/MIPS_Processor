`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2020 12:29:50 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] a,  
    input [31:0] b, 
    input [3:0] alu_control,
    output zero, 
    output reg [31:0] alu_result);  
    
    wire signed [31:0] a_signed;
    assign a_signed = a;
 always @(*)
 begin   
      case(alu_control)  
      4'b0000: alu_result = a & b;      // And  
      4'b0001: alu_result = a | b;      // Or  
      4'b0010: alu_result = a + b;      // Add  
      4'b0110: alu_result = a - b;      // Sub, Beq                                
      4'b0111: 
                if (a < b) 
                    alu_result = 32'h00000001;      // SLT
                else 
                    alu_result = 32'h00000000;       
      4'b1000: alu_result = a<<b[10:6];      // SLL
      4'b1001: alu_result = a>>b[10:6];      // SRL
      4'b1010: alu_result = a_signed>>>b[10:6];      // SRA
      4'b1100: alu_result = ~(a | b);   // Nor
      4'b0100: alu_result = a ^ b;      // Xor
      4'b0101: alu_result = a * b;      // Mult 
      4'b1011: alu_result = a / b;      // Divide
      default: alu_result = a + b; // add  
      endcase  
 end  
 assign zero = (alu_result==32'd0) ? 1'b1: 1'b0;

endmodule
