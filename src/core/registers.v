module Registers (
    input wire clk,
    input wire regWrite,
    input wire [4:0] readRegister1,
    input wire [4:0] readRegister2,
    input wire [4:0] writeRegister,
    input wire [31:0] writeData,
    output wire [31:0] readData1,
    output wire [31:0] readData2
);

reg [31:0] registers[0:15];

assign readData1  = registers[readRegister1];
assign readData2  = registers[readRegister2];

always @(posedge clk) begin
    if (regWrite == 1'b1) begin
        registers[writeRegister] <= writeData;
    end
    
    registers[0] <= 32'h00000000;
end

`ifdef __ICARUS__
wire [31:0] register1  = registers[1];
wire [31:0] register2  = registers[2];
wire [31:0] register3  = registers[3];
wire [31:0] register4  = registers[4];
wire [31:0] register5  = registers[5];
wire [31:0] register6  = registers[6];
wire [31:0] register7  = registers[7];
wire [31:0] register8  = registers[8];
wire [31:0] register9  = registers[9];
wire [31:0] register10 = registers[10];
wire [31:0] register11 = registers[11];
wire [31:0] register12 = registers[12];
wire [31:0] register13 = registers[13];
wire [31:0] register14 = registers[14];
wire [31:0] register15 = registers[15];

`endif

endmodule
