`timescale 1ns/1ps
`include "rv32i_defs.vh"
module alu_tb;
    reg [31:0] a, b; reg [3:0] control; wire [31:0] result; wire zero;
    alu dut(.a(a), .b(b), .control(control), .result(result), .zero(zero));
    task check;
        input [31:0] av, bv, expected; input [3:0] op;
        begin
            a = av; b = bv; control = op; #1;
            if (result !== expected) begin
                $display("FAIL ALU op=%0d a=%h b=%h got=%h expected=%h", op, av, bv, result, expected);
                $finish;
            end
        end
    endtask
    initial begin
        check(32'd7, 32'd5, 32'd12, `ALU_ADD);
        check(32'd7, 32'd5, 32'd2, `ALU_SUB);
        check(32'hf0f0, 32'h0ff0, 32'h00f0, `ALU_AND);
        check(32'hf000, 32'h0ff0, 32'hfff0, `ALU_OR);
        check(32'hff00, 32'h0ff0, 32'hf0f0, `ALU_XOR);
        check(-32'sd2, 32'd1, 32'd1, `ALU_SLT);
        check(32'hffff_fffe, 32'd1, 32'd0, `ALU_SLTU);
        check(32'd3, 32'd4, 32'd48, `ALU_SLL);
        check(32'h8000_0000, 32'd4, 32'h0800_0000, `ALU_SRL);
        check(32'h8000_0000, 32'd4, 32'hf800_0000, `ALU_SRA);
        $display("ALU PASS");
        $finish;
    end
endmodule
