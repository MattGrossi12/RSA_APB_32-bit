`timescale 1ns/1ps

module testbench #(
    parameter ADDR_WIDTH = 12,
              A_WID = ADDR_WIDTH - 1
);

    logic [A_WID:0] paddr_i;
    logic [3:0] oaddr_o;
    logic addr_valid_o;
    integer checks = 0;

    amba_3_apb_adrec #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .A_WID      (A_WID)
    ) dut (
        .paddr_i      (paddr_i),
        .oaddr_o      (oaddr_o),
        .addr_valid_o (addr_valid_o)
    );

    task automatic check_address(
        input logic [A_WID:0] address,
        input logic [3:0] expected_index,
        input logic expected_valid
    );
        paddr_i = address;
        #1;
        checks++;
        if (oaddr_o !== expected_index || addr_valid_o !== expected_valid)
            $fatal(1, "ADREC FAIL: PADDR=0x%h index=%b expected=%b valid=%b expected=%b",
                   address, oaddr_o, expected_index, addr_valid_o, expected_valid);
    endtask

    task automatic sweep_addresses;
        // Include every byte offset, register index and invalid upper address.
        for (int address = 0; address < (1 << (A_WID + 1)); address++)
            check_address((A_WID + 1)'(address), 4'((address / 4) % 16), address < 32);
    endtask

    task automatic check_unknown_bits;
        logic [A_WID:0] address;

        // Unknown byte offsets do not affect selection or validity.
        address = '0;
        address[1:0] = 2'bxz;
        check_address(address, 4'b0000, 1'b1);

        // Unknown index bits propagate without changing a known valid window.
        address = '0;
        address[2] = 1'bx;
        check_address(address, 4'b000x, 1'b1);

        // An unknown bit at the window boundary leaves validity unknown.
        address = '0;
        address[5] = 1'bx;
        check_address(address, 4'bx000, 1'bx);
        address[5] = 1'bz;
        check_address(address, 4'bz000, 1'bx);

        // A known invalid address remains invalid with an unknown index bit.
        address = '0;
        address[5] = 1'b1;
        address[2] = 1'bx;
        check_address(address, 4'b100x, 1'b0);
    endtask

    initial begin
        sweep_addresses();
        check_unknown_bits();
        $display("ADREC PASS: %0d checks, address width=%0d", checks, A_WID + 1);
        $finish;
    end

endmodule: testbench
