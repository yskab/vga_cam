


module ov7670_regs (

				    input wire clk,
				    input wire [4:0]  addr,
					output reg [15:0] b

				   );



always @(posedge clk)

begin
					
	case(addr)
		
		0:	b <= 16'h8012;	        //reset all registers
		1:	b <= 16'h1a3e;
		2:	b <= 16'h2272;
		3:	b <= 16'hF273;
		4:	b <= 16'h1617;
		5:	b <= 16'h0418;
		6:	b <= 16'ha432;
		7:	b <= 16'h0219;
		8:	b <= 16'h7a1a;
		9:	b <= 16'h0a03;
		10:	b <= 16'h040C;
		11: b <= 16'h0012;
		12: b <= 16'h008C;
		13: b <= 16'h0004;
		14: b <= 16'hC040;
		15: b <= 16'h6A14;
		16: b <= 16'h804F;
		17: b <= 16'h8050;
		18: b <= 16'h0051;
		19: b <= 16'h2252;
		20: b <= 16'h5E53;
		21: b <= 16'h8054;
		22: b <= 16'h403D;	
	endcase
end

endmodule







	
