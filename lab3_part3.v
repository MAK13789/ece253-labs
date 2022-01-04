
module part3(A, B, Function, ALUout);
	input [3:0] A;
	input [3:0] B;
	input [2:0] Function;
	
	output reg [7:0] ALUout;
	
	wire [4:0] wire_0;
	part2 fourbitadder(
		.c_in(1'b0),
		.a(A),
		.b(B),
		.s(wire_0[3:0]),
		.c_out(wire_0[4])
	);
	
	
	always @(*) // declare always block
	begin // + {4{B[3]}, B};
		case (Function) // start case statement
			3'b000: ALUout = {4'b0000, wire_0};
			3'b001: ALUout = /* {{4{A[3]}}, A} + {{4{B[3]}}, B} */ A + B; 
			3'b010: ALUout = {{4{B[3]}}, B};
			3'b011: if (A | B) ALUout = 8'b00000001; else ALUout = 8'b00000000;
			3'b100: if (A & B) ALUout = 8'b00000001; else ALUout = 8'b00000000;
			3'b101: ALUout = {A, B};
			default: ALUout = 8'b00000000; // default case
		endcase
	end
endmodule


module part2(a, b, c_in, s, c_out);
	input [3:0] a;
	input [3:0] b;
	input c_in;
	
	wire [2:0] c_w;
	
	output [3:0] s;
	output c_out;
	
	full_adder adder1(
		.c_in(c_in),
		.a(a[0]),
		.b(b[0]),
		.s(s[0]),
		.c_out(c_w[0])
	);

	full_adder adder2(
		.c_in(c_w[0]),
		.a(a[1]),
		.b(b[1]),
		.s(s[1]),
		.c_out(c_w[1])
	);

	full_adder adder3(
		.c_in(c_w[1]),
		.a(a[2]),
		.b(b[2]),
		.s(s[2]),
		.c_out(c_w[2])
	);

	full_adder adder4(
		.c_in(c_w[2]),
		.a(a[3]),
		.b(b[3]),
		.s(s[3]),
		.c_out(c_out)
	);
	
endmodule

	

module full_adder(c_in, a, b, s, c_out);
	input a;
	input b;
	input c_in;
	
	output s;
	output c_out;
	
	assign s = c_in ^ (a ^ b);
	assign c_out = (a & b) | (b & c_in) | (a & c_in);

endmodule


module part1(MuxSelect, Input, Out);
	input [2:0] MuxSelect;
	input [6:0] Input;

	output reg Out; // declare the output signal for the always block
	always @(*) // declare always block
	begin
		case (MuxSelect[2:0]) // start case statement
			3'b000: Out = Input[0]; // case 0
			3'b001: Out = Input[1]; // case 1
			3'b010: Out = Input[2]; // case 2
			3'b011: Out = Input[3]; // case 3
			3'b100: Out = Input[4]; // case 4
			3'b101: Out = Input[5]; // case 5
			3'b110: Out = Input[6]; // case 6
			default: Out = 0; // default case
		endcase
	end
endmodule