


//i2c standard 100khz

module i2c_core( 
				 input wire clk,
				 input wire i2c_reset,
				 output reg sda,scl,
				 input wire [15:0] i2c_in_data,
				 output reg [4:0] val_addr,
				 output wire i2c_start_tx

				);




 parameter IDLE = 3'b000, 
		   START = 3'b001,
		   DATA = 3'b010,
		   ACK  = 3'b011,
		   STOP = 3'b100,
		   INIT = 3'b110,
		   DELAY_STOP = 3'b111,
		   DELAY_5US = 500,
		   I2C_WADDR = 8'h42,  //I2C write addr
		   TOTAL = 22;  	    //total regs to be set.

 reg [2:0] state;
 reg [3:0] n_b;
 reg [2:0] n_pkt;
 reg [7:0] data;
 reg [11:0] ctr;
 reg [15:0] i2c_data;
 reg start_clk;
 reg prev_tick_clk;
 reg d;
 reg [8:0] ctr_delay = 9'd0;
 reg [16:0] i = 10'd0;
 wire [16:0] reset_delay;

 assign i2c_start_tx = (val_addr <= TOTAL)? 1'b1: 1'b0;
 
 assign reset_delay = (val_addr == 1)? 17'd100000: 17'd4;       //500ms delay after module reset


 //100khz clock module
 i2c_clk clk_100khz( .clk(clk),
					 .tick_clk(tick_clk),
                     .start_clk(start_clk)
                    );



 always @(posedge clk)
 begin

    prev_tick_clk <= tick_clk;

    if(i2c_reset)	
    begin
        state <= IDLE;
        n_b <= 4'd0;
        n_pkt <= 3'd0;
        val_addr <= 6'b0;
        start_clk <= 1'b0;
    end

	else
	begin
		
		case(state)

			IDLE:	begin
						sda <= 1'bz;
						scl <= 1'bz;
						d <= delay(reset_delay);
						if(i2c_start_tx)
						begin
							if(d)
								state <= START;
						end
					end

			START:	begin                               //i2c start signal
						sda <= 1'b0;
						d <= delay(1);                  //5us delay
						if(d)
						begin
							state <= INIT;
							data <= I2C_WADDR;
							i2c_data <= i2c_in_data;
							n_pkt <= 3'd0;
						end
					end

			INIT:	begin
						scl <= 1'b0;
						d <= delay(2);
						if(d)
						begin
							n_b <= 4'd0;
							state <= DATA;
						end
					end

			DATA:	begin
						start_clk <= 1'b1;
						if(n_pkt < 3)			
						begin
							scl <= (tick_clk)? 1'bz : 1'b0;
							sda <= (data[7]) ? 1'bz : 1'b0;
							if(n_b <= 7)
							begin
								if((prev_tick_clk ^ tick_clk ) && (tick_clk == 1'b0))
								begin
									data <= data << 1;
									n_b <= n_b + 1'b1;
								end
							end
							else
							begin
								d <= delay(1);
								if(d)
								begin
									state <= ACK;
									n_pkt <= n_pkt + 1'b1;
								end	
							end
						end

					end

			ACK:	begin	                                //ignoring ack..not reading ack.
						sda <= 1'bz;
						scl <= (tick_clk)? 1'bz : 1'b0;
						d <= delay(2);                          //10us delay
						if(d)	
						begin
							scl <= 1'b0;
							data <= i2c_data & 8'hFF;
							i2c_data <= i2c_data >> 8;
							if(n_pkt == 3)
							begin
								val_addr <= val_addr + 1'b1;
								state <= STOP;
							end
							else
								state <= INIT;
							
						end			
					end	

			STOP:	 begin                                      //i2c stop signal
		
						scl <= 1'b0;
						sda <= 1'b0;
						d <= delay(2);
						if(d)
						begin
							scl <= 1'bz;
							state <= DELAY_STOP;
						end		

					  end	

			DELAY_STOP:		begin
								d <= delay(1);
								if(d)
								begin
									sda <= 1'bz;
									state <= IDLE;
								end	
							end
							
							
												
				
		endcase
	end
 end




 //function to provide delay in multiples of 5us
 function delay;
 input [16:0] count;
 begin
 	 if(i < count)
 	 begin
	 	 delay = 1'b0;
		 ctr_delay = ctr_delay + 1'b1;
		 if(ctr_delay == DELAY_5US)
		 begin
			 ctr_delay = 9'd0;
			 i = i + 1'b1;
		 end
	 end
	 else
	 begin
		 delay = 1'b1;
		 i = 17'd0;
	 end

 end
 endfunction



 endmodule
 
