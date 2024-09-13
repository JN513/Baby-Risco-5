module Core #(
    parameter BOOT_ADDRESS=32'h00000000
) (
    // Control signal
    input wire clk,
    input wire halt,
    input wire reset,

    // Memory BUS
    input wire memory_response,
    output wire memory_read,
    output wire memory_write,
    output wire [2:0] option,
    input  wire [31:0] read_data,
    output wire [31:0] address,
    output wire [31:0] write_data
);

reg [31:0] PC, PCOld, RS1, RS2, ALUOutReg, MemoryReg, InstructionReg, alu_input_a, alu_input_b;
wire [31:0] register_input, alu_out, immediate, register_data_1_out, register_data_2_out, PC_Input;

wire pc_load, zero, IRWrite, reg_write, and_zero_out, pc_write_cond, pc_write, is_immediate,
    memory_to_reg, lorD, pc_source;

wire [1:0] aluop, alu_src_a, alu_src_b;
wire [3:0] aluop_out;

assign address = (lorD == 1'b0) ? PC : ALUOutReg;
assign PC_Input = (pc_source == 1'b0) ? alu_out : ALUOutReg;
assign register_input = (memory_to_reg == 1'b0) ? ALUOutReg : MemoryReg;
assign option = InstructionReg[14:12];
assign write_data = RS2;

and(and_zero_out, zero, pc_write_cond);
or(pc_load, pc_write, and_zero_out);

always @(*) begin
    case (alu_src_a)
        2'b00: alu_input_a <= PC;
        2'b01: alu_input_a <= RS1;
        2'b10: alu_input_a <= PCOld;
        2'b11: alu_input_a <= 32'd4;
        default: alu_input_a <= PC;
    endcase

    case (alu_src_b)
        2'b00: alu_input_b <= RS2;
        2'b01: alu_input_b <= 32'd4;
        2'b10: alu_input_b <= immediate;
        default: alu_input_b <= RS2;
    endcase
end

Control_Unit Control_Unit(
    .clk(clk),
    .reset(reset),
    .instruction_opcode(InstructionReg[6:0]),
    .pc_write_cond(pc_write_cond),
    .pc_write(pc_write),
    .lorD(lorD),
    .memory_read(memory_read),
    .memory_write(memory_write),
    .memory_to_reg(memory_to_reg),
    .ir_write(IRWrite),
    .pc_source(pc_source),
    .aluop(aluop),
    .alu_src_b(alu_src_b),
    .alu_src_a(alu_src_a),
    .reg_write(reg_write),
    .is_immediate(is_immediate),
    .memory_response(memory_response)
);

Registers RegisterBank(
    .clk(clk),
    .regWrite(reg_write),
    .readRegister1(InstructionReg[19:15]),
    .readRegister2(InstructionReg[24:20]),
    .writeRegister(InstructionReg[11:7]),
    .writeData(register_input),
    .readData1(register_data_1_out),
    .readData2(register_data_2_out)
);


ALU_Control ALU_Control(
    .is_immediate(is_immediate),
    .aluop_in(aluop),
    .func7(InstructionReg[31:25]),
    .func3(InstructionReg[14:12]),
    .aluop_out(aluop_out)
);


Alu Alu(
    .operation(aluop_out),
    .ALU_in_X(alu_input_a),
    .ALU_in_Y(alu_input_b),
    .ALU_out_S(alu_out),
    .ZR(zero)
);

Immediate_Generator Immediate_Generator(
    .instruction(InstructionReg),
    .immediate(immediate)
);


always @(posedge clk ) begin
    if(reset == 1'b1) begin
        PC <= BOOT_ADDRESS;
        InstructionReg <= 32'h00000000;
    end else begin
        if(pc_load == 1'b1) begin
            PC <= PC_Input;
            
        end

        if(IRWrite == 1'b1)begin
            InstructionReg <= read_data;
            PCOld <= PC;
        end
    end

    MemoryReg <= read_data;
    RS1 <= register_data_1_out;
    RS2 <= register_data_2_out;
    ALUOutReg <= alu_out;
end
    

endmodule
