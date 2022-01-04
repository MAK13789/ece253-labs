
module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset, RotateRight, ASRight, ParallelLoadn;
	input [7:0] Data_IN;
	output [7:0] Q;
	
	
	part3_sub Q7(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[6]),
		.left((ASRight ? Q[7] : Q[0])),
		.D(Data_IN[7]),
		.Q(Q[7])
	);

	part3_sub Q6(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[5]),
		.left(Q[7]),
		.D(Data_IN[6]),
		.Q(Q[6])
	);

	part3_sub Q5(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[4]),
		.left(Q[6]),
		.D(Data_IN[5]),
		.Q(Q[5])
	);
	
	part3_sub Q4(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[3]),
		.left(Q[5]),
		.D(Data_IN[4]),
		.Q(Q[4])
	);
	
	part3_sub Q3(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[2]),
		.left(Q[4]),
		.D(Data_IN[3]),
		.Q(Q[3])
	);
	
	part3_sub Q2(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[1]),
		.left(Q[3]),
		.D(Data_IN[2]),
		.Q(Q[2])
	);
	
	part3_sub Q1(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[0]),
		.left(Q[2]),
		.D(Data_IN[1]),
		.Q(Q[1])
	);
	
	part3_sub Q0(
		.clock(clock),
		.reset(reset),
		.LoadLeft(RotateRight),
		.loadn(ParallelLoadn),
		.right(Q[7]),
		.left(Q[1]),
		.D(Data_IN[0]),
		.Q(Q[0])
	);

endmodule

module part3_sub(clock, reset, LoadLeft, loadn, right, left, D, Q);
	input clock, reset, LoadLeft, loadn, right, left, D;
	output Q;

	wire rotatedata;
	wire datato_dff;

	mux2to1 M0(
		.y(left),
		.x(right),
		.s(LoadLeft),
		.m(rotatedata)
	);

	mux2to1 M1( //instantiates 2nd multiplexer
		.y(rotatedata), //output from left most multiplexer
		.x(D), //data D coming in
		.s(loadn), //selects input D or rotate
		.m(datato_dff) //outputs to flip flop
	);

	flipflop F0(
		.d(datato_dff),
		.clock(clock),
		.reset(reset),
		.q(Q)
	);
	
endmodule

module flipflop(d, q, clock, reset); // active high sync reset.
	input d, clock, reset;
	output reg q;

	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1 (note this is tested on every rising clock edge)
			q <= 1'b0; // q is set to 0. Note that the assignment uses <=
		else // when Reset b is not 0
			q <= d; // value of d passes through to output q
	end
endmodule

module mux2to1 (x,y,s,m);
	input x;
	input y;
	input s;
	output m;

 	wire con1;
	wire con2;
	wire con3;

//    assign m = s & y | ~s & x;
	
 	v7408 u0(
		.pin1(s),
		.pin2(y),
		.pin3(con1)
	);
	
	v7404 u1(
		.pin1(s),
		.pin2(con2)
	);
	
	v7408 u2(
		.pin1(con2),
		.pin2(x),
		.pin3(con3)
	);

	v7432 u3(
		.pin1(con1),
		.pin2(con3),
		.pin3(m)
	);	
endmodule


module v7408 (input pin1, pin2, pin4, pin5, pin13, pin12, pin10, pin9,
				output pin3, pin6, pin11, pin8);
		
		assign pin3 = (pin1 & pin2);
		assign pin6 = (pin5 & pin4);
		assign pin8 = (pin9 & pin10);
		assign pin11 = (pin12 & pin13);
		
endmodule // 7408 - AND chip.

module v7432(input pin1, pin2, pin4, pin5, pin13, pin12, pin10, pin9,
			 output pin3, pin6, pin11, pin8);
	assign pin3 = pin1 | pin2;
	assign pin6 = pin4 | pin5;
	assign pin11 = pin13 | pin12;
	assign pin8 = pin10 | pin9;
endmodule

module v7404(input pin1, pin3, pin5, pin13, pin11, pin9,
			 output pin2, pin4, pin6, pin12, pin10, pin8);
	assign pin2 = !pin1;
	assign pin4 = !pin3;
	assign pin6 = !pin5;
	assign pin12 = !pin13;
	assign pin10 = !pin11;
	assign pin8 = !pin9;
endmodule