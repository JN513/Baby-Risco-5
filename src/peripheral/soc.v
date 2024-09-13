module Baby_Risco_5_SOC #(
    parameter CLOCK_FREQ = 25000000,
    parameter BIT_RATE = 9600,
    parameter BOOT_ADDRESS = 32'h00000000,
    parameter MEMORY_SIZE = 4096,
    parameter MEMORY_FILE = "",
    parameter GPIO_WIDHT = 5,
    parameter UART_BUFFER_SIZE = 8
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output wire tx,
    output wire [7:0] leds,
    inout [GPIO_WIDHT-1:0] gpios
);

wire memory_read, memory_write, slave_read, slave_write,
    slave1_read, slave1_write, slave2_read;
wire [2:0] option;
wire [31:0] address, write_data, read_data, 
    slave_read_data, slave1_read_data;

wire response, memory_response, leds_response;

assign slave_read = (address[31] == 1'b0) ? memory_read : 1'b0;
assign slave_write = (address[31] == 1'b0) ? memory_write : 1'b0;
assign slave1_read = (address[31] == 1'b1) ? memory_read : 1'b0;
assign slave1_write = (address[31] == 1'b1) ? memory_write : 1'b0;

assign read_data = (address[31] == 1'b0) ? slave_read_data : slave1_read_data;
assign response = (address[31] == 1'b0) ? memory_response : leds_response;

Core #(
    .BOOT_ADDRESS(BOOT_ADDRESS)
) Core(
    .clk(clk),
    .reset(reset),
    .option(option),
    .memory_response(response),
    .memory_read(memory_read),
    .memory_write(memory_write),
    .write_data(write_data),
    .read_data(read_data),
    .address(address)
);

Memory #(
    .MEMORY_FILE(MEMORY_FILE),
    .MEMORY_SIZE(MEMORY_SIZE)
) Memory(
    .clk(clk),
    .reset(reset),
    .option(option),
    .memory_read(slave_read),
    .memory_write(slave_write),
    .write_data(write_data),
    .read_data(slave_read_data),
    .address(address),
    .memory_response(memory_response)
);

LEDs Leds(
    .clk(clk),
    .reset(reset),
    .read(slave1_read),
    .write(slave1_write),
    .write_data(write_data),
    .read_data(slave1_read_data),
    .address(address),
    .leds(leds),
    .response(leds_response)
);

endmodule
