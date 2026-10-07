`include "rv32i_defs.vh"
module imm_gen (input [31:0] instruction, output reg [31:0] immediate);
    wire [6:0] opcode = instruction[6:0];
    always @* begin
        case (opcode)
            `OPCODE_OPIMM, `OPCODE_LOAD, `OPCODE_JALR, `OPCODE_SYSTEM:
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            `OPCODE_STORE:
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            `OPCODE_BRANCH:
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            `OPCODE_LUI, `OPCODE_AUIPC:
                immediate = {instruction[31:12], 12'b0};
            `OPCODE_JAL:
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default: immediate = 32'd0;
        endcase
    end
endmodule
