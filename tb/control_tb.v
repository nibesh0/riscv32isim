`timescale 1ns/1ps
`include "rv32i_defs.vh"
module control_tb;
    reg [31:0] instruction;
    wire reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch, jump, jalr, link, halt;
    wire [3:0] alu_control; wire [2:0] branch_kind, load_type; wire [1:0] store_type; wire illegal;
    control dut(.*);
    function [31:0] rtype;
        input [6:0] f7; input [4:0] rs2, rs1, rd; input [2:0] f3;
        rtype = {f7, rs2, rs1, f3, rd, `OPCODE_OP};
    endfunction
    initial begin
        instruction = rtype(0, 2, 1, 3, 0); #1;
        if (!reg_write || alu_control != `ALU_ADD) begin $display("FAIL R control"); $finish; end
        instruction = 32'h0000a203; #1;
        if (!reg_write || !mem_read || !mem_to_reg || !alu_src) begin $display("FAIL load control"); $finish; end
        instruction = 32'h00208863; #1;
        if (!branch || branch_kind != 1) begin $display("FAIL branch control"); $finish; end
        instruction = 32'h0000006f; #1;
        if (!jump || !link) begin $display("FAIL jump control"); $finish; end
        $display("CONTROL PASS"); $finish;
    end
endmodule
