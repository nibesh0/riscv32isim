`timescale 1ns/1ps
module regfile_tb;
    reg clk = 0, reset = 1, reg_write = 0; reg [4:0] rs1 = 0, rs2 = 0, rd = 0;
    reg [31:0] write_data = 0; wire [31:0] read_data1, read_data2;
    regfile dut(.*);
    always #5 clk = ~clk;
    initial begin
        #12; reset = 0; reg_write = 1; rd = 5; write_data = 32'h12345678; #10;
        reg_write = 0; rs1 = 5; #1;
        if (read_data1 !== 32'h12345678) begin $display("FAIL register write/read"); $finish; end
        rs1 = 0; #1;
        if (read_data1 !== 0) begin $display("FAIL x0"); $finish; end
        $display("REGFILE PASS"); $finish;
    end
endmodule
