module Memory #(
    parameter MEMORY_FILE = "",
    parameter MEMORY_SIZE = 4096
)(
    input  wire        clk,

    input  wire        rd_en_i,    // Indica uma solicitação de leitura
    input  wire        wr_en_i,    // Indica uma solicitação de escrita

    input  wire [31:0] addr_i,     // Endereço
    input  wire [31:0] data_i,     // Dados de entrada (para escrita)
    output wire [31:0] data_o,     // Dados de saída (para leitura)

    output wire        ack_o       // Confirmação da transação
);

    localparam BIT_INDEX = $clog2(MEMORY_SIZE) - 1'b1;
    reg [31:0] memory [(MEMORY_SIZE/4)-1:0];

    // Inicialização da memória com arquivo, se fornecido
    initial begin
        if (MEMORY_FILE != "") begin
            $readmemh(MEMORY_FILE, memory);
        end
    end

    // Leitura assíncrona
    assign data_o = (rd_en_i) ? memory[addr_i[BIT_INDEX:2]] : 32'd0;

    // Resposta assíncrona de ACK
    assign ack_o = rd_en_i || wr_en_i;  

    // Escrita síncrona
    always @(posedge clk) begin
        if (wr_en_i) begin
            memory[addr_i[BIT_INDEX:2]] <= data_i;
        end
    end

endmodule