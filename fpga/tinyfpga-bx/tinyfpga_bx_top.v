`default_nettype none

// look in pins.pcf for all the pin names on the TinyFPGA BX board
module tinyfpga_bx_top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU, // USB pull-up resistor
    output wire PIN_12,
    output wire PIN_13
);
    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    wire clk_20mhz;

    pll_20mhz pll(
        .clock_in(CLK),
        .clock_out(clk_20mhz)
    );


    reg [7:0] duty_reg1 = 0;
    reg [7:0] duty_reg2 = 0;

    ////////
    // generate PWM with given duty cycle
    ////////

    reg [22:0] clk_reg = 0;
    reg clk_bit8_reg = 0;
    wire clk_bit8_stb = clk_reg[8] && !clk_bit8_reg;

    reg clk_bit9_reg = 0;
    wire clk_bit9_stb = clk_reg[9] && !clk_bit9_reg;

    // rate strobes
    wire stb_10mhz = clk_reg[0];
    wire stb_313khz = clk_reg[5];

    // increment the blink_counter every clock
    always @(posedge clk_20mhz) begin
        // clk_reg = !clk_reg;
        clk_reg <= clk_reg + 1;
        clk_bit8_reg <= clk_reg[8];
        clk_bit9_reg <= clk_reg[9];

        if (clk_bit8_stb) begin
            duty_reg1 <= duty_reg1 + 1;
        end
        if (clk_bit9_stb) begin
            duty_reg2 <= duty_reg2 + 1;
        end
    end

    // light up the LED according to the pattern
    assign LED = 1;

    // toggle pin13
    wire saw1 = (clk_reg[7:0] < duty_reg1);
    wire saw2 = (clk_reg[7:0] < duty_reg2);

    assign PIN_13 = clk_reg[22] ? saw1 : saw2;
endmodule

/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        16.000 MHz
 * Requested output frequency:   20.000 MHz
 * Achieved output frequency:    20.000 MHz
 */

 module pll_20mhz(
	input  clock_in,
	output clock_out,
	output locked
);

SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0100111),	// DIVF = 39
		.DIVQ(3'b101),		// DIVQ =  5
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(clock_out)
		);

endmodule