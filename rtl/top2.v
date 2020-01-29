`default_nettype none   
//`define __ICARUS__ 0

module top (
    input wire clk,	      // 25MHz clock input
    input wire RSTN_BUTTON,   // rstn,
    input wire rx,            // Tx from the computer
    output wire [15:0] PMOD,   // Led outputs
    // segments outputs
    output wire [6:0] seg,
    output wire [2:0] ca
  );

//--------------------
//Local parameters
//--------------------

    //V for Video output resolution
    localparam Vwidth=640;
    localparam Vheight=480;
    //C for Character resolution
    localparam Cwidth=16;
    localparam Cheight=16;
    //Number of columns and rows
    localparam Ncol=Vwidth/Cwidth;
    localparam Nrow=Vheight/Cheight;

    localparam pixels_segundo = 100;
    localparam limiteContador = 31000000/pixels_segundo;

    localparam squareSize = 18;
   
    localparam HposHole = 300;
    localparam VposHole = 198;


//--------------------
//IO pins assigments
//--------------------
    //Names of the signals on digilent VGA PMOD adapter
    wire R0, R1, R2, R3;
    wire G0, G1, G2, G3;
    wire B0, B1, B2, B3;
    wire HS,VS;
    wire rstn;
    wire px_clk;
    //pmod1
    assign PMOD[0] = B0;
    assign PMOD[1] = B1;
    assign PMOD[2] = B2;
    assign PMOD[3] = B3;
    assign PMOD[4] = R0;
    assign PMOD[5] = R1;
    assign PMOD[6] = R2;
    assign PMOD[7] = R3;
    //pmod2
    assign PMOD[8] = HS;
    assign PMOD[9] = VS;
    assign PMOD[10] = 0;
    assign PMOD[11] = 0;
    assign PMOD[12] = G0;
    assign PMOD[13] = G1;
    assign PMOD[14] = G2;
    assign PMOD[15] = G3;
    //sync reset from button and enable pull up
    wire rstn_button_int; //internal signal after pullups
    reg bf1_rstn;
    reg bf2_rstn;
    always @(posedge px_clk) begin
        bf1_rstn <= rstn_button_int;
        bf2_rstn <= bf1_rstn;
    end
    assign  rstn = bf2_rstn;
    //Reset button
    `ifdef __ICARUS__	
    `else
    SB_IO #(
        .PIN_TYPE(6'b 0000_01),
        .PULLUP(1'b1)
    ) io_pin (
        .PACKAGE_PIN(RSTN_BUTTON),
        .D_IN_0(rstn_button_int)
    );
    `endif

    //signals from UART
    wire wr;
    wire [7:0] data;

    //local signals for UART
    reg  wr1 = 1;
    wire wr_f;
    reg [7:0] regData = 0;

//--------------------
// IP internal signals
//--------------------
    //Sync signals
    wire [9:0] x_px;
    wire [9:0] y_px;
    wire activevideo;
    VgaSyncGen vga_inst( .clk(clk), .hsync(HS), .vsync(VS), .x_px(x_px), .y_px(y_px), .px_clk(px_clk), .activevideo(activevideo));
    //Internal registers for current pixel color
    reg [3:0] R_int = 0;
    reg [3:0] G_int = 0;
    reg [3:0] B_int = 0;

    //posicion de los elementos
    reg [9:0] HposSquare = 0;
    reg [9:0] VposSquare = 200;
    wire [9:0] Hmovement;
    wire [9:0] Vmovement;

    reg [18:0] contador = 0;
    wire [9:0] HposSquare_n;
    wire [9:0] VposSquare_n;

    //RGB values assigment from pixel color register
    assign R0 = activevideo ? R_int[0] :0; 
    assign R1 = activevideo ? R_int[1] :0; 
    assign R2 = activevideo ? R_int[2] :0; 
    assign R3 = activevideo ? R_int[3] :0; 
    assign G0 = activevideo ? G_int[0] :0; 
    assign G1 = activevideo ? G_int[1] :0; 
    assign G2 = activevideo ? G_int[2] :0; 
    assign G3 = activevideo ? G_int[3] :0; 
    assign B0 = activevideo ? B_int[0] :0; 
    assign B1 = activevideo ? B_int[1] :0; 
    assign B2 = activevideo ? B_int[2] :0; 
    assign B3 = activevideo ? B_int[3] :0; 
    
    //Track current column and row
    `ifdef ASSERTIONS
        assert Cwidth == 16;
        assert Cheight == 16;
        //if that assertions fail current_col current_row range need to change
        //along other parameters as the lookup and pixel within image
    `endif
    wire [9:0] current_col;
    wire [9:0] current_row;
    assign current_col = x_px[9:4];
    assign current_row = y_px[9:4];
    //x_img and y_img are used to index within the look up
    wire [3:0] x_img;
    wire [3:0] y_img;
    assign x_img = x_px[3:0]; 
    assign y_img = y_px[3:0];
    
    //Simple image tests, replace by memory instance and font instead
    wire [19:0] pattern [0:19];
    assign pattern [0] =   20'b00000000000000000000;
    assign pattern [1] =   20'b00000000000000000000;
    assign pattern [2] =   20'b00111111111111111100; 
    assign pattern [3] =   20'b00111111111111111100; 
    assign pattern [4] =   20'b00111111111111111100; 
    assign pattern [5] =   20'b00111111111111111100; 
    assign pattern [6] =   20'b00111111111111111100; 
    assign pattern [7] =   20'b00111111111111111100; 
    assign pattern [8] =   20'b00111111111111111100; 
    assign pattern [9] =   20'b00111111111111111100;
    assign pattern [10] =  20'b00111111111111111100;
    assign pattern [11] =  20'b00111111111111111100;
    assign pattern [12] =  20'b00111111111111111100;
    assign pattern [13] =  20'b00111111111111111100;
    assign pattern [14] =  20'b00111111111111111100;
    assign pattern [15] =  20'b00111111111111111100;
    assign pattern [16] =  20'b00111111111111111100;
    assign pattern [17] =  20'b00111111111111111100;
    assign pattern [18] =  20'b00000000000000000000;
    assign pattern [19] =  20'b00000000000000000000;
    

    //Update next pixel color
    always @(posedge px_clk) begin
        if (!rstn) begin
                R_int <= 4'b0;
                G_int <= 4'b0;
                B_int <= 4'b0;
		HposSquare <= 0;
		contador <= 0;
        end else
        if (activevideo) begin
		if ((x_px >= HposHole) && (x_px < HposHole + 20) && (y_px >= VposHole) && (y_px < VposHole + 20))
			G_int <= {~pattern[y_px-VposHole][x_px -HposHole], 3'b000};
		else
			G_int <= 4'b0000;

		if ((x_px >= HposSquare) && (x_px < HposSquare + squareSize) && (y_px >= VposSquare) && (y_px < VposSquare + squareSize))
			R_int <= 4'b1000;
		else
			R_int <= 4'b0000;

                //contador
		contador <= (contador == limiteContador) ? 0 : contador + 1;
		if (contador == limiteContador) begin
			HposSquare <= HposSquare_n;
			VposSquare <= VposSquare_n;
		end
		else begin
			HposSquare <= HposSquare;
			VposSquare <= VposSquare;
		end
       	end
    end

    assign HposSquare_n = HposSquare + Hmovement;
    assign VposSquare_n = VposSquare + Vmovement;


    assign Hmovement = (regData == 32) ? 0:
		       (regData == 67) ? 1:
		       (regData == 68) ? -1 : 0;
   
    assign Vmovement = (regData == 32) ? 0:
		       (regData == 66) ? 1:
		       (regData == 65) ? -1 : 0;

    

//---------------------------
//          UART-RX
//---------------------------
		

	
	rxuart #(.baudRate(115200), .if_parity(1'b0))
		reciver (.i_clk(clk), .rst(rstn), .o_wr(wr), .o_data(data), .i_uart_rx(rx));

	//flank detector and register for the data from the UART
	always @(posedge clk) begin
		if (!rstn) begin
			wr1 <= 1;
			regData <= 0;
		end
		else begin
			wr1 <= wr;
			if (wr_f)
				regData <= data; 
			else 
				regData <= regData;
		end
	end
	
	assign wr_f = (wr & ~wr1);



//-----------------
//     7segs
//-----------------
	sevenSeg S7 (.clk(clk), .binary(regData), .seg(seg), .ca(ca));

  

endmodule
