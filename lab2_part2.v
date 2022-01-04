module mux2to1 (x,y,s,m);
    input x;
    input y;
    input s;
    output m;

    wire con1;
    wire con2;
    wire con3;
    
    //assign m = s & y | ~s & x;
    
    v7408 u0(
        .pin1(s);
        .pin2(y);
        .pin3(con1);
    );
    
    v7404 u1(
        .pin1(s);
        .pin2(con2);
    );
    
    v7408 u2(
        .pin1(con2);
        .pin2(x);
        .pin3(con3);
    );

    v7432 u3(
        .pin1(con1);
        .pin2(con3);
        .pin3(m);
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
    assign pin8 - !pin9;
endmodule