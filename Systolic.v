`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 01:55:00 PM
// Design Name: 
// Module Name: finalproject
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
module Systolic (Clk,En,Est,Ld,A,Mem_In,Result);
input Clk,En,Est,Ld;
input [71:0] A;
input [647:0] Mem_In;
output reg [143:0] Result;
wire [15:0] Result_Wire[0:8][0:8];
wire [7:0] Passthrough_Wire[0:8][0:8];
wire [7:0]Ain[0:8];
reg [7:0] Mem_Inin[0:8][0:8];
integer Parse_Col, Parse_Row;

always @* begin
    for (Parse_Col=0; Parse_Col<9; Parse_Col = Parse_Col+1) begin
            Result[Parse_Col*16+:16] <= Result_Wire[Parse_Col][8];
        for (Parse_Row=0; Parse_Row<9; Parse_Row = Parse_Row+1) begin
            Mem_Inin[Parse_Col][Parse_Row] <= Mem_In [(Parse_Col*72)+(Parse_Row*8)+:8];
        end
    end
end

pe PE0 (Clk,En,Est,Ld,A[7:0],Mem_Inin[0][0],16'd0,Result_Wire[0][0],Passthrough_Wire[0][0]);
genvar i,j;
generate
    for (j=1;j<9;j=j+1) begin
        pe PE1 (Clk,En,Est,Ld,A[(j)*8+7:(j)*8],Mem_Inin[0][j],Result_Wire[0][j-1],Result_Wire[0][j],Passthrough_Wire[0][j]);
        pe PE2 (Clk,En,Est,Ld,Passthrough_Wire[j-1][0],Mem_Inin[j][0],16'd0,Result_Wire[j][0],Passthrough_Wire[j][0]);
        for (i=1;i<9;i=i+1) begin
            pe PE3 (Clk,En,Est,Ld,Passthrough_Wire[j-1][i],Mem_Inin[j][i],Result_Wire[j][i-1],Result_Wire[j][i],Passthrough_Wire[j][i]);
        end
    end
endgenerate
endmodule

module pe(Clk,En,Rst,Ld,A,Mem_In,C,Result,Aout);
input Clk,En,Rst,Ld;
input [7:0] A, Mem_In ;
input [15:0] C;
output reg [15:0] Result;
output reg [7:0] Aout;
reg [15:0] Prod_Reg;
reg [7:0] Memory;
wire cout;

always@* begin
Aout <= A;
end

wire [15:0] Prod_Wire;
wire [15:0] Result_Wire;
Vedic_8bit IN1 (A,Memory,Prod_Wire);
always@(posedge Clk) begin
     if (Rst == 1'b1) begin
     Prod_Reg <= 16'd0;
     Memory <= 8'd0;
     end
     else if (Ld == 1'b1) begin
     Memory <= Mem_In;
     end
     else begin
     Prod_Reg <= Prod_Wire;
     end
end
CSLA_16bit IN2 (Prod_Reg,C,Result_Wire,cout);
always@(posedge Clk) begin
    if (Rst == 1'b1) begin
     Result <= 16'd0;
     end
    else if (Ld) begin
     end
    else begin
     Result <= Result_Wire;
    end
end
endmodule

module Vedic_2bit(A,B,Prod);
input [1:0] A,B;
output [3:0] Prod;
wire Nand2,Nand3,Nand4;
wire Carry1, Carry2;
assign Nand2 = A[1]&B[0];
assign Nand3 = A[0]&B[1];
assign Nand4 = A[1]&B[1];
assign Prod [0] = A[0]&B[0];
Full_Adder IN1 (Nand2,Nand3, 1'b0,Prod[1],Carry1);
Full_Adder IN2 (Carry1, Nand4,1'b0, Prod[2],Prod[3]);
endmodule

module Vedic_4bit(A,B,Prod);
input [3:0] A,B;
output [7:0] Prod;
wire [3:0] Vedic_Prod1,Vedic_Prod2,Vedic_Prod3,Vedic_Prod4;
wire [3:0] Sum1,Sum2,Sum3;
wire Carry1, Carry2, Carry3;
Vedic_2bit IN1 (A[1:0],B[1:0],Vedic_Prod1);
Vedic_2bit IN2 (A[1:0],B[3:2],Vedic_Prod2);
Vedic_2bit IN3 (A[3:2],B[1:0],Vedic_Prod3);
Vedic_2bit IN4 (A[3:2],B[3:2],Vedic_Prod4);
RCA_4bit IN5 ( Vedic_Prod2                  , Vedic_Prod3   , Sum1  , Carry1);
RCA_4bit IN6 ( {1'b0,1'b0,Vedic_Prod1[3:2]} , Sum1          , Sum2  , Carry2);
RCA_4bit IN7 ( {1'b0,Carry2,Sum2[3:2]}      , Vedic_Prod4   , Sum3  , Carry3);
assign Prod[1:0] = Vedic_Prod1[1:0];
assign Prod[3:2] = Sum2[1:0];
assign Prod[7:4] = Sum3[3:0];
endmodule

module Vedic_8bit(A,B,Prod);
input [7:0] A,B;
output [15:0] Prod;
wire [7:0] Vedic_Prod1,Vedic_Prod2,Vedic_Prod3,Vedic_Prod4;
wire [7:0] Sum1,Sum2,Sum3;
wire Carry1, Carry2, Carry3;
Vedic_4bit IN1 (A[3:0],B[3:0],Vedic_Prod1);
Vedic_4bit IN2 (A[3:0],B[7:4],Vedic_Prod2);
Vedic_4bit IN3 (A[7:4],B[3:0],Vedic_Prod3);
Vedic_4bit IN4 (A[7:4],B[7:4],Vedic_Prod4);
CSLA_8bit IN5 ( Vedic_Prod2                  , Vedic_Prod3   , Sum1  , Carry1);
CSLA_8bit IN6 ( {4'd0,Vedic_Prod1[7:4]}      , Sum1          , Sum2  , Carry2);
CSLA_8bit IN7 ( {3'd0,Carry2,Sum2[7:4]}      , Vedic_Prod4   , Sum3  , Carry3);
assign Prod[3:0] = Vedic_Prod1[3:0];
assign Prod[7:4] = Sum2[3:0];
assign Prod[15:8] = Sum3[7:0];
endmodule

module CSLA_16bit(A,B,Sum,Cout);
input [15:0] A,B;
output [15:0] Sum;
output Cout;

//Most significant bit of the sum is the carry out.
wire [2:0] RCA_Sum1,RCA_Sum2;
wire [3:0] RCA_Sum3;
wire [4:0] RCA_Sum4;
wire [5:0] RCA_Sum5;
wire RCA_Cout1,RCA_Cout2,RCA_Cout3,RCA_Cout4,RCA_Cout5;

wire [2:0] BEC_Sum3;
wire [3:0] BEC_Sum4;
wire [4:0] BEC_Sum5;
wire [5:0] BEC_Sum6;

wire [2:0] Mux_6to3;
wire [3:0] Mux_8to4;
wire [4:0] Mux_10to5;
wire [5:0] Mux_12to6;

RCA_2bit IN1 (A[1:0],B[1:0],RCA_Sum1[1:0],RCA_Sum1[2]);
RCA_2bit IN2 (A[3:2],B[3:2],RCA_Sum2[1:0],RCA_Sum2[2]);
RCA_3bit IN3 (A[6:4],B[6:4],RCA_Sum3[2:0],RCA_Sum3[3]);
RCA_4bit IN4 (A[10:7],B[10:7],RCA_Sum4[3:0],RCA_Sum4[4]);
RCA_5bit IN5 (A[15:11],B[15:11],RCA_Sum5[4:0],RCA_Sum5[5]);

BEC_3bit IN6(RCA_Sum2,BEC_Sum3);
BEC_4bit IN7(RCA_Sum3,BEC_Sum4);
BEC_5bit IN8(RCA_Sum4,BEC_Sum5);
BEC_6bit IN9(RCA_Sum5,BEC_Sum6);

Mux #(6,3) IN10 ({BEC_Sum3,RCA_Sum2}, RCA_Sum1[2], Mux_6to3);
Mux #(8,4) IN11 ({BEC_Sum4,RCA_Sum3}, Mux_6to3[2], Mux_8to4);
Mux #(10,5) IN12 ({BEC_Sum5,RCA_Sum4}, Mux_8to4[3], Mux_10to5);
Mux #(12,6) IN13 ({BEC_Sum6,RCA_Sum5}, Mux_10to5[4], Mux_12to6);


assign Sum [1:0] = RCA_Sum1[1:0];
assign Sum [3:2] = Mux_6to3[1:0];
assign Sum [6:4] = Mux_8to4[2:0];
assign Sum [10:7] = Mux_10to5[3:0];
assign Sum [15:11] = Mux_12to6[4:0];
assign Cout = Mux_12to6[5];
endmodule

module CSLA_8bit(A,B,Sum,Cout);
input [7:0] A,B;
output [7:0] Sum;
output Cout;

//Most significant bit of the sum is the carry out.
wire [1:0] RCA_Sum1;
wire [2:0] RCA_Sum2,RCA_Sum3;
wire [3:0] RCA_Sum4;

wire [2:0] BEC_Sum1;
wire [2:0] BEC_Sum2;
wire [3:0] BEC_Sum3;

wire [2:0] First_Mux_6to3;
wire [2:0] Second_Mux_6to3;
wire [3:0] Mux_8to4;

Full_Adder In1 (A[0],B[0],1'b0,RCA_Sum1[0], RCA_Sum1[1]);
RCA_2bit IN2 (A[2:1],B[2:1],RCA_Sum2[1:0],RCA_Sum2[2]);
RCA_2bit IN3 (A[4:3],B[4:3],RCA_Sum3[1:0],RCA_Sum3[2]);
RCA_3bit IN4 (A[7:5],B[7:5],RCA_Sum4[2:0],RCA_Sum4[3]);

BEC_3bit IN5(RCA_Sum2,BEC_Sum1);
BEC_3bit IN6(RCA_Sum3,BEC_Sum2);
BEC_4bit IN7(RCA_Sum4,BEC_Sum3);

Mux #(6,3) IN8 ({BEC_Sum1,RCA_Sum2}, RCA_Sum1[1], First_Mux_6to3);
Mux #(6,3) IN9 ({BEC_Sum2,RCA_Sum3}, First_Mux_6to3[2], Second_Mux_6to3);
Mux #(8,4) IN10 ({BEC_Sum3,RCA_Sum4}, Second_Mux_6to3[2], Mux_8to4);


assign Sum [0] = RCA_Sum1[0];
assign Sum [2:1] = First_Mux_6to3[1:0];
assign Sum [4:3] = Second_Mux_6to3[1:0];
assign Sum [7:5] = Mux_8to4[2:0];
assign Cout = Mux_8to4[3];
endmodule

module BEC_3bit (Bec3_Input, Bec3_Output);
input [2:0] Bec3_Input;
output [2:0] Bec3_Output;
assign Bec3_Output[0] = ~Bec3_Input[0];
assign Bec3_Output[1] = Bec3_Input[0]^Bec3_Input[1];
assign Bec3_Output[2] = Bec3_Input[2]^(Bec3_Input[0]&Bec3_Input[1]);
endmodule

module BEC_4bit (Bec4_Input, Bec4_Output);
input [3:0] Bec4_Input;
output [3:0] Bec4_Output;
assign Bec4_Output[0] = ~Bec4_Input[0];
assign Bec4_Output[1] = Bec4_Input[0]^Bec4_Input[1];
assign Bec4_Output[2] = Bec4_Input[2]^(Bec4_Input[0]&Bec4_Input[1]);
assign Bec4_Output[3] = Bec4_Input[3]^(Bec4_Input[0]&Bec4_Input[1]&Bec4_Input[2]);
endmodule

module BEC_5bit (Bec5_Input, Bec5_Output);
input [4:0] Bec5_Input;
output [4:0] Bec5_Output;
assign Bec5_Output[0] = ~Bec5_Input[0];
assign Bec5_Output[1] = Bec5_Input[0]^Bec5_Input[1];
assign Bec5_Output[2] = Bec5_Input[2]^(Bec5_Input[0]&Bec5_Input[1]);
assign Bec5_Output[3] = Bec5_Input[3]^(Bec5_Input[0]&Bec5_Input[1]&Bec5_Input[2]);
assign Bec5_Output[4] = Bec5_Input[4]^(Bec5_Input[0]&Bec5_Input[1]&Bec5_Input[2]&Bec5_Input[3]);
endmodule

module BEC_6bit (Bec6_Input, Bec6_Output);
input [5:0] Bec6_Input;
output [5:0] Bec6_Output;
assign Bec6_Output[0] = ~Bec6_Input[0];
assign Bec6_Output[1] = Bec6_Input[0]^Bec6_Input[1];
assign Bec6_Output[2] = Bec6_Input[2]^(Bec6_Input[0]&Bec6_Input[1]);
assign Bec6_Output[3] = Bec6_Input[3]^(Bec6_Input[0]&Bec6_Input[1]&Bec6_Input[2]);
assign Bec6_Output[4] = Bec6_Input[4]^(Bec6_Input[0]&Bec6_Input[1]&Bec6_Input[2]&Bec6_Input[3]);
assign Bec6_Output[5] = Bec6_Input[5]^(Bec6_Input[0]&Bec6_Input[1]&Bec6_Input[2]&Bec6_Input[3]&Bec6_Input[4]);
endmodule

module RCA_2bit (A,B,Sum_2bit,Cout_2bit);
input [1:0] A;
input [1:0] B;
output [1:0] Sum_2bit;
output Cout_2bit;
wire Cout;
Full_Adder IN1 (A[0],B[0],1'b0,Sum_2bit[0],Cout);
Full_Adder IN2 (A[1],B[1],Cout,Sum_2bit[1],Cout_2bit);
endmodule

module RCA_3bit (A,B,Sum_3bit,Cout_3bit);
input [2:0] A;
input [2:0] B;
output [2:0] Sum_3bit;
output Cout_3bit;
wire [1:0] Cout;
Full_Adder IN1 (A[0],B[0],1'b0,Sum_3bit[0],Cout[0]);
Full_Adder IN2 (A[1],B[1],Cout[0],Sum_3bit[1],Cout[1]);
Full_Adder IN3 (A[2],B[2],Cout[1],Sum_3bit[2],Cout_3bit);
endmodule

module RCA_4bit (A,B,Sum_4bit,Cout_4bit);
input [3:0] A;
input [3:0] B;
output [3:0] Sum_4bit;
output Cout_4bit;
wire [2:0] Cout;
Full_Adder IN1 (A[0],B[0],1'b0,Sum_4bit[0],Cout[0]);
Full_Adder IN2 (A[1],B[1],Cout[0],Sum_4bit[1],Cout[1]);
Full_Adder IN3 (A[2],B[2],Cout[1],Sum_4bit[2],Cout[2]);
Full_Adder IN4 (A[3],B[3],Cout[2],Sum_4bit[3],Cout_4bit);
endmodule

module RCA_5bit (A,B,Sum_5bit,Cout_5bit);
input [4:0] A;
input [4:0] B;
output [4:0] Sum_5bit;
output Cout_5bit;
wire [3:0] Cout;
Full_Adder IN1 (A[0],B[0],1'b0,Sum_5bit[0],Cout[0]);
Full_Adder IN2 (A[1],B[1],Cout[0],Sum_5bit[1],Cout[1]);
Full_Adder IN3 (A[2],B[2],Cout[1],Sum_5bit[2],Cout[2]);
Full_Adder IN4 (A[3],B[3],Cout[2],Sum_5bit[3],Cout[3]);
Full_Adder IN5 (A[4],B[4],Cout[3],Sum_5bit[4],Cout_5bit);
endmodule

module Full_Adder (A,B,Cin,Sum,Cout);
input A,B,Cin;
output Sum,Cout;
assign Sum = A^B^Cin;
assign Cout = (A&B)|((A^B)&Cin);
endmodule

module Mux #(parameter from = 2 , parameter to = 1)(In,Sel,Out);
input [from-1:0] In;
input Sel;
output [to-1:0] Out;
integer i;
reg [to-1:0] Out_Reg;
assign Out = Out_Reg;
always @* begin 
for (i = 0; i<to; i=i+1) begin
    Out_Reg[i] <= (~Sel&In[i])|(Sel&In[i+to]);
    end
end
endmodule



