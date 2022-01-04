
module part2(a, b, c_in, s, c_out);
	input [3:0] a;
	input [3:0] b;
	input c_in;
	
	// wire [2:0] c_w;
	
	output [3:0] s;
	output [3:0] c_out;
	
	full_adder adder1(
		.c_in(c_in),
		.a(a[0]),
		.b(b[0]),
		.s(s[0]),
		.c_out(c_out[0])
	);

	full_adder adder2(
		.c_in(c_out[0]),
		.a(a[1]),
		.b(b[1]),
		.s(s[1]),
		.c_out(c_out[1])
	);

	full_adder adder3(
		.c_in(c_out[1]),
		.a(a[2]),
		.b(b[2]),
		.s(s[2]),
		.c_out(c_out[2])
	);

	full_adder adder4(
		.c_in(c_out[2]),
		.a(a[3]),
		.b(b[3]),
		.s(s[3]),
		.c_out(c_out[3])
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