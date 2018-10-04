
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

/* DIAGRAMA
                                              +----------------------------------------------------+
                                              v                                                    |
                                                                                                    |
            +-----------------------------+   +--------------------------------------+             |
            |                             |0  v                                      |             |
            |     1,2                     |                                          |             |
            |  +------------------------+ |   +----------------------+               |             |
            v  |                        v |   v                      |0,1,2          |0,1,2        |0,1,2
                |                          |                          |               |             |
            +---+-+        +-----+       +-+---+     0 +-----+       ++----+        +-+---+       +-+---+
            |     | 0      |     | 0,1   |     | <-----+     |       |     |        |     |       |     |
            |  0  +------> |  1  +-----> |  2  |       |  4  |       |  3  |        |  5  |       |  6  |
            |     |        |     |       |     | 1     |     |1,2,3  |     | 3      |     | 3     |     |
            +---+-+        ++----+       +--+--+-----> +-----------> +-+-+--------> +-----+-----> +-----+
                |           |    ^       |2 ^ |3                     ^ ^ ^ ^                        |3
                |           |    |       |  | +----------------------+ | | |                        |
                |3       2,3|    |       v  |                        ^ | | +------------------------+
                |           |    |          |0,1                     | | |
                |           |    |       +-----+                     | | |
                |           |    |       |     |                     | | |
                |           |    +-------+  3' +---------------------+ | |
                |           |           2|     |3                      | |
                |           |            +-----+                       | |
                |           |                                          | |
                |           +------------------------------------------+ |
                |                                                        |
                +--------------------------------------------------------+
*/

// ----   FSM alto nível com Case
module stateCase(clk, reset, a, out);

input clk, reset;
input [1:0] a;
output [2:0] out;
reg [2:0] state;

parameter c0=3'd0, c1=3'd1, c2=3'd2, c4=3'd3, c3=3'd4, c5=3'd5, c6=3'd6, c3t=3'd7;


assign out =  ( state == c0 ) ? 3'd0 :
              ( state == c1 ) ? 3'd1 :
              ( state == c2 ) ? 3'd2 :
              ( state == c4 ) ? 3'd4 :
              ( state == c3 || state == c3t ) ? 3'd3 :
              ( state == c5 ) ? 3'd5 : 3'd6;

always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = c0;
          else
               case (state)
                    c0:
                         if ( a == 2'd0 ) state = c1;
                         else if( a == 2'd1 || a == 2'd2 ) state = c2;
                         else state = c3;

                    c1:
                         if ( a == 2'd0 || a == 2'd1 ) state = c2;
                         else state = c3;

                    c2:
                         if ( a == 2'd0 ) state = c0;
                         else if( a == 2'd1 ) state = c4;
                         else if( a == 2'd2 ) state = c3t;
                         else state = c3;
                    
                    c4:
                         if ( a == 2'd0 ) state = c2;
                         else state = c3;

                    c3:
                         if ( a == 2'd3 ) state = c5;
                         else state = c2;

                    c5:
                         if ( a == 2'd3 ) state = c6;
                         else state = c2;

                    c6:
                         if ( a == 2'd3 ) state = c3;
                         else state = c2;

                    c3t:
                         if ( a == 2'd2 ) state = c1;
                         else if( a == 2'd3 ) state = c3;
                         else state = c2;
						 
               endcase
     end
endmodule


// FSM com portas logicas
module statePorta(input clk, input res, input [1:0] a, output [2:0] t);
wire [2:0] e;
wire [2:0] p;

//equacoes minimizadas obtidas com o software pyeda
assign t[0] = ( e[0] & e[1] & e[2] ) | ( e[0] & ~e[1] ) | ( ~e[0] & ~e[1] & e[2] );
assign t[1] = ( ~e[0] & e[1] ) | ( e[0] & e[1] & e[2] ) | ( ~e[0] & ~e[1] & e[2] );
assign t[2] = ( e[0] & e[1] & ~e[2] ) | ( e[0] & ~e[1] & e[2] ) | ( ~e[0] & e[1] & e[2] );
assign p[0] = ( ~a[0] & a[1] & ~e[0] & e[1] & ~e[2] ) | ( a[0] & ~a[1] & ~e[0] & e[1] & ~e[2] ) | ( ~a[0] & a[1] & e[0] & e[1] & e[2] ) | ( a[0] & a[1] & ~e[0] & ~e[1] & e[2] ) | ( ~a[0] & ~a[1] & ~e[0] & ~e[1] & ~e[2] );
assign p[1] = ( ~a[0] & ~a[1] & e[0] ) | ( a[0] & ~a[1] & ~e[0] & e[1] & ~e[2] ) | ( e[0] & ~e[1] & e[2] ) | ( ~a[0] & a[1] & ~e[0] ) | ( ~a[1] & e[2] ) | ( a[0] & ~a[1] & ~e[1] );
assign p[2] =  ( ~a[0] & a[1] & ~e[0] & e[1] & ~e[2] ) | ( a[1] & e[0] & ~e[2] ) | ( a[0] & e[0] & e[1] & ~e[2] ) | ( a[0] & a[1] );

ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);

endmodule 



// FSM com memoria
module stateMem(input clk,input res, input [1:0] a, output [2:0] saida);
reg [5:0] StateMachine [0:31];

initial
begin
StateMachine[0] = 6'b001000;  StateMachine[1] = 6'b010000;
StateMachine[2] = 6'b010000;  StateMachine[3] = 6'b100000;
StateMachine[4] = 6'b010001;  StateMachine[5] = 6'b010001;
StateMachine[6] = 6'b100001;  StateMachine[7] = 6'b100001;
StateMachine[8] = 6'b000010;  StateMachine[9] = 6'b011010;
StateMachine[10] = 6'b111010;  StateMachine[11] = 6'b100010;
StateMachine[12] = 6'b010100;  StateMachine[13] = 6'b100100;
StateMachine[14] = 6'b100100;  StateMachine[15] = 6'b100100;
StateMachine[16] = 6'b010011;  StateMachine[17] = 6'b010011;
StateMachine[18] = 6'b010011;  StateMachine[19] = 6'b101011;
StateMachine[20] = 6'b010101;  StateMachine[21] = 6'b010101;
StateMachine[22] = 6'b010101;  StateMachine[23] = 6'b110101;
StateMachine[24] = 6'b010110;  StateMachine[25] = 6'b010110;
StateMachine[26] = 6'b010110;  StateMachine[27] = 6'b100110;
StateMachine[28] = 6'b010011;  StateMachine[29] = 6'b010011;
StateMachine[30] = 6'b001011;  StateMachine[31] = 6'b100011;
end

wire [4:0] address;
wire [5:0] dout;

assign address[0] = a[0];
assign address[1] = a[1];
assign dout = StateMachine[address];
assign saida = dout[2:0];

ff st0(dout[3],clk,res,address[2]);
ff st1(dout[4],clk,res,address[3]);
ff st2(dout[5],clk,res,address[4]);

endmodule

module main;
reg c,res;
reg [1:0] a;
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

   //teste usando minha matricula (73995) em binario
  initial 
    begin
     $monitor($time," c %b res %b a %d outMem %d outPorta %d outCase %d ",c,res,a,out,out2,out3);
      #1 res=0; a=2'd1;
      #1 res=1;
      #1 a=2'd0;
      #1
      #1 a=2'd2;
      #1
      #1 a=2'd0;
      #1
      #1 a=2'd1;
      #1
      #1 a=2'd0;
      #1
      #1 a=2'd0;
      #1
      #1 a=2'd2;
      #1
      #1 a=2'd3;
      #1
      $finish ;
    end
endmodule
