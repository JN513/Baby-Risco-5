module LEDs (
    input  wire clk,
    input  wire rst_n,
    input  wire read,
    input  wire write,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output wire [31:0] read_data,
    output wire response,
    output wire [7:0] leds
);

assign response = read | write;

reg [31:0] data;

assign read_data = (read) ? data : 32'h0;

always @( posedge clk ) begin
    if(!rst_n) begin
        data <= 1'b0;
    end else if(write) begin
        data <= write_data;
    end
end

assign leds = ~data[7:0];
    
endmodule