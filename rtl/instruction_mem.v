module instruction_mem #(
    parameter WORDS = 4096,
    parameter HEX_FILE = ""
) (
    input [31:0] address, output [31:0] instruction
);
    reg [31:0] mem [0:WORDS-1];
    wire [31:0] word_address = address >> 2;
    integer i;
    initial begin
        for (i = 0; i < WORDS; i = i + 1) mem[i] = 32'h00000013;
        if (HEX_FILE != "") $readmemh(HEX_FILE, mem);
    end
    assign instruction = (word_address < WORDS) ? mem[word_address] : 32'h00000013;
endmodule
