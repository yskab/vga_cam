

 module i2c_clk(
			   input wire clk,
			   output wire tick_clk,
			   input wire start_clk

  			   );
 

 
 reg [9:0] i2c_ctr;
 reg out = 1'b1;

 assign tick_clk = out;
 parameter DELAY = 500;

 always @(posedge clk)
 begin
 	if(start_clk)
	begin
		if(i2c_ctr == DELAY)
		begin
			out <= ~out;	
			i2c_ctr <= 10'd0;
		end
		else
			i2c_ctr <= i2c_ctr + 1'b1;
	end

	else
	 	begin
			i2c_ctr <= 10'd0;
	 	end

 end

	
endmodule
	
