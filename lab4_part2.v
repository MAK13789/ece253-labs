
module part2(Clock, Reset_b, Data, Function, ALUout);
	input Clock;
	input Reset_b;
	input [3:0] Data;
	input [2:0] Function;

	output reg [7:0] ALUout;
	
	wire [4:0] wire_0;
	part2_lab3 fourbitadder(
		.c_in(1'b0),
		.a(Data),
		.b(ALUout[3:0]),
		.s(wire_0[3:0]),
		.c_out(wire_0[4])
	);


	reg [7:0] wire_1;

	always @(*) // declare always block
	begin
		case (Function) // start case statement
			3'b000: wire_1 = {3'b000, wire_0};
			3'b001: wire_1 = Data + ALUout[3:0];
			3'b010: wire_1 = {{4{ALUout[3]}}, ALUout[3:0]};
			3'b011: if (Data | ALUout[3:0]) wire_1 = 8'b00000001; else wire_1 = 8'b00000000;
			3'b100: if (Data & ALUout[3:0]) wire_1 = 8'b00000001; else wire_1 = 8'b00000000;
			3'b101: wire_1 = ALUout << Data; // Guess we'll see in the sanity check.
			3'b110: wire_1 = Data * ALUout[3:0];
			3'b110: wire_1 = ALUout;
			default: wire_1 = 8'b00000000;
		endcase
	end
	
	always @(posedge Clock) // triggered every time clock rises
	begin
		if (Reset_b == 1'b0) // when Reset b is 0 (note this is tested on every rising clock edge)
			ALUout <= 8'b00000000; // q is set to 0. Note that the assignment uses <=
		else // when Reset b is not 0
			ALUout <= wire_1; // value of d passes through to output q
	end

endmodule

module part2_lab3(a, b, c_in, s, c_out);
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
