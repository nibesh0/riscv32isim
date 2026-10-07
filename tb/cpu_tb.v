`timescale 1ns/1ps
module cpu_tb;
    reg clk = 0, reset = 1;
    wire halted, trapped;
    wire [31:0] pc, debug_x10, exit_code;
    wire [63:0] cycles, instructions;
    reg [1023:0] imem_file, dmem_file, expected_file, dump_file;
    reg [31:0] expected [0:4095];
    integer checks, i, unused, max_cycles, expected_exit, expected_trap;
    integer stack_min, stack_bytes, dump_fd, dump_address, corrupt_address;
    reg [63:0] kernel_start, kernel_cycles;
    reg timing_active, timing_finished;
    cpu dut(.clk(clk), .reset(reset), .halted(halted), .pc_out(pc),
        .cycle_count(cycles), .instruction_count(instructions), .debug_x10(debug_x10),
        .trapped(trapped), .exit_code(exit_code));
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (!reset && !halted) begin
            if (dut.regs.regs[2] >= 32'hc000 && dut.regs.regs[2] < stack_min)
                stack_min = dut.regs.regs[2];
            if (dut.mem_write && dut.alu_result == 32'hfffffff0) begin
                if (dut.rs2_data == 1) begin
                    if (timing_active || timing_finished) $fatal(1, "FAIL duplicate timer start");
                    kernel_start = cycles + 1;
                    timing_active = 1;
                end else if (dut.rs2_data == 2) begin
                    if (!timing_active) $fatal(1, "FAIL timer end without start");
                    kernel_cycles = cycles - kernel_start;
                    timing_active = 0;
                    timing_finished = 1;
                end else $fatal(1, "FAIL invalid timer marker");
            end
        end
    end

    initial begin
        checks = 0; max_cycles = 5000000; expected_exit = 0; expected_trap = 0;
        stack_min = 65536; timing_active = 0; timing_finished = 0;
        kernel_start = 0; kernel_cycles = 0; corrupt_address = -1;
        if (!$value$plusargs("imem=%s", imem_file)) $fatal(1, "FAIL missing +imem");
        unused = $value$plusargs("checks=%d", checks);
        unused = $value$plusargs("max_cycles=%d", max_cycles);
        unused = $value$plusargs("exit=%d", expected_exit);
        unused = $value$plusargs("trap=%d", expected_trap);
        unused = $value$plusargs("corrupt=%d", corrupt_address);
        #1;
        $readmemh(imem_file, dut.imem.mem);
        if ($value$plusargs("dmem=%s", dmem_file)) $readmemh(dmem_file, dut.dmem.mem);
        if (checks > 0) begin
            if (checks > 2048 || !$value$plusargs("expected=%s", expected_file))
                $fatal(1, "FAIL invalid expected image");
            $readmemh(expected_file, expected, 0, checks*2-1);
        end
        #19; reset = 0;
        wait (halted || cycles >= max_cycles);
        @(negedge clk);
        // $display("DEBUG final pc=%08h instruction=%08h exit=%08h trapped=%b cycles=%0d", pc, dut.instruction, exit_code, trapped, cycles);
        // $display("DEBUG signature=%08h %08h %08h %08h", dut.dmem.mem[8192], dut.dmem.mem[8193], dut.dmem.mem[8194], dut.dmem.mem[8195]);
        if (!halted) $fatal(1, "FAIL timeout pc=%h cycles=%0d", pc, cycles);
        if (trapped !== (expected_trap != 0))
            $fatal(1, "FAIL unexpected trap pc=%h instruction=%h cycles=%0d", pc, dut.instruction, cycles);
        if (!expected_trap && exit_code !== expected_exit)
            $fatal(1, "FAIL exit code=%h expected=%h", exit_code, expected_exit);
        if (dut.regs.regs[0] !== 0) $fatal(1, "FAIL x0 changed");
        if (timing_active) $fatal(1, "FAIL missing timer end");
        if (corrupt_address >= 0) dut.dmem.mem[corrupt_address >> 2] = 32'hdeadbeef;
        for (i = 0; i < checks; i = i + 1) begin
            if (expected[i*2][1:0] != 0 || expected[i*2] >= 65536)
                $fatal(1, "FAIL invalid check address");
            if (dut.dmem.mem[expected[i*2] >> 2] !== expected[i*2+1])
                $fatal(1, "FAIL result address=%h got=%h expected=%h",
                    expected[i*2], dut.dmem.mem[expected[i*2] >> 2], expected[i*2+1]);
        end
        if ($value$plusargs("dump=%s", dump_file)) begin
            dump_fd = $fopen(dump_file, "w");
            if (!dump_fd) $fatal(1, "FAIL cannot open dump");
            for (dump_address=0; dump_address<16384; dump_address=dump_address+1)
                $fdisplay(dump_fd, "%08x", dut.dmem.mem[dump_address]);
            $fclose(dump_fd);
        end
        stack_bytes = 65536 - stack_min;
        $display("PASS cycles=%0d instructions=%0d kernel_cycles=%0d stack_bytes=%0d sim_time_ns=%0d checks=%0d trapped=%0d",
                 cycles, instructions, kernel_cycles, stack_bytes, cycles*10, checks, trapped);
        $finish;
    end
endmodule
