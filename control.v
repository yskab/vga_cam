


module fsm_control(

			input wire clk,
			input wire start_button,	//only once after powerup
			input wire click_button,	//take picture


			output reg i2c_reset,
			input wire i2c_done,

			output reg begin_cap,
			input wire done_cap,
			input wire [5:0] w_cmd_bl,
			input wire [29:0] w_cmd_addr,
			input wire w_cmd_en,

			output reg begin_read,
			input wire read_done,
			input wire r_cmd_en,
			input wire [5:0] r_cmd_bl,
			input wire [29:0] r_cmd_addr,

			input wire calib_done,
			output reg ram_reset,
			output reg cmd_en,
			output reg [2:0] cmd_inst,
			output reg [5:0] cmd_bl,
			output reg [29:0] cmd_addr

		);





reg [1:0] state;
reg write_cmd;

parameter RAM_CALIB = 2'd0,
	  CAM_INIT = 2'd1,
	  CAPTURE = 2'd2,
	  SEND = 2'd3;


always @(posedge clk) begin

ram_reset <= 1'b1;		
				//capture module will start the write clock
if(start_button) begin

state <= RAM_CALIB;
ram_reset <= 1'b0;

end


else
case(state)


	RAM_CALIB:	
		
		if(calib_done) begin				//wait till ram calibration.
								
		state <= CAM_INIT;
		i2c_reset <= 1'b1;

		end

	CAM_INIT:						//initialize camera registers
		
		begin

		i2c_reset <= 1'b0;
		if(i2c_done)
		state <= CAPTURE;				

		end


	CAPTURE:
		begin
			
		write_cmd <= 1'b1;
		begin_cap <= 1'b1;
		if(click_button) begin			
		
		begin_cap <= 1'b0;
		state <= SEND;

		end

		end

	SEND:
		if(done_cap) begin
		
		write_cmd <= 1'b0;	
		begin_read <= 1'b1;		
		
			if(read_done) begin		
			
			begin_read <= 1'b0;
			state <= CAPTURE;
		
			end

		end
		


endcase

end






always @(posedge clk) begin


if(write_cmd) begin
		
cmd_en <= w_cmd_en;
cmd_inst <= 3'd0;
cmd_bl <= w_cmd_bl;		
cmd_addr <= w_cmd_addr;

end

else begin		

cmd_en <= r_cmd_en;
cmd_inst <= 3'd1;
cmd_bl <= r_cmd_bl;
cmd_addr <= r_cmd_addr;

end




end



endmodule
