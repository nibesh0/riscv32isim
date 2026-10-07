module data_mem #(
    parameter WORDS = 16384,
    parameter HEX_FILE = ""
) (
    input clk, input mem_read, input mem_write,
    input [31:0] address, input [31:0] write_data,
    input [1:0] store_type, input [2:0] load_type,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:WORDS-1];
    wire [31:0] word_address = address >> 2;
    integer i;
    initial begin
        for (i = 0; i < WORDS; i = i + 1) mem[i] = 32'd0;
        if (HEX_FILE != "") $readmemh(HEX_FILE, mem);
    end

    always @* begin
        read_data = 32'd0;
        if (mem_read && (word_address < WORDS)) begin
            case (load_type)
                3'd3: begin
                    case (address[1:0])
                        2'd0: read_data = {{24{mem[word_address][7]}}, mem[word_address][7:0]};
                        2'd1: read_data = {{24{mem[word_address][15]}}, mem[word_address][15:8]};
                        2'd2: read_data = {{24{mem[word_address][23]}}, mem[word_address][23:16]};
                        default: read_data = {{24{mem[word_address][31]}}, mem[word_address][31:24]};
                    endcase
                end
                3'd4: read_data = address[1] ? {{16{mem[word_address][31]}}, mem[word_address][31:16]} :
                                                {{16{mem[word_address][15]}}, mem[word_address][15:0]};
                3'd5: read_data = mem[word_address];
                3'd6: begin
                    case (address[1:0])
                        2'd0: read_data = {24'd0, mem[word_address][7:0]};
                        2'd1: read_data = {24'd0, mem[word_address][15:8]};
                        2'd2: read_data = {24'd0, mem[word_address][23:16]};
                        default: read_data = {24'd0, mem[word_address][31:24]};
                    endcase
                end
                3'd7: read_data = address[1] ? {16'd0, mem[word_address][31:16]} :
                                                {16'd0, mem[word_address][15:0]};
                default: read_data = mem[word_address];
            endcase
        end
    end

    always @(posedge clk) begin
        // $display("DEBUG memory write=%b address=%08h data=%08h type=%0d", mem_write, address, write_data, store_type);
        if (mem_write && (word_address < WORDS)) begin
            case (store_type)
                2'd1: begin
                    case (address[1:0])
                        2'd0: mem[word_address][7:0] <= write_data[7:0];
                        2'd1: mem[word_address][15:8] <= write_data[7:0];
                        2'd2: mem[word_address][23:16] <= write_data[7:0];
                        default: mem[word_address][31:24] <= write_data[7:0];
                    endcase
                end
                2'd2: begin
                    if (address[1]) mem[word_address][31:16] <= write_data[15:0];
                    else mem[word_address][15:0] <= write_data[15:0];
                end
                default: mem[word_address] <= write_data;
            endcase
        end
    end
endmodule
