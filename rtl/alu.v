`include "rv32i_defs.vh"
module alu (
    input [31:0] a, input [31:0] b, input [3:0] control,
    output reg [31:0] result, output zero
);
    always @* begin
        case (control)
            `ALU_ADD: result = a + b;
            `ALU_SUB: result = a - b;
            `ALU_AND: result = a & b;
            `ALU_OR: result = a | b;
            `ALU_XOR: result = a ^ b;
            `ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
            `ALU_SLL: result = a << b[4:0];
            `ALU_SRL: result = a >> b[4:0];
            `ALU_SRA: result = $signed(a) >>> b[4:0];
            default: result = 32'd0;
        endcase
    end
    assign zero = (result == 32'd0);
endmodule
