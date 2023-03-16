`timescale 1ns/1ns
module bmp_sim_VIP_tb();

integer	iBmpFileId	;
integer	oBmpFileId_1	;
integer	oBmpFileId_2	;
integer	oBmpFileId_3	;

integer	oTxtFileId	;
integer	iIndex=0	;
integer	pixel_index	=	0	;

integer	iCode	;
integer	iBmpWidth	;
integer	iBmpHight	;
integer	iBmpSize	;
integer	iDataStartIndex	;

reg	[7:0]			rBmpData[0:2000000]			;
reg	[7:0]			Vip_BmpData_1[0:2000000]			;
reg	[7:0]			Vip_BmpData_2[0:2000000]			;
reg	[7:0]			Vip_BmpData_3[0:2000000]			;
reg	[31:0]			rBmpWord			;
reg	[7:0]			pixel_data			;

reg					clk			;
reg					rst_n			;

reg	[7:0]			vip_pixel_data_1[0:921600]			;
reg	[7:0]			vip_pixel_data_2[0:921600]			;
reg	[7:0]			vip_pixel_data_3[0:921600]			;


initial	begin

iBmpFileId	=	$fopen("E:\\githubPrj\\fpga_image_processing\\rgb2ycbcr\\sim\\3.bmp","rb");

iCode = $fread(rBmpData,iBmpFileId);
iBmpWidth	={rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
iBmpHight	={rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
iBmpSize	={rBmpData[5],rBmpData[4],rBmpData[3],rBmpData[2]};
iDataStartIndex	={rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};

$fclose(iBmpFileId);

oBmpFileId_1=$fopen("E:\\githubPrj\\fpga_image_processing\\rgb2ycbcr\\sim\\out_pic_1.bmp","wb+");
oBmpFileId_2=$fopen("E:\\githubPrj\\fpga_image_processing\\rgb2ycbcr\\sim\\out_pic_2.bmp","wb+");
oBmpFileId_3=$fopen("E:\\githubPrj\\fpga_image_processing\\rgb2ycbcr\\sim\\out_pic_3.bmp","wb+");

#13000000

////////////
for(iIndex	=0	;iIndex<iBmpSize;iIndex=iIndex+1)	begin
	if(iIndex	<54)
		Vip_BmpData_1[iIndex]=rBmpData[iIndex];
	else
		Vip_BmpData_1[iIndex]=vip_pixel_data_1[iIndex-54];

end
	
for(iIndex	=0	;iIndex<iBmpSize;iIndex=iIndex+4)	begin
	rBmpWord={Vip_BmpData_1[iIndex+3],Vip_BmpData_1[iIndex+2],Vip_BmpData_1[iIndex+1],Vip_BmpData_1[iIndex]};
	$fwrite(oBmpFileId_1,"%u",rBmpWord);
end


////////////
for(iIndex	=0	;iIndex<iBmpSize;iIndex=iIndex+1)	begin
	if(iIndex	<54)
		Vip_BmpData_2[iIndex]=rBmpData[iIndex];
	else
		Vip_BmpData_2[iIndex]=vip_pixel_data_2[iIndex-54];

end
	
for(iIndex	=0	;iIndex<iBmpSize;iIndex=iIndex+4)	begin
	rBmpWord={Vip_BmpData_2[iIndex+3],Vip_BmpData_2[iIndex+2],Vip_BmpData_2[iIndex+1],Vip_BmpData_2[iIndex]};
	$fwrite(oBmpFileId_2,"%u",rBmpWord);
end

////////////
for(iIndex	=0	;iIndex<iBmpSize;iIndex=iIndex+1)	begin
	if(iIndex	<54)
		Vip_BmpData_3[iIndex]=rBmpData[iIndex];
	else
		Vip_BmpData_3[iIndex]=vip_pixel_data_3[iIndex-54];

end
	
for(iIndex	=0	;iIndex<iBmpSize;iIndex=iIndex+4)	begin
	rBmpWord={Vip_BmpData_3[iIndex+3],Vip_BmpData_3[iIndex+2],Vip_BmpData_3[iIndex+1],Vip_BmpData_3[iIndex]};
	$fwrite(oBmpFileId_3,"%u",rBmpWord);
end

$fclose(oBmpFileId_1);
$fclose(oBmpFileId_2);
$fclose(oBmpFileId_3);

end

initial	begin
	clk	=	1	;
	rst_n	=	0	;
	#110
	rst_n	=	1	;
end

always	#10	clk	=~clk	;

always@(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		pixel_data	<=	8'd0	;
		pixel_index	<=	0	;
	end
	else	begin
		pixel_data	<=	rBmpData[pixel_index]	;
		pixel_index	<=	pixel_index+1;
	end
	
end

///产生摄像头时序
wire				cmos_vsync			;
reg					cmos_href			;
wire				cmos_clken			;
reg	[23:0]			cmos_data			;
reg					cmos_clken_r			;
reg	[31:0]			cmos_index			;

parameter	[10:0]	IMG_HDISP	=	11'd640	;
parameter	[10:0]	IMG_VDISP	=	11'd480	;

localparam	H_SYNC	=	11'd5	;
localparam	H_BACK	=	11'd5	;
localparam	H_DISP	=	IMG_HDISP	;
localparam	H_FRONT	=	11'd5	;
localparam	H_TOTAL	=	H_SYNC	+	H_BACK+H_DISP+H_FRONT	;

localparam	V_SYNC	=	11'd1	;
localparam	V_BACK	=	11'd0	;
localparam	V_DISP	=	IMG_VDISP	;
localparam	V_FRONT	=	11'd1	;
localparam	V_TOTAL	=	V_SYNC	+	V_BACK+V_DISP+V_FRONT	;

//模拟OV7725/5640驱动模块 输出使能


//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		cmos_clken_r	<=	0;
	end
	else begin
		cmos_clken_r	<=	~cmos_clken_r	;
	end
end
//水平计数器
reg	[10:0]			hcnt			;

//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		hcnt<=11'd0	;
	end
	else if(cmos_clken_r)begin
		hcnt	<=	(hcnt	<	H_TOTAL-1'b1)?hcnt+1'b1:11'd0	;
	end
end

//竖直计数器
reg	[10:0]			vcnt			;

//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		vcnt<=11'd0	;
	end
	else if(cmos_clken_r)begin
		if(hcnt==H_TOTAL-1'b1)
			vcnt	<=	(vcnt	<	V_TOTAL-1'b1)?vcnt+1'b1:11'd0	;
		else
			vcnt	<=	vcnt	;
	end
end

//场同步
reg					cmos_vsync_r			;

always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		cmos_vsync_r<=1'b0	;
	end
	else begin
		if(vcnt	<=	V_SYNC-1'b1)
			cmos_vsync_r<=1'b0	;
		else
			cmos_vsync_r<=1'b1	;
	end
end
assign	cmos_vsync	=	cmos_vsync_r	;

//行有效
wire	frame_valid_ahead=(vcnt>=V_SYNC+V_BACK	&& vcnt<V_SYNC+V_BACK+V_DISP
							&&	hcnt	>=H_SYNC+H_BACK	&&	hcnt<H_SYNC+H_BACK+H_DISP)
							?1'b1:1'b0;
							
reg					cmos_href_r			;


//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		cmos_href_r	<=0;
	end
	else begin
		if(frame_valid_ahead)
			cmos_href_r	<=	1;
		else
			cmos_href_r	<=	0;
	end
end

always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		cmos_href	<=0;
	end
	else begin		
		cmos_href	<=	cmos_href_r;		
	end
end
assign	cmos_clken	=	cmos_href&	cmos_clken_r;

///从数组中以视频格式输出 像素数据
wire	[10:0]				x_pos			;
wire	[10:0]				y_pos			;

assign	x_pos	=frame_valid_ahead?(hcnt-(H_SYNC+H_BACK)):0;
assign	y_pos	=frame_valid_ahead?(vcnt-(V_SYNC+V_BACK)):0;


//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		cmos_index	<=	0;
		cmos_data	<=	24'd0;
	end
	else begin
		cmos_index	<=	y_pos*1920+x_pos*3+54	;
		cmos_data	<=	{rBmpData[cmos_index],rBmpData[cmos_index+1],rBmpData[cmos_index+2]};
	end
end

wire				per_frame_vsync	=	cmos_vsync;
wire				per_frame_href	=	cmos_href;	
wire				per_frame_clken	=	cmos_clken;	
wire		[7:0]	per_img_red		=	cmos_data[7:0];	
wire		[7:0]	per_img_green	=	cmos_data[15:8];	
wire		[7:0]	per_img_blue	=	cmos_data[23:16];	

wire				post0_frame_vsync	;
wire				post0_frame_href	;
wire				post0_frame_clken	;
wire		[7:0]	post0_img_Y			;		
wire		[7:0]	post0_img_Cb		;	
wire		[7:0]	post0_img_Cr		;


VIP_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
(
	//global clock
	.clk				(clk),					//cmos video pixel clock
	.rst_n				(rst_n),				//system reset

	//Image data prepred to be processd
	.per_frame_vsync	(per_frame_vsync),		//Prepared Image data vsync valid signal
	.per_frame_href		(per_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken	(per_frame_clken),		//Prepared Image data output/capture enable clock
	.per_img_red		(per_img_red),			//Prepared Image red data input
	.per_img_green		(per_img_green),		//Prepared Image green data input
	.per_img_blue		(per_img_blue),			//Prepared Image blue data input
	
	//Image data has been processd
	.post_frame_vsync	(post0_frame_vsync	),		//Processed Image frame data valid signal
	.post_frame_href	(post0_frame_href	),		//Processed Image hsync data valid signal
	.post_frame_clken	(post0_frame_clken	),		//Processed Image data output/capture enable clock
	.post_img_Y			(post0_img_Y),			//Processed Image brightness output
	.post_img_Cb		(post0_img_Cb),			//Processed Image blue shading output
	.post_img_Cr		(post0_img_Cr)			//Processed Image red shading output
);

///VIP算法---二值化
wire	post1_frame_vsync	;
wire	post1_frame_href	;
wire	post1_frame_clken	;
wire	post1_img_Bit		;

binarization	u_VIP_Gray_Median_Filter_1(

    .clk             (clk    ),   // 时钟信号
    .rst_n           (rst_n  ),   // 复位信号（低有效）
    
	
    .pre_frame_vsync (post0_frame_vsync	),   // vsync信号
    .pre_frame_hsync (post0_frame_href	),   // hsync信号
    .pre_frame_de    (post0_frame_clken	),   // data enable信号
    .color           (post0_img_Cb		),
                     
					 
    .post_frame_vsync(post1_frame_vsync),   // vsync信号
    .post_frame_hsync(post1_frame_href	),   // hsync信号
    .post_frame_de   (post1_frame_clken),   // data enable信号
    .monoc           (post1_img_Bit),   // monochrome（1=白，0=黑）
    .monoc_fall      ()
);


///VIP算法---二值化
wire	post2_frame_vsync	;
wire	post2_frame_href	;
wire	post2_frame_clken	;
wire	post2_img_Bit		;

binarization	u_VIP_Gray_Median_Filter_2(

    .clk             (clk    ),   // 时钟信号
    .rst_n           (rst_n  ),   // 复位信号（低有效）
    
	
    .pre_frame_vsync (post0_frame_vsync	),   // vsync信号
    .pre_frame_hsync (post0_frame_href	),   // hsync信号
    .pre_frame_de    (post0_frame_clken	),   // data enable信号
    .color           (post0_img_Cb		),
                     
					 
    .post_frame_vsync(post2_frame_vsync),   // vsync信号
    .post_frame_hsync(post2_frame_href	),   // hsync信号
    .post_frame_de   (post2_frame_clken),   // data enable信号
    .monoc           (post2_img_Bit),   // monochrome（1=白，0=黑）
    .monoc_fall      ()
);
///VIP算法---二值化
wire	post3_frame_vsync	;
wire	post3_frame_href	;
wire	post3_frame_clken	;
wire	post3_img_Bit		;

binarization	u_VIP_Gray_Median_Filter_3(

    .clk             (clk    ),   // 时钟信号
    .rst_n           (rst_n  ),   // 复位信号（低有效）
    
	
    .pre_frame_vsync (post0_frame_vsync	),   // vsync信号
    .pre_frame_hsync (post0_frame_href	),   // hsync信号
    .pre_frame_de    (post0_frame_clken	),   // data enable信号
    .color           (post0_img_Cb		),
                     
					 
    .post_frame_vsync(post3_frame_vsync),   // vsync信号
    .post_frame_hsync(post3_frame_href	),   // hsync信号
    .post_frame_de   (post3_frame_clken),   // data enable信号
    .monoc           (post3_img_Bit),   // monochrome（1=白，0=黑）
    .monoc_fall      ()
);

///其他算法--sobel边缘检测--中值滤波省略

wire				PIC1_vip_out_frame_vsync			;
wire				PIC1_vip_out_frame_href			;
wire				PIC1_vip_out_frame_clken			;
wire	[7:0]		PIC1_vip_out_img_R			;
wire	[7:0]		PIC1_vip_out_img_G			;
wire	[7:0]		PIC1_vip_out_img_B			;


wire				PIC2_vip_out_frame_vsync			;
wire				PIC2_vip_out_frame_href			;
wire				PIC2_vip_out_frame_clken			;
wire	[7:0]		PIC2_vip_out_img_R			;
wire	[7:0]		PIC2_vip_out_img_G			;
wire	[7:0]		PIC2_vip_out_img_B			;


wire				PIC3_vip_out_frame_vsync			;
wire				PIC3_vip_out_frame_href			;
wire				PIC3_vip_out_frame_clken			;
wire	[7:0]		PIC3_vip_out_img_R			;
wire	[7:0]		PIC3_vip_out_img_G			;
wire	[7:0]		PIC3_vip_out_img_B			;

//第一张输出回答转换后的Cb
assign	PIC1_vip_out_frame_vsync	=post1_frame_vsync	;
assign	PIC1_vip_out_frame_href		=post1_frame_href	;
assign	PIC1_vip_out_frame_clken	=post1_frame_clken	;
assign	PIC1_vip_out_img_R			={8{post1_img_Bit}};
assign	PIC1_vip_out_img_G			={8{post1_img_Bit}};
assign	PIC1_vip_out_img_B			={8{post1_img_Bit}};


//第2张输出回答转换后的Cb
assign	PIC2_vip_out_frame_vsync	=post2_frame_vsync	;
assign	PIC2_vip_out_frame_href		=post2_frame_href	;
assign	PIC2_vip_out_frame_clken	=post2_frame_clken	;
assign	PIC2_vip_out_img_R			={8{post2_img_Bit}};
assign	PIC2_vip_out_img_G			={8{post2_img_Bit}};
assign	PIC2_vip_out_img_B			={8{post2_img_Bit}};


//第3张输出回答转换后的Cb
assign	PIC3_vip_out_frame_vsync	=post3_frame_vsync	;
assign	PIC3_vip_out_frame_href		=post3_frame_href	;
assign	PIC3_vip_out_frame_clken	=post3_frame_clken	;
assign	PIC3_vip_out_img_R			={8{post3_img_Bit}};
assign	PIC3_vip_out_img_G			={8{post3_img_Bit}};
assign	PIC3_vip_out_img_B			={8{post3_img_Bit}};


//寄存图像处理之后的像素数据
//第一张图片
reg	[31:0]			PIC1_vip_cnt			;
reg					PIC1_vip_vsync_r			;
reg					PIC1_vip_out_en			;


//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC1_vip_vsync_r	<=	1'b0	;
	end
	else begin
		PIC1_vip_vsync_r	<=	PIC1_vip_out_frame_vsync	;
	end
end
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC1_vip_out_en	<=	1'b1	;
	end
	else if(PIC1_vip_vsync_r  & (!PIC1_vip_out_frame_vsync))begin
		PIC1_vip_out_en	<=	1'b0	;
	end
end
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC1_vip_cnt	<=	32'd0	;
	end
	else if(PIC1_vip_out_en)begin
		if(PIC1_vip_out_frame_href	& PIC1_vip_out_frame_clken) begin
			PIC1_vip_cnt	<=	PIC1_vip_cnt+3;
			vip_pixel_data_1[PIC1_vip_cnt+0]<=PIC1_vip_out_img_R;
			vip_pixel_data_1[PIC1_vip_cnt+1]<=PIC1_vip_out_img_G;
			vip_pixel_data_1[PIC1_vip_cnt+2]<=PIC1_vip_out_img_B;
		end
	end
end

//第2张图片
reg	[31:0]			PIC2_vip_cnt			;
reg					PIC2_vip_vsync_r			;
reg					PIC2_vip_out_en			;


//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC2_vip_vsync_r	<=	1'b0	;
	end
	else begin
		PIC2_vip_vsync_r	<=	PIC2_vip_out_frame_vsync	;
	end
end
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC2_vip_out_en	<=	1'b1	;
	end
	else if(PIC2_vip_vsync_r  & (!PIC2_vip_out_frame_vsync))begin
		PIC2_vip_out_en	<=	1'b0	;
	end
end
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC2_vip_cnt	<=	32'd0	;
	end
	else if(PIC2_vip_out_en)begin
		if(PIC2_vip_out_frame_href	& PIC2_vip_out_frame_clken) begin
			PIC2_vip_cnt	<=	PIC2_vip_cnt+3;
			vip_pixel_data_2[PIC2_vip_cnt+0]<=PIC2_vip_out_img_R;
			vip_pixel_data_2[PIC2_vip_cnt+1]<=PIC2_vip_out_img_G;
			vip_pixel_data_2[PIC2_vip_cnt+2]<=PIC2_vip_out_img_B;
		end
	end
end

//第3张图片
reg	[31:0]			PIC3_vip_cnt			;
reg					PIC3_vip_vsync_r			;
reg					PIC3_vip_out_en			;


//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC3_vip_vsync_r	<=	1'b0	;
	end
	else begin
		PIC3_vip_vsync_r	<=	PIC3_vip_out_frame_vsync	;
	end
end
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC3_vip_out_en	<=	1'b1	;
	end
	else if(PIC3_vip_vsync_r  & (!PIC3_vip_out_frame_vsync))begin
		PIC3_vip_out_en	<=	1'b0	;
	end
end
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		PIC3_vip_cnt	<=	32'd0	;
	end
	else if(PIC3_vip_out_en)begin
		if(PIC3_vip_out_frame_href	& PIC3_vip_out_frame_clken) begin
			PIC3_vip_cnt	<=	PIC3_vip_cnt+3;
			vip_pixel_data_3[PIC3_vip_cnt+0]<=PIC3_vip_out_img_R;
			vip_pixel_data_3[PIC3_vip_cnt+1]<=PIC3_vip_out_img_G;
			vip_pixel_data_3[PIC3_vip_cnt+2]<=PIC3_vip_out_img_B;
		end
	end
end
endmodule
