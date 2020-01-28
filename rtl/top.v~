`default_nettype none   

module top (
    // 25MHz clock input
    input  clk,
    input RSTN_BUTTON, // rstn,
    // Led outputs
    output [15:0] PMOD
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

//--------------------
//IO pins assigments
//--------------------
    //Names of the signals on digilent VGA PMOD adapter
    wire R0, R1, R2, R3;
    wire G0, G1, G2, G3;
    wire B0, B1, B2, B3;
    wire HS,VS;
    wire rstn;
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
    SB_IO #(
        .PIN_TYPE(6'b 0000_01),
        .PULLUP(1'b1)
    ) io_pin (
        .PACKAGE_PIN(RSTN_BUTTON),
        .D_IN_0(rstn_button_int)
    );
//--------------------
// IP internal signals
//--------------------
    //Sync signals
    wire [9:0] x_px;
    wire [9:0] y_px;
    wire px_clk;
    wire activevideo;
    VgaSyncGen vga_inst( .clk(clk), .hsync(HS), .vsync(VS), .x_px(x_px), .y_px(y_px), .px_clk(px_clk), .activevideo(activevideo));
    //Internal registers for current pixel color
    reg [3:0] R_int = 0;
    reg [3:0] G_int = 0;
    reg [3:0] B_int = 0;
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
    wire [15:0] pattern [0:16];
    assign pattern [0] =  16'b0000000000000000;
    assign pattern [1] =  16'b0000000000000000;
    assign pattern [2] =  16'b0011000000001100;
    assign pattern [3] =  16'b0011000000001100;
    assign pattern [4] =  16'b0000000000000000;
    assign pattern [5] =  16'b0000000000000000;
    assign pattern [6] =  16'b0000000000000000;
    assign pattern [7] =  16'b0000000000000000;
    assign pattern [8] =  16'b0111111111111110;
    assign pattern [8] =  16'b0111111111111110;
    assign pattern [9] =  16'b0100000000000110;
    assign pattern [10] = 16'b0110000000000110;
    assign pattern [11] = 16'b0011000000001100;
    assign pattern [12] = 16'b0001100000011000;
    assign pattern [13] = 16'b0000111111110000;
    assign pattern [14] = 16'b0000011111100000;
    assign pattern [15] = 16'b0000000000000000;
    

    //Update next pixel color
    always @(posedge px_clk, negedge rstn) begin
        if (!rstn) begin
                R_int <= 4'b0;
                G_int <= 4'b0;
                B_int <= 4'b0;
        end else
        //remember that there is a section outside the screen
        //if We don't use the active video pixel value will increase in the 
        //section outside the display as well.
        if (activevideo) begin
                R_int <= pattern[y_img][x_img]<<3;
                G_int <= pattern[y_img][x_img];
                B_int <= pattern[y_img][x_img];
        end
    end

endmodule
