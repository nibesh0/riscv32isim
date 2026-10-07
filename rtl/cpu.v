`include "rv32i_defs.vh"
module cpu #(
    parameter IMEM_WORDS = 4096,
    parameter DMEM_WORDS = 16384,
    parameter IMEM_FILE = "",
    parameter DMEM_FILE = ""
) (
    input clk, input reset,
    output reg halted,
    output [31:0] pc_out,
    output reg [63:0] cycle_count,
    output reg [63:0] instruction_count,
    output [31:0] debug_x10,
    output reg trapped,
    output reg [31:0] exit_code
);
    localparam [31:0] DONE_ADDRESS = 32'hffff_fffc;
    reg [31:0] pc;
    wire [31:0] instruction;
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd = instruction[11:7];
    wire [6:0] opcode = instruction[6:0];
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] immediate;
    wire reg_write, mem_read, mem_write, mem_to_reg, alu_src;
    wire branch, jump, jalr, link, halt_instruction, illegal;
    wire [3:0] alu_control;
    wire [2:0] branch_kind, load_type;
    wire [1:0] store_type;
    wire [31:0] alu_a, alu_b, alu_result;
    wire alu_zero;
    wire [31:0] load_data;
    wire branch_taken;
    wire [31:0] pc_plus4 = pc + 32'd4;
    wire [31:0] pc_branch = pc + immediate;
    wire [31:0] pc_jump = jalr ? {alu_result[31:1], 1'b0} : pc_branch;
    wire [31:0] writeback_data = link ? pc_plus4 : (mem_to_reg ? load_data : alu_result);
    wire done_store = mem_write && (alu_result == DONE_ADDRESS);
    wire effective_mem_write = mem_write && !done_store;
    wire [31:0] next_pc = jump ? pc_jump : (branch_taken ? pc_branch : pc_plus4);
    wire misaligned_data = (mem_read &&
        ((load_type == 5 && alu_result[1:0] != 0) ||
         ((load_type == 4 || load_type == 7) && alu_result[0]))) ||
        (mem_write && ((store_type == 0 && alu_result[1:0] != 0) ||
                       (store_type == 2 && alu_result[0])));
    wire mmio = (done_store || (mem_write && alu_result == 32'hfffffff0)) && store_type == 0;
    wire fault = illegal || pc[1:0] != 0 || (pc >> 2) >= IMEM_WORDS ||
        ((jump || branch_taken) && next_pc[1:0] != 0) || misaligned_data ||
        ((mem_read || mem_write) && !mmio && (alu_result >> 2) >= DMEM_WORDS);

    instruction_mem #(.WORDS(IMEM_WORDS), .HEX_FILE(IMEM_FILE)) imem (
        .address(pc), .instruction(instruction)
    );
    regfile regs (
        .clk(clk), .reset(reset), .reg_write(reg_write && !halted && !reset && !fault),
        .rs1(rs1), .rs2(rs2), .rd(rd), .write_data(writeback_data),
        .read_data1(rs1_data), .read_data2(rs2_data)
    );
    imm_gen immediates (.instruction(instruction), .immediate(immediate));
    control decoder (
        .instruction(instruction), .reg_write(reg_write), .mem_read(mem_read),
        .mem_write(mem_write), .mem_to_reg(mem_to_reg), .alu_src(alu_src),
        .branch(branch), .jump(jump), .jalr(jalr), .link(link),
        .halt(halt_instruction), .alu_control(alu_control),
        .branch_kind(branch_kind), .load_type(load_type), .store_type(store_type), .illegal(illegal)
    );

    assign alu_a = (opcode == `OPCODE_LUI) ? 32'd0 :
                   (opcode == `OPCODE_AUIPC) ? pc : rs1_data;
    assign alu_b = alu_src ? immediate : rs2_data;
    alu arithmetic (.a(alu_a), .b(alu_b), .control(alu_control),
                    .result(alu_result), .zero(alu_zero));
    data_mem #(.WORDS(DMEM_WORDS), .HEX_FILE(DMEM_FILE)) dmem (
        .clk(clk), .mem_read(mem_read && !halted), .mem_write(effective_mem_write && !halted && !reset && !fault),
        .address(alu_result), .write_data(rs2_data), .store_type(store_type),
        .load_type(load_type), .read_data(load_data)
    );

    assign branch_taken = branch &&
        ((branch_kind == 3'd1 && alu_zero) ||
         (branch_kind == 3'd2 && !alu_zero) ||
         (branch_kind == 3'd3 && alu_result[0]) ||
         (branch_kind == 3'd4 && !alu_result[0]) ||
         (branch_kind == 3'd5 && alu_result[0]) ||
         (branch_kind == 3'd6 && !alu_result[0]));
    assign pc_out = pc;
    assign debug_x10 = regs.regs[10];

    always @(posedge clk) begin
        // $display("DEBUG pc=%08h instruction=%08h alu=%08h rs1=%08h rs2=%08h", pc, instruction, alu_result, rs1_data, rs2_data);
        // $display("DEBUG controls rw=%b mr=%b mw=%b branch=%b jump=%b trap=%b halt=%b", reg_write, mem_read, mem_write, branch, jump, fault, halt_instruction);
        if (reset) begin
            pc <= 32'd0;
            halted <= 1'b0;
            trapped <= 1'b0;
            exit_code <= 32'd0;
            cycle_count <= 64'd0;
            instruction_count <= 64'd0;
        end else if (!halted) begin
            pc <= next_pc;
            cycle_count <= cycle_count + 64'd1;
            if (!fault) instruction_count <= instruction_count + 64'd1;
            if (fault) begin
                halted <= 1'b1;
                trapped <= 1'b1;
            end else if (halt_instruction || done_store) begin
                halted <= 1'b1;
                exit_code <= done_store ? rs2_data : debug_x10;
            end
        end
    end
endmodule
