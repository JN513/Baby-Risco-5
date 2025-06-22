module Core #(
    parameter BOOT_ADDRESS = 32'h00000000
) (
    // Control signal
    input wire clk,
    input wire halt,
    input wire rst_n,

    // Memory BUS
    input  wire ack_i,
    output wire rd_en_o,
    output wire wr_en_i,
    output wire [3:0]  byte_enable,
    input  wire [31:0] data_i,
    output wire [31:0] addr_o,
    output wire [31:0] data_o
);

reg [31:0] PC, PCOld, RS1, RS2, ALUOutReg, MemoryReg, InstructionReg, alu_input_a, alu_input_b;
wire [31:0] register_input, alu_out, immediate, register_data_1_out, register_data_2_out, PC_Input;

wire pc_load, zero, IRWrite, reg_write, and_zero_out, pc_write_cond, pc_write, is_immediate,
    memory_to_reg, lorD, pc_source;

wire [1:0] aluop, alu_src_a, alu_src_b;
wire [3:0] aluop_out;

assign addr_o         = (lorD)          ? ALUOutReg: PC;
assign PC_Input       = (pc_source)     ? ALUOutReg: alu_out;
assign register_input = (memory_to_reg) ? MemoryReg: ALUOutReg;
assign data_o         = RS2;

and(and_zero_out, zero, pc_write_cond);
or(pc_load, pc_write, and_zero_out);

always @(*) begin
    case (alu_src_a)
        2'b00: alu_input_a   = PC;
        2'b01: alu_input_a   = RS1;
        2'b10: alu_input_a   = PCOld;
        2'b11: alu_input_a   = 32'd0;
        default: alu_input_a = PC;
    endcase

    case (alu_src_b)
        2'b00: alu_input_b   = RS2;
        2'b01: alu_input_b   = 32'd4;
        2'b10: alu_input_b   = immediate;
        default: alu_input_b = RS2;
    endcase

    case (InstructionReg[14:12])
        3'b000: byte_enable  = 4'b0001; // Byte write
        3'b001: byte_enable  = 4'b0011; // Half-word write
        3'b010: byte_enable  = 4'b1111; // Word write
        3'b011: byte_enable  = 4'b1110; // Upper half-word write
        3'b100: byte_enable  = 4'b1100; // Lower half
        default: byte_enable = 4'b1111; // Default to full word write
    endcase
end

Control_Unit Control_Unit(
    .clk                (clk),
    .rst_n              (rst_n),
    .instruction_opcode (InstructionReg[6:0]),
    .pc_write_cond      (pc_write_cond),
    .pc_write           (pc_write),
    .lorD               (lorD),
    .memory_read        (rd_en_o),
    .memory_write       (wr_en_i),
    .memory_to_reg      (memory_to_reg),
    .ir_write           (IRWrite),
    .pc_source          (pc_source),
    .aluop              (aluop),
    .alu_src_b          (alu_src_b),
    .alu_src_a          (alu_src_a),
    .reg_write          (reg_write),
    .is_immediate       (is_immediate),
    .memory_response    (ack_i)
);

Registers RegisterBank(
    .clk        (clk),
    .wr_en_i    (reg_write),
    .RS1_ADDR_i (InstructionReg[19:15]),
    .RS2_ADDR_i (InstructionReg[24:20]),
    .RD_ADDR_i  (InstructionReg[11:7]),
    .data_i     (register_input),
    .RS1_data_o (register_data_1_out),
    .RS2_data_o (register_data_2_out)
);


ALU_Control ALU_Control(
    .is_immediate_i (is_immediate),
    .ALU_CO_i       (aluop),
    .FUNC7_i        (InstructionReg[31:25]),
    .FUNC3_i        (InstructionReg[14:12]),
    .ALU_OP_o       (aluop_out)
);


Alu Alu(
    .ALU_OP_i  (aluop_out),
    .ALU_RS1_i (alu_input_a),
    .ALU_RS2_i (alu_input_b),
    .ALU_RD_o  (alu_out),
    .ALU_ZR_o  (zero)
);

Immediate_Generator Immediate_Generator(
    .instr_i (InstructionReg),
    .imm_o   (immediate)
);


always @(posedge clk ) begin
    if(!rst_n) begin
        PC             <= BOOT_ADDRESS;
        InstructionReg <= 32'h00000000;
    end else begin
        if(pc_load) begin
            PC <= PC_Input;
        end

        if(IRWrite)begin
            InstructionReg <= data_i;
            PCOld          <= PC;
        end
    end

    MemoryReg <= data_i;
    RS1       <= register_data_1_out;
    RS2       <= register_data_2_out;
    ALUOutReg <= alu_out;
end
    

endmodule
