// DataIn - input data port
// Resetn - synchronous reset
// Go signal starts things
// Dividend - Thing to divide.
// Divisor - Thing to divide by.
// Quotient - Result
// Remainder - duh.
module part3(Clock, Resetn, Go, Divisor, Dividend, Quotient, Remainder);
    input Clock;
    input Resetn;
    input Go;
    input [3:0] Dividend;
    input [3:0] Divisor;

    output [3:0] Quotient;
    output [3:0] Remainder;

    // wires
    wire ld_a, ld_dd, ld_dr, ld_msbrega, set_msbrega, ld_r, ld_all, ld_end;
	wire msb_rega;
    wire [1:0] alu_op;

    control C0(
        .clk(Clock),
        .resetn(Resetn),
        
        .go(Go),
        
        .msb_rega(msb_rega),
        .divisor(Divisor),
        .dividend(Dividend),

        .ld_a(ld_a),
        .ld_dd(ld_dd),
        .ld_dr(ld_dr),
		.ld_msbrega(ld_msbrega),
		.set_msbrega(set_msbrega),
        .ld_r(ld_r), 
        .ld_all(ld_all),
		.ld_end(ld_end),
        
        .alu_op(alu_op)
    );

    datapath D0(
        .clk(Clock),
        .resetn(Resetn),

        .dividend(Dividend),
        .divisor(Divisor),

        .ld_a(ld_a),
        .ld_dr(ld_dr),
        .ld_dd(ld_dd),
		.ld_msbrega(ld_msbrega),
		.set_msbrega(set_msbrega),
		.ld_end(ld_end),
        .ld_r(ld_r),
		.ld_all(ld_all),

        .alu_op(alu_op),
        .msb_rega(msb_rega),

        .quotient(Quotient),
        .remainder(Remainder)
    );

endmodule

module control(
    input clk,
    input resetn,
    input go,
    input msb_rega,
    input [3:0] divisor, dividend,

    output reg  ld_a, ld_dd, ld_dr, ld_r, ld_msbrega, ld_all, set_msbrega, ld_end,
    output reg [1:0] alu_op
    );

    reg [5:0] current_state, next_state; 
    reg [1:0] counter;

    localparam  S_LOAD          = 5'd0,
                S_LOAD_WAIT     = 5'd1,
				S_CYCLE_0 		= 5'd2,
				S_CYCLE_1 		= 5'd3,
				S_CYCLE_2 		= 5'd4,
				S_CYCLE_3 		= 5'd5;

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD: next_state = go ? S_LOAD_WAIT : S_LOAD;
                S_LOAD_WAIT: begin
					next_state = go ? S_LOAD_WAIT : S_CYCLE_0;
					counter= 'b0;
				end
				S_CYCLE_0: next_state = S_CYCLE_1;
				S_CYCLE_1: next_state = S_CYCLE_2;
				S_CYCLE_2: next_state = S_CYCLE_3;
				S_CYCLE_3: begin
					if(counter == 2'b11) begin
					  next_state = S_LOAD;
					  ld_r = 1'b1;
					end
					else begin
					  next_state = S_CYCLE_0;
					  counter = counter + 1;
					end
				end
            default: next_state = S_LOAD;
        endcase
    end // state_table

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0 at every time this always block is triggered.
        ld_a = 1'b0;
        ld_dd = 1'b0;
        ld_dr = 1'b0;
		ld_end = 1'b0;
		set_msbrega = 1'b0;
		ld_msbrega = 1'b0;
        ld_all = 1'b0;
		alu_op = 2'b11;

        case (current_state)
            S_LOAD_WAIT: begin
                ld_all = 1'b1;
				ld_r = 1'b0;
                end
			S_CYCLE_0: begin // do shifting left
				alu_op = 2'b10; // shifting
				ld_a = 1'b1;
				ld_end = 1'b1; // load result back to a and dd
			end
			S_CYCLE_1: begin // subtract dr from reg A and get MSB to msb_rega
				alu_op = 2'b01; // subtracting
				ld_msbrega = 1'b1;
				ld_a = 1'b1; // load result back to a
			end
			S_CYCLE_2: begin // if msb_rega == 1 then add back, else do nothing
				if(msb_rega == 1'b0) begin
				  alu_op = 2'b00; // adding
				  ld_a = 1'b1; // load result back to a
				end
			end
			S_CYCLE_3: begin // set msb_rega to 0 or 1
				set_msbrega = 1'b1;
			end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn) begin // active-low sync reset.
            current_state <= S_LOAD;
        end
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input [3:0] dividend, divisor,
    input ld_a, ld_dr, ld_dd, ld_msbrega, ld_end, ld_r, set_msbrega, ld_all,
    input [1:0] alu_op,

	output reg msb_rega,
    output reg [3:0] quotient,
    output reg [3:0] remainder
    );
    
    // input registers
    reg [4:0] a; // a is Register A, dr is register Divisor
    reg [3:0] dr, dd; // dd is Register Dividend.

    // alu input signals
    reg [4:0] alu_a;
	reg [3:0] alu_b;
    
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            a <= 'b0;
            dr <= 'b0; 
            dd <= 'b0; 
        end
        else begin
			if (ld_end) begin
				dd <= alu_b;
			end
			if (ld_a) begin
				a <= alu_a;
			end
			if (ld_msbrega) begin
				msb_rega <= ~alu_a[4];
			end
			if (set_msbrega) begin
				dd[0] = msb_rega;
			end
            if (ld_all) begin
                dd <= dividend;
                dr <= divisor;
				a <= 'b0;
            end
        end
    end
 
    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            quotient <= 'b0;
            remainder <= 'b0;
            msb_rega <= 'b0;
        end
        else begin
            if(ld_r) begin
                quotient <= dd;
                remainder <= a;
			end
		end
    end

    // The ALU - Keeping this not all alu_a and alu_b saves a ton of headache.
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            2'd0: begin
                   alu_a = a + dr; //performs addition
               end
            2'd1: begin
                   alu_a = a - dr; // performs subtraction of alu_b from divisor
               end
            2'd2: begin // shifting.
				   {alu_a, alu_b} = {a, dd} << 1; // nice and cool way to shift.
               end
            default: begin
				alu_a = 5'b0;
				alu_b = 4'b0;
			end
        endcase
    end
endmodule