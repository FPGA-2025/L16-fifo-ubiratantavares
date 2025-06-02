module fifo(
    input clk,
    input rstn,
    input wr_en,
    input rd_en,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output reg full,
    output reg empty
);

    reg [7:0] buffer [0:3];
    reg [1:0] w_ptr;
    reg [1:0] r_ptr;

    // Lógica para os ponteiros e o buffer
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin // Reset assíncrono (ativo em nível baixo)
            w_ptr <= 2'b00;
            r_ptr <= 2'b00;
            // data_out não é definido aqui para que seja 'x' até a primeira leitura
            // ou pode ser 0 se a especificação pedir
        end else begin
            if (wr_en && !full) begin
                buffer[w_ptr] <= data_in;
                w_ptr <= w_ptr + 1;
            end

            // O data_out deve ser atualizado no próximo ciclo DEPOIS que o rd_en é ativo,
            // refletindo o dado do buffer[r_ptr] ANTES do incremento do r_ptr.
            // Se rd_en é ativo e a FIFO não está vazia, o dado é lido.
            if (rd_en && !empty) begin
                data_out <= buffer[r_ptr]; // Lê o dado da posição atual
                r_ptr <= r_ptr + 1;        // Incrementa o ponteiro de leitura
            end
            // Se rd_en não estiver ativo, data_out mantém o valor anterior,
            // a menos que haja um reset.
        end
    end

    // Lógica para full e empty (combinacional)
    always @(*) begin
        if (w_ptr == r_ptr) begin
            empty = 1'b1;
        end else begin
            empty = 1'b0;
        end

        // A FIFO está cheia se o ponteiro de escrita estiver uma posição "atrás" do ponteiro de leitura,
        // considerando o wrap-around. Ex: w_ptr=3, r_ptr=0 (para 4 posições).
        // (w_ptr + 1) == r_ptr
        if ((w_ptr + 2'b01) == r_ptr) begin // (w_ptr + 1) module 4
            full = 1'b1;
        end else begin
            full = 1'b0;
        end
    end

endmodule
