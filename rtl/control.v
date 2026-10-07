`include "rv32i_defs.vh"
module control (
    input [31:0] instruction,
    output reg reg_write, output reg mem_read, output reg mem_write,
    output reg mem_to_reg, output reg alu_src, output reg branch,
    output reg jump, output reg jalr, output reg link, output reg halt,
    output reg [3:0] alu_control, output reg [2:0] branch_kind,
    output reg [2:0] load_type, output reg [1:0] store_type,
    output reg illegal
);
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    always @* begin
        reg_write = 0; mem_read = 0; mem_write = 0; mem_to_reg = 0;
        alu_src = 0; branch = 0; jump = 0; jalr = 0; link = 0; halt = 0;
        alu_control = `ALU_ADD; branch_kind = 0; load_type = 3'd5; store_type = 0;
        illegal = 0;
        case (opcode)
            `OPCODE_OP: begin
                reg_write = 1;
                case (funct3)
                    3'b000: alu_control = (funct7 == 7'b0100000) ? `ALU_SUB : `ALU_ADD;
                    3'b001: alu_control = `ALU_SLL;
                    3'b010: alu_control = `ALU_SLT;
                    3'b011: alu_control = `ALU_SLTU;
                    3'b100: alu_control = `ALU_XOR;
                    3'b101: alu_control = (funct7 == 7'b0100000) ? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_control = `ALU_OR;
                    3'b111: alu_control = `ALU_AND;
                    default: reg_write = 0;
                endcase
                if (funct7 != 0 && !(funct7 == 7'h20 && (funct3 == 0 || funct3 == 5))) illegal = 1;
            end
            `OPCODE_OPIMM: begin
                reg_write = 1; alu_src = 1;
                case (funct3)
                    3'b000: alu_control = `ALU_ADD;
                    3'b010: alu_control = `ALU_SLT;
                    3'b011: alu_control = `ALU_SLTU;
                    3'b100: alu_control = `ALU_XOR;
                    3'b110: alu_control = `ALU_OR;
                    3'b111: alu_control = `ALU_AND;
                    3'b001: alu_control = `ALU_SLL;
                    3'b101: alu_control = (funct7 == 7'b0100000) ? `ALU_SRA : `ALU_SRL;
                    default: reg_write = 0;
                endcase
                if ((funct3 == 1 && funct7 != 0) ||
                    (funct3 == 5 && funct7 != 0 && funct7 != 7'h20)) illegal = 1;
            end
            `OPCODE_LOAD: begin
                reg_write = 1; mem_read = 1; mem_to_reg = 1; alu_src = 1;
                case (funct3)
                    3'b000: load_type = 3'd3;
                    3'b001: load_type = 3'd4;
                    3'b010: load_type = 3'd5;
                    3'b100: load_type = 3'd6;
                    3'b101: load_type = 3'd7;
                    default: illegal = 1;
                endcase
            end
            `OPCODE_STORE: begin
                mem_write = 1; alu_src = 1;
                case (funct3)
                    3'b000: store_type = 2'd1;
                    3'b001: store_type = 2'd2;
                    3'b010: store_type = 2'd0;
                    default: illegal = 1;
                endcase
            end
            `OPCODE_BRANCH: begin
                branch = 1;
                case (funct3)
                    3'b000: begin branch_kind = 1; alu_control = `ALU_SUB; end
                    3'b001: begin branch_kind = 2; alu_control = `ALU_SUB; end
                    3'b100: begin branch_kind = 3; alu_control = `ALU_SLT; end
                    3'b101: begin branch_kind = 4; alu_control = `ALU_SLT; end
                    3'b110: begin branch_kind = 5; alu_control = `ALU_SLTU; end
                    3'b111: begin branch_kind = 6; alu_control = `ALU_SLTU; end
                    default: illegal = 1;
                endcase
            end
            `OPCODE_JAL: begin reg_write = 1; jump = 1; link = 1; end
            `OPCODE_JALR: begin
                reg_write = 1; jump = 1; jalr = 1; link = 1; alu_src = 1;
                if (funct3 != 0) illegal = 1;
            end
            `OPCODE_LUI: begin reg_write = 1; alu_src = 1; end
            `OPCODE_AUIPC: begin reg_write = 1; alu_src = 1; end
            7'b0001111: begin
                if (funct3 != 0) illegal = 1;
            end
            `OPCODE_SYSTEM: begin
                if (instruction == 32'h00100073) halt = 1;
                else illegal = 1;
            end
            default: illegal = 1;
        endcase
        if (illegal) begin
            reg_write = 0; mem_read = 0; mem_write = 0; branch = 0; jump = 0; halt = 0;
        end
    end
endmodule
