module Registers (
    input  wire clk,
    input  wire wr_en_i,
    
    input  wire [4:0] RS1_ADDR_i,
    input  wire [4:0] RS2_ADDR_i,
    input  wire [4:0] RD_ADDR_i,

    input  wire [31:0] data_i,
    output wire [31:0] RS1_data_o,
    output wire [31:0] RS2_data_o
);

reg [31:0] registers[0:31];

assign RS1_data_o = registers[RS1_ADDR_i];
assign RS2_data_o = registers[RS2_ADDR_i];


always @(posedge clk ) begin
    if (wr_en_i) begin
        registers[RD_ADDR_i] <= data_i;
    end
    
    registers[0] <= 32'h00000000;
end

endmodule