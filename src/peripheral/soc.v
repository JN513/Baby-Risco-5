module Baby_Risco_5_SOC #(
    parameter CLOCK_FREQ       = 25000000,
    parameter BIT_RATE         = 9600,
    parameter BOOT_ADDRESS     = 32'h00000000,
    parameter MEMORY_SIZE      = 4096,
    parameter MEMORY_FILE      = "",
    parameter GPIO_WIDHT       = 5,
    parameter UART_BUFFER_SIZE = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output wire tx,
    output wire [7:0] leds,
    inout [GPIO_WIDHT-1:0] gpios
);

wire memory_read, memory_write, mem_rd_en, mem_wr_en,
    led_rd_en, led_wr_en;
wire [3:0] byte_enable;
wire [31:0] mem_addr, mem_data_in, read_data, 
    mem_read_data, led_read_data;

wire ack, mem_ack, led_ack;

assign mem_rd_en = (!mem_addr[31]) ? memory_read  : 1'b0;
assign mem_wr_en = (!mem_addr[31]) ? memory_write : 1'b0;
assign led_rd_en = (mem_addr[31])  ? memory_read  : 1'b0;
assign led_wr_en = (mem_addr[31])  ? memory_write : 1'b0;

assign read_data = (mem_addr[31]) ? led_read_data : mem_read_data;
assign ack       = (mem_addr[31]) ? led_ack : mem_ack;


Core #(
    .BOOT_ADDRESS (BOOT_ADDRESS)
) Core(
    .clk          (clk),
    .rst_n        (rst_n),
    .byte_enable  (byte_enable),
    .ack_i        (response),
    .rd_en_o      (memory_read),
    .wr_en_i      (memory_write),
    .data_o       (mem_data_in),
    .data_i       (read_data),
    .addr_o       (mem_addr)
);

Memory #(
    .MEMORY_FILE (MEMORY_FILE),
    .MEMORY_SIZE (MEMORY_SIZE)
) MemoryUnit (
    .clk         (clk),
    .rd_en_i     (mem_rd_en),
    .wr_en_i     (mem_wr_en),
    .addr_i      (mem_addr),
    .data_i      (mem_data_in),
    .data_o      (mem_read_data),
    .ack_o       (mem_ack)
);

LEDs Leds(
    .clk        (clk),
    .rst_n      (rst_n),
    .read       (led_rd_en),
    .write      (led_wr_en),
    .write_data (mem_data_in),
    .read_data  (led_read_data),
    .address    (mem_addr),
    .leds       (leds),
    .response   (led_ack)
);

endmodule
