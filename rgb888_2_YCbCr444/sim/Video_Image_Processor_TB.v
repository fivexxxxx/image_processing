/*-----------------------------------------------------------------------
								 \\\|///
							   \\  - -  //
								(  @ @  )
+-----------------------------oOOo-(_)-oOOo-----------------------------+
CONFIDENTIAL IN CONFIDENCE
This confidential and proprietary software may be only used as authorized
by a licensing agreement from CrazyBingo (Thereturnofbingo).
In the event of publication, the following notice is applicable:
Copyright (C) 2013-20xx CrazyBingo Corporation
The entire notice above must be reproduced on all authorized copies.
Author				:		CrazyBingo
Technology blogs 	: 		www.crazyfpga.com
Email Address 		: 		crazyfpga@vip.qq.com
Filename			:		Video_Image_Processor_TB.v
Date				:		2013-11-08
Description			:		The testbench of cmos data of Video_Image_Processor Module.
Modification History	:
Date			By			Version			Change Description
=========================================================================
13/11/08		CrazyBingo	1.0				Original
-------------------------------------------------------------------------
|                                     Oooo								|
+-------------------------------oooO--(   )-----------------------------+
                               (   )   ) /
                                \ (   (_/
                                 \_)
-----------------------------------------------------------------------*/

`timescale 1ns/1ns
module Video_Image_Processor_TB;

//------------------------------------------
//Generate 24MHz driver clock
reg	clk; 
localparam PERIOD2 = 41;		//24MHz
initial	
begin
	clk = 0;
	forever	#(PERIOD2/2)	
	clk = ~clk;
end

//------------------------------------------
//Generate global reset
reg	rst_n;
task task_reset;
begin
	rst_n = 0;
	repeat(2) @(negedge clk);
	rst_n = 1;
end
endtask
wire	clk_cmos = clk;		//24MHz
wire	sys_rst_n = rst_n;	


//-----------------------------------------
//CMOS Camera interface and data output simulation
wire			cmos_xclk;				//24MHz drive clock
wire			cmos_pclk;				//24MHz CMOS Pixel clock input
wire			cmos_vsync;				//L: vaild, H: invalid
wire			cmos_href;				//H: vaild, L: invalid
wire	[7:0]	cmos_data;				//8 bits cmos data input
Video_Image_Simulate_CMOS	
#(
	.CMOS_VSYNC_VALID	(1'b1),     //VSYNC = 1
	.IMG_HDISP			(10'd16),	//(10'd640),	//640*480
	.IMG_VDISP			(10'd4)		//(10'd480)
)
u_Video_Image_Simulate_CMOS
(
	//global reset
	.rst_n				(sys_rst_n),	
	
	//CMOS Camera interface and data output simulation
	.cmos_xclk			(clk_cmos),			//25MHz cmos clock
	.cmos_pclk			(cmos_pclk),		//25MHz when rgb output
	.cmos_vsync			(cmos_vsync),		//L: vaild, H: invalid
	.cmos_href			(cmos_href),		//H: vaild, L: invalid
	.cmos_data			(cmos_data)			//8 bits cmos data input
);

//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
//cmos video image capture
wire			cmos_init_done = 1'b1;	///cmos camera init done
wire			cmos_frame_vsync;	//cmos frame data vsync valid signal
wire			cmos_frame_href;	//cmos frame data href vaild  signal
wire	[15:0]	cmos_frame_data;	//cmos frame data output: {cmos_data[7:0]<<8, cmos_data[7:0]}	
wire			cmos_frame_clken;	//cmos frame data output/capture enable clock
wire	[7:0]	cmos_fps_rate;		//cmos image output rate
CMOS_Capture_RGB565	
#(
	.CMOS_FRAME_WAITCNT		(4'd0)				//Wait n fps for steady(OmniVision need 10 Frame)
)
u_CMOS_Capture_RGB565
(
	//global clock
	.clk_cmos				(clk_cmos),			//24MHz CMOS Driver clock input
	.rst_n					(sys_rst_n & cmos_init_done),	//global reset

	//CMOS Sensor Interface
	.cmos_pclk				(cmos_pclk),  		//24MHz CMOS Pixel clock input
	.cmos_xclk				(cmos_xclk),		//24MHz drive clock
	.cmos_data				(cmos_data),		//8 bits cmos data input
	.cmos_vsync				(cmos_vsync),		//L: vaild, H: invalid
	.cmos_href				(cmos_href),		//H: vaild, L: invalid
	
	//CMOS SYNC Data output
	.cmos_frame_vsync		(cmos_frame_vsync),	//cmos frame data vsync valid signal
	.cmos_frame_href		(cmos_frame_href),	//cmos frame data href vaild  signal
	.cmos_frame_data		(cmos_frame_data),	//cmos frame RGB output: {{R[4:0],G[5:3]}, {G2:0}, B[4:0]}	
	.cmos_frame_clken		(cmos_frame_clken),	//cmos frame data output/capture enable clock
	
	//user interface
	.cmos_fps_rate			(cmos_fps_rate)		//cmos image output rate
);

//----------------------------------------------------
//Video Image processor module.
//Image data prepred to be processd
wire			per_frame_vsync	=	cmos_frame_vsync;	//Prepared Image data vsync valid signal
wire			per_frame_href	=	cmos_frame_href;	//Prepared Image data href vaild  signal
wire			per_frame_clken	=	cmos_frame_clken;	//Prepared Image data output/capture enable clock
wire	[7:0]	per_img_red		=	{cmos_frame_data[15:11], cmos_frame_data[15:13]};	//Prepared Image red data to be processed
wire	[7:0]	per_img_green	=	{cmos_frame_data[10:5], cmos_frame_data[10:9]};		//Prepared Image green data to be processed
wire	[7:0]	per_img_blue	=	{cmos_frame_data[4:0], cmos_frame_data[4:2]};		//Prepared Image blue data to be processed
wire			post_frame_vsync;	//Processed Image data vsync valid signal
wire			post_frame_href;	//Processed Image data href vaild  signal
wire			post_frame_clken;	//Processed Image data output/capture enable clock
wire	[7:0]	post_img_Y;			//Processed Image brightness output
wire	[7:0]	post_img_Cb;			//Processed Image blue shading output
wire	[7:0]	post_img_Cr;			//Processed Image red shading output
Video_Image_Processor	u_Video_Image_Processor
(
	//global clock
	.clk					(cmos_pclk),  			//cmos video pixel clock
	.rst_n					(sys_rst_n),			//global reset

	//Image data prepred to be processd
	.per_frame_vsync		(per_frame_vsync),		//Prepared Image data vsync valid signal
	.per_frame_href			(per_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken		(per_frame_clken),		//Prepared Image data output/capture enable clock
	.per_img_red			(per_img_red),			//Prepared Image red data to be processed
	.per_img_green			(per_img_green),		//Prepared Image green data to be processed
	.per_img_blue			(per_img_blue),			//Prepared Image blue data to be processed

	//Image data has been processd
	.post_frame_vsync		(post_frame_vsync),		//Processed Image data vsync valid signal
	.post_frame_href		(post_frame_href),		//Processed Image data href vaild  signal
	.post_frame_clken		(post_frame_clken),		//Processed Image data output/capture enable clock
	.post_img_Y				(post_img_Y),			//Processed Image brightness output
	.post_img_Cb			(post_img_Cb),			//Processed Image blue shading output
	.post_img_Cr			(post_img_Cr)			//Processed Image red shading output
);

//---------------------------------------------
//testbench of the RTL
task task_sysinit;
begin
end
endtask

//----------------------------------------------
initial
begin
	task_sysinit;
	task_reset;

end

endmodule

