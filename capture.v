
module frame_capture#(
			parameter H_RES = 160,               
 			parameter V_RES = 120     
		)
	(   
		input wire clk,
		input wire rst,	
		input wire begin_cap,
		output reg frame_done,
	
		//camera signals
		input wire hs,
		input wire vs,
		input wire pclk_in,
		input wire [7:0] pix_data,     

		//ram write fifo signals
		output reg w_clk,	
		output wire w_en,		
		output reg [31:0] w_data,
		input wire [6:0] w_count,
	
		//ram command fifo signals	
		output reg cmd_en,
		output reg [5:0] cmd_bl,
		output reg [29:0] cmd_addr
           
	 );




parameter IDLE = 2'd0,
	  START = 2'd1,
	  WAIT = 2'd2,
	  DATA = 2'd3,
	  W_LOAD = 1'b0,
	  W_WAIT = 1'b1,
	  BURST = 40;


reg [1:0] state;
reg w_state;

reg prev_pclk;
reg [2:0] loc;
reg [7:0] pix_buff[0:3];
reg start_en;
reg pclk,pclk_4;
reg dec_burst;		

reg [29:0] cmd_addr_new;
reg [9:0] c_count;
reg [1:0] ctr;
reg [19:0] pix_count;


wire [6:0] burst;

assign latch_data = (hs && (pclk && (pclk ^ prev_pclk))) ? 1'b1 : 1'b0;		

assign w_en = (start_en && hs) ? 1'b1 : 1'b0;	

assign w_almost_full = (w_count == burst) ? 1'b1 : 1'b0;

assign rem_burst = (pix_count == (2*H_RES*V_RES - 1)) ? 1'b1 : 1'b0;

assign burst = (rem_burst) ? w_count : BURST;








always @(posedge clk) begin

pclk <= pclk_in;					
prev_pclk <= pclk;
frame_done <= 1'b0;

if(rst)				
state <= IDLE;

else
case(state)

	IDLE:	
		if(begin_cap) begin

		pix_count <= 20'd0;
		state <= START;
		
		end
	START:	
		if(vs)                           
		state <= WAIT;

	WAIT:	
		if(!vs)
		state <= DATA;

	DATA:	
		begin

		if(!vs) begin

			if(latch_data) begin						
			
			pix_buff[loc] <= pix_data;
			pix_count <= pix_count + 1'b1;
	
			end

		end
	
		else begin

		frame_done <= 1'b1;
		

		end

		end


endcase

end


always @(posedge clk) begin

if(rst)  begin		

loc <= 3'd0;
start_en <= 1'b0;

end


else begin

	if(latch_data)
	loc <= loc + 1'b1;

	if(loc == 3'd4) begin

	w_data <= {pix_buff[3],pix_buff[2],pix_buff[1],pix_buff[0]};
	loc <= 3'd0;
	start_en <= 1'b1;

	end
end

end




always @(posedge clk) begin	

cmd_en <= 1'b0;

if(rst) begin

cmd_addr_new <= 30'h0;	
c_count <= 10'd1;	
w_state <= W_LOAD;
dec_burst <= 1'b0;
pclk_4 <= 1'b0;

end

else
case(w_state)


	
	W_LOAD:	
		
		if(w_almost_full) begin

		cmd_en <= 1'b1;
		cmd_bl <= burst - 1;		
		cmd_addr <= cmd_addr_new;
		w_state <= W_WAIT;
		c_count <= c_count + 1'b1;

		end

	W_WAIT:	
		if(!w_almost_full) begin
			
		dec_burst <= ~dec_burst;		
		cmd_addr_new <= BURST*(2**c_count);
		w_state <= W_LOAD;
			
		end

endcase

end



//ram write_clock gen. 4 pclk's for one w_data packet
always @(posedge pclk)
pclk_4 <= ~pclk_4;

always @(posedge pclk_4)
w_clk <= ~w_clk;




endmodule

