



module ram_read(
			input wire clk,
			input wire rst,
			input wire start_read,
			output wire read_done,

			output reg spi_start,
			input wire load_data,
			output reg cmd_en,
			output reg [5:0] cmd_bl,
			output reg [29:0] cmd_addr,
		
			output reg rd_en,
			input wire [31:0] rd_data_in,

			output reg [31:0] data



		);





parameter MAX_ADDR = 76800;	//

reg [29:0] cmd_addr_new;

assign read_done = (cmd_addr_new == (MAX_ADDR + 1)) ? 1'b1 : 1'b0; 

reg [1:0] state;

parameter IDLE = 2'd0,
	  CMD = 2'd1,
	  WAIT = 2'd2,
	  LOAD = 2'd3;





always @(posedge clk) begin

cmd_en <= 1'b0;

if(rst) begin

state <= IDLE;
cmd_addr_new <= 30'h0;	

end

else
case(state)


	IDLE:
		if(start_read)
		state <= CMD;

		else
		spi_start <= 1'b0;

	CMD:
		begin

		cmd_en <= 1'b1;
		cmd_bl <= 6'd1;		
		cmd_addr <= cmd_addr_new;
		state <= WAIT;
	
		end
	WAIT:	
		begin
			

		state <= LOAD;
		rd_en <= 1'b1;	

		end

	LOAD:
		begin
			
		rd_en <= 1'b0;			
		data <= rd_data_in;
		spi_start <= 1'b1;
		if(load_data) begin			
		
		state <= IDLE;
		cmd_addr_new <= cmd_addr_new + 3'd4;
		
		end

		end
endcase

end




endmodule

