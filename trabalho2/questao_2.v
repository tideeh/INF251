
module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b0; 
 else 
  q <= data; 
end 
endmodule //End 

// ----   FSM alto nível com Case
module stateCase(clk, reset, a, out);

input clk, reset;
input a;
output [2:0] out;
reg [2:0] state;
parameter c0=3'd2, c2=3'd3, c3=3'd0, c4=3'd4, c5=3'd1;


assign out = ( state == c0 ) ? 3'd0 :
( state == c2 ) ? 3'd2 :
( state == c3 ) ? 3'd3 :
( state == c4 ) ? 3'd4 : 3'd5;

always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = c0;
          else
               case (state)
                    c0:
                         if ( a == 1'd0 || a == 1'd1 ) state = c3;

                    c2:
                         if ( a == 1'd0 || a == 1'd1 ) state = c4;

                    c3:
                         if ( a == 1'd0 ) state = c2;
                         else if ( a == 1'd1  ) state = c5;
						 
					c4:
						if ( a == 1'd0 ) state = c0;
                        else if ( a == 1'd1  ) state = c3;

					c5:
                         if ( a == 1'd0 || a == 1'd1 ) state = c2;
						 
               endcase
     end
endmodule


// FSM com portas logicas
module statePorta(input clk, input res, input a, output [2:0] t);
wire [2:0] e;
wire [2:0] p;

assign t[0] = ~e[2] & ~e[1];
assign t[1] = ~e[2] & ( ~ ( e[1] ^ e[0] ) );
assign t[2] = ~e[1] & ( e[2] ^ e[0] );

assign p[0] = ~e[2] & ~e[1];
assign p[1] = ~e[1] & ( ( ~e[0] & ~a ) | ( ~e[2] & e[0] ) );
assign p[2] =  ~e[2] & e[1] & e[0];

ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);

endmodule 



// FSM com memoria
module stateMem(input clk,input res, input a, output [2:0] saida);
reg [5:0] StateMachine [0:9];

initial
begin  // programar ainda....
StateMachine[0] = 6'b011011;  StateMachine[1] = 6'b001011;
StateMachine[2] = 6'b011101;  StateMachine[3] = 6'b011101;
StateMachine[4] = 6'b000000;  StateMachine[5] = 6'b000000;
StateMachine[6] = 6'b100010;  StateMachine[7] = 6'b100010;
StateMachine[8] = 6'b010100;  StateMachine[9] = 6'b000100;
end

wire [3:0] address;
wire [5:0] dout;

assign address[0] = a;
assign dout = StateMachine[address];
assign saida = dout[2:0];

ff st0(dout[3],clk,res,address[1]);
ff st1(dout[4],clk,res,address[2]);
ff st2(dout[5],clk,res,address[3]);

endmodule

module main;
reg c,res;
reg a;
wire  [2:0] out;
wire  [2:0] out2;
wire  [2:0] out3;

stateMem FSMmem(c,res,a,out);
statePorta FSMporta(c,res,a,out2);
stateCase FSMcase(c,res,a,out3);


initial
    c = 1'b0;
  always
    c= #(1) ~c;

//visualizar formas de onda usar gtkwave out.vcd
initial  begin
     $dumpfile ("out.vcd"); 
     $dumpvars; 
   end 

  initial 
    begin
     $monitor($time," c %b res %b a %d outMem %d outPorta %d outCase %d ",c,res,a,out,out2,out3);
      #1 res=0; a=1'd0;
      #1 res=1;
      #14;
      $finish ;
    end
endmodule

