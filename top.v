



module design_top(

			input wire clk,
			input wire start_button,		//only once after powerup
			input wire click_button,		//take picture		


			//i2c lines
                 	output wire sda,scl,        

			//spi lines
			output wire miso,
			input wire spi_clk,
			output reg spi_start,			//instruct OPI to start capture

			//camera lines
			input wire hs,vs,pclk_in,
			input wire [7:0] pix_data,

			//ram lines
   			output		calib_done,
			output          error,
   			inout  [15:0]   mcb3_dram_dq,
   			output [12:0]   mcb3_dram_a,
   			output [1:0]    mcb3_dram_ba,
   			output          mcb3_dram_cke,
   			output          mcb3_dram_ras_n,
   			output          mcb3_dram_cas_n,
   			output          mcb3_dram_we_n,
   			output          mcb3_dram_dm,
   			inout           mcb3_dram_udqs,
   			inout           mcb3_rzq,
   			output          mcb3_dram_udm,
   			input           c3_sys_clk,
   			input           c3_sys_rst_i,
   			inout           mcb3_dram_dqs,
   			output          mcb3_dram_ck,
   			output          mcb3_dram_ck_n

	
		);




wire [2:0] cmd_inst;

wire [5:0] cmd_bl,
	   w_cmd_bl,
	   r_cmd_bl;

wire [29:0] cmd_addr,
	    w_cmd_addr,
	    r_cmd_addr;


wire [31:0] w_data,
	    r_data,
	    data_in;


wire [6:0] w_count;
wire [4:0] addr_rom;
wire [15:0] data_rom;



//MCB LPDDR
 ddr_ram # (
    .C3_P0_MASK_SIZE(4),
    .C3_P0_DATA_PORT_SIZE(32),
    .C3_P1_MASK_SIZE(4),
    .C3_P1_DATA_PORT_SIZE(32),
    .DEBUG_EN(0),
    .C3_MEMCLK_PERIOD(10000),
    .C3_CALIB_SOFT_IP("TRUE"),
    .C3_SIMULATION("FALSE"),
    .C3_RST_ACT_LOW(0),
    .C3_INPUT_CLK_TYPE("SINGLE_ENDED"),
    .C3_MEM_ADDR_ORDER("ROW_BANK_COLUMN"),
    .C3_NUM_DQ_PINS(16),
    .C3_MEM_ADDR_WIDTH(13),
    .C3_MEM_BANKADDR_WIDTH(2)
)
u_ddr_ram (

     .c3_sys_clk           (c3_sys_clk),
  .c3_sys_rst_i           (c3_sys_rst_i),                        

  .mcb3_dram_dq           (mcb3_dram_dq),  
  .mcb3_dram_a            (mcb3_dram_a),  
  .mcb3_dram_ba           (mcb3_dram_ba),
  .mcb3_dram_ras_n        (mcb3_dram_ras_n),                        
  .mcb3_dram_cas_n        (mcb3_dram_cas_n),                        
  .mcb3_dram_we_n         (mcb3_dram_we_n),                          
  .mcb3_dram_cke          (mcb3_dram_cke),                          
  .mcb3_dram_ck           (mcb3_dram_ck),                          
  .mcb3_dram_ck_n         (mcb3_dram_ck_n),       
  .mcb3_dram_dqs          (mcb3_dram_dqs),
  .mcb3_dram_udqs         (mcb3_dram_udqs),    
  .mcb3_dram_udm          (mcb3_dram_udm),     
  .mcb3_dram_dm           (mcb3_dram_dm),

  .c3_clk0		        (c3_clk0),
  .c3_rst0		        (c3_rst0),
	
 
  .c3_calib_done    (c3_calib_done),
  
  .mcb3_rzq               (rzq3),
        
     .c3_p0_cmd_clk                        (clk),
   .c3_p0_cmd_en                           (cmd_en),
   .c3_p0_cmd_instr                        (cmd_inst),
   .c3_p0_cmd_bl                           (cmd_bl),
   .c3_p0_cmd_byte_addr                    (cmd_addr),
   .c3_p0_wr_clk                           (w_clk),
   .c3_p0_wr_en                            (w_en),
   .c3_p0_wr_data                          (w_data),
   .c3_p0_wr_count                         (w_count),
   .c3_p0_rd_clk                           (clk),
   .c3_p0_rd_en                            (rd_en),
   .c3_p0_rd_data                          (r_data)

);





//FSM
fsm_control fsm(

		.clk(clk),
		.start_button(start_button),
		.click_button(click_button),
		

		.i2c_reset(i2c_reset),
		.i2c_done(i2c_done),

		.begin_cap(begin_cap),
		.done_cap(done_cap),
		.w_cmd_bl(w_cmd_bl),
		.w_cmd_addr(w_cmd_addr),
		.w_cmd_en(w_cmd_en),
		
		.begin_read(begin_read),
		.read_done(read_done),
		.r_cmd_en(r_cmd_en),
		.r_cmd_bl(r_cmd_bl),
		.r_cmd_addr(r_cmd_addr),

		.calib_done(calib_done),
		.ram_reset(ram_reset),
		.cmd_en(cmd_en),
		.cmd_inst(cmd_inst),
		.cmd_bl(cmd_bl),	
		.cmd_addr(cmd_addr)

);


//Capture module

frame_capture#(
		.H_RES(640),
		.V_RES(480)
	      )

	img_cap(

		.clk(clk),
		.rst(ram_reset),
		.begin_cap(begin_cap),
		.frame_done(done_cap),

		.hs(hs),
	        .vs(vs),	
		.pclk_in(pclk_in),
		.pix_data(pix_data),

		.w_clk(w_clk),
		.w_en(w_en),
		.w_data(w_data),
		.w_count(w_count),


		.cmd_en(w_cmd_en),
		.cmd_bl(w_cmd_bl),
		.cmd_addr(w_cmd_addr)


	);



//RAM read module

ram_read ram_read(
			
		.clk(clk),
		.rst(rst),
		.start_read(begin_read),
		.read_done(read_done),
		
		.spi_start(spi_start),
		.load_data(load_data),

		.cmd_en(r_cmd_en),
		.cmd_bl(r_cmd_bl),
		.cmd_addr(r_cmd_addr),

		.rd_en(rd_en),
		.rd_data_in(r_data),	
		.data(data_in)			

);



//SPI slave
spi_slave slave(
			
		.clk(clk),
		.rst(rst),
		.spi_start(spi_start),
		.load_data(load_data),
		.data_in(data_in),
		.spi_data(miso),
		.spi_clk_in(spi_clk)

);



//I2c Master
i2c_core I2c_master( 

		.clk(clk),
                .i2c_reset(i2c_reset),
    		.val_addr(addr_rom),
                .i2c_in_data(data_rom),
                .sda(sda),
                .scl(scl),
		.i2c_done(i2c_done)
);


//Camera registers
ov7670_regs rom( 

		.clk(clk),
                .addr(addr_rom),
                .b(data_rom)
);






endmodule

