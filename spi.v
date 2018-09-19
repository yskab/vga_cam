


module spi_slave (
			input wire clk,
			input wire rst,			
			input wire spi_start,
			output wire load_data,
			input wire [31:0] data_in,
			output reg spi_data,
			input wire spi_clk_in

		);



reg spi_clk_prev,
    spi_clk,
    state;


reg [5:0] bit_ctr;
reg [31:0] data;

parameter START = 1'b0,
	  DATA = 1'b1;

assign latch_data = ((spi_clk ^ spi_clk_prev) && spi_clk) ? 1'b1 : 1'b0;
assign load_data = ((spi_clk ^ spi_clk_prev) && !spi_clk) ? 1'b1 : 1'b0;	


always @(posedge clk) begin

spi_clk <= spi_clk_in;
spi_clk_prev <= spi_clk;

if(rst) begin				

state <= START;


end

else
case(state)


	START:
		if(spi_start) begin			
		
		state <= DATA;
		data <= data_in;
		bit_ctr <= 6'd0;

		end
	DATA:
		begin

		if(bit_ctr < 6'd32) begin

			if(latch_data) begin

			spi_data <= data[31];
			data <= data << 1;
			bit_ctr <= bit_ctr + 1'b1;

			end
		end
		else begin

		bit_ctr <= 6'd0;	
		if(load_data)			
		
		state <= START;
		end
	
		end

endcase

end


endmodule
