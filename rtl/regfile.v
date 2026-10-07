module regfile (
    input clk, input reset, input reg_write,
    input [4:0] rs1, input [4:0] rs2, input [4:0] rd,
    input [31:0] write_data, output [31:0] read_data1, output [31:0] read_data2
);
    reg [31:0] regs [0:31];
    integer i;
    assign read_data1 = (rs1 == 0) ? 32'd0 : regs[rs1];
    assign read_data2 = (rs2 == 0) ? 32'd0 : regs[rs2];
    always @(posedge clk) begin
        // $display("DEBUG regfile write=%b rd=x%0d data=%08h", reg_write, rd, write_data);
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'd0;
        end else if (reg_write && (rd != 0)) begin
            regs[rd] <= write_data;
        end
        regs[0] <= 32'd0;
    end
endmodule
