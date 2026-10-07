`timescale 1ns/1ps
module memory_tb;
    reg clk = 0, mem_read = 0, mem_write = 0; reg [31:0] address = 0, write_data = 0;
    reg [1:0] store_type = 0; reg [2:0] load_type = 5; wire [31:0] read_data;
    data_mem #(.WORDS(16)) dut(.*);
    always #5 clk = ~clk;
    initial begin
        #2; write_data = 32'h80ff1234; address = 4; mem_write = 1; #10; mem_write = 0;
        mem_read = 1; load_type = 5; #1;
        if (read_data !== 32'h80ff1234) begin $display("FAIL word memory"); $finish; end
        load_type = 3; address = 5; #1;
        if (read_data !== 32'h00000012) begin $display("FAIL byte memory %h", read_data); $finish; end
        $display("MEMORY PASS"); $finish;
    end
endmodule
