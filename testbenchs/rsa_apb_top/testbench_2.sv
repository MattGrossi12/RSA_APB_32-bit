////////////////////////////////////////////////
// Curso de Verificação de Circuitos Digitais
// Outubro 2026
// Description: Verification environment using direct testcases
// DUT: RSA_APB
////////////////////////////////////////////////

`timescale 1ns/1ps

module testbench;

////////////////////////////////////////////////
// Internal Signals and Parameter
////////////////////////////////////////////////
    localparam integer DATA_WIDTH = 32;
    localparam integer ADDR_WIDTH = 12;
    localparam integer CLOCK_PERIOD_NS = 10;

    // Address Mapping (Datasheet 5)
    localparam logic [ADDR_WIDTH-1:0] CTRL_ADDR   = 12'h000;
    localparam logic [ADDR_WIDTH-1:0] STATUS_ADDR = 12'h004;
    localparam logic [ADDR_WIDTH-1:0] IER_ADDR    = 12'h008;
    localparam logic [ADDR_WIDTH-1:0] MSG_ADDR    = 12'h00C;
    localparam logic [ADDR_WIDTH-1:0] EXP_ADDR    = 12'h010;
    localparam logic [ADDR_WIDTH-1:0] MOD_ADDR    = 12'h014;
    localparam logic [ADDR_WIDTH-1:0] RESULT_ADDR = 12'h018;
    localparam logic [ADDR_WIDTH-1:0] ID_ADDR     = 12'h01C;

    task div; $display("+-----------------------------------------------+"); endtask

    // Signals
    logic pclk;
    logic presetn;
    logic psel; 
    logic penable; 
    logic pwrite;
    logic [ADDR_WIDTH-1:0] paddr;
    logic [DATA_WIDTH-1:0] pwdata;
    logic [DATA_WIDTH-1:0] prdata;
    logic  pready;
    logic  pslverr; 
    logic  irq;

    // Results analyzer signals
    logic [ADDR_WIDTH-1:0] expected_result;
    logic [ADDR_WIDTH-1:0] read_data;
    logic                  error;

////////////////////////////////////////////////
// DUT instantiation
////////////////////////////////////////////////
    amba_3_apb_rsa_apb_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        // rsa_core_ctrl waits for LOAD to fall between MSG, EXP and MOD.
        .LOAD_GAP   (1)
    ) dut (
        .pclk_i     (pclk),
        .presetn_i  (presetn),
        .psel_i     (psel),
        .penable_i  (penable),
        .pwrite_i   (pwrite),
        .paddr_i    (paddr),
        .pwdata_i   (pwdata),
        .prdata_o   (prdata),
        .pready_o   (pready),
        .pslverr_o  (pslverr),
        .irq_o      (irq)
    );

////////////////////////////////////////////////
// Stimuli Generation
////////////////////////////////////////////////
// Clock generation
always begin
    #(CLOCK_PERIOD_NS / 2) pclk = ~pclk;
end

// APB Write trasaction (Datasheet 7.1)
task apb_write(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] write_data
    );
    begin
        @(posedge pclk);
        psel      = 1'b1;
        penable   = 1'b0;
        pwrite    = 1'b1;
        paddr     = address;
        pwdata    = write_data;

        @(posedge pclk);
        penable   = 1'b1;

        @(posedge pclk);
        psel      = 1'b0;
        penable   = 1'b0;
    end
 endtask

// APB READ trasaction (Datasheet 7.2)
task apb_read(
        input  logic [ADDR_WIDTH-1:0] address,
        output logic [DATA_WIDTH-1:0] read_data
    );
    begin
        @(posedge pclk);
        psel      = 1'b1;
        penable   = 1'b0;
        pwrite    = 1'b0;
        paddr     = address;

        @(posedge pclk);
        penable   = 1'b1;

        @(posedge pclk);
        psel      = 1'b0;
        penable   = 1'b0;

        read_data = prdata;
    end
 endtask

////////////////////////////////////////////////
// Results analysis
////////////////////////////////////////////////
// Golden model
task update_expected_result(
        input  logic [DATA_WIDTH-1:0] msg,
        input  logic [DATA_WIDTH-1:0] exp,
        input  logic [DATA_WIDTH-1:0] mod,
        output logic [DATA_WIDTH-1:0] expected_result
    );
    begin
        expected_result = (msg ** exp) % mod;
    end
 endtask

// Compare
task compare_results(
        input  logic [DATA_WIDTH-1:0] dut_result,
        input  logic [DATA_WIDTH-1:0] expected_result,
        output logic error
    );
    begin
        // Assert error
        if (dut_result !== expected_result) begin
            error++;
            $display("Received data: %h  Expected: %h", dut_result, expected_result);
        end
    end
 endtask

////////////////////////////////////////////////
// Tests Description
////////////////////////////////////////////////
// test_rsa_operation
task test_rsa_operation;
    begin
        //  1) Iniciar o DUT com PRESETn = 0
        presetn = 1'b0;

        // 2) Aguardar 10 ciclos de clock e colocar PRESETn = 1 na borda de descida do clock
        repeat(10) @(posedge pclk);
        presetn = 1'b1;

        // 3) Carregar operandos:
        // 3.1) Escrever em 0x0C o valor <dado1>
        apb_write(MSG_ADDR, 'h0000_0004);
        
        // 3.2) Escrever em 0x10 o valor <dado2>
        apb_write(EXP_ADDR, 'h0000_0002);

        //3.3) Escrever em 0x14 o valor <dado3>
        apb_write(MOD_ADDR, 'h0000_0001);

        // 4) Diparar o start da operação
        // 4.1) Escrever em 0x00 o valor 0x01
        apb_write(CTRL_ADDR, 'h0000_0001);

        // Update reference model
        update_expected_result('h0000_0004, 'h0000_0002, 'h0000_0001, expected_result);

        //5) Pooling no status register
        read_data = 'h0;
        while (read_data !== 'h2) begin
            apb_read(STATUS_ADDR, read_data);
        end

        // 6) Ler o resultado
        // 6.1) Ler do endereço 0x18
        apb_read(RESULT_ADDR, read_data);

        // Compare result
        compare_results(read_data, expected_result);

    end
 endtask

////////////////////////////////////////////////
// Test Execution
////////////////////////////////////////////////
initial begin
    // signal initialization
    pclk        = 1'b0;
    presetn     = 1'b0;
    psel        = 1'b0;
    penable     = 1'b0; 
    pwrite      = 1'b0;
    error       = 1'b0;
    
    // Run test
//`ifdef TEST
//    if (`TEST == rsa_operation)
//        test_rsa_operation;
//`else    
    test_rsa_operation();
//`end

    // Finaliza teste
    div();
    $display("Test   Result");
    div();
    if (error) begin
        $display("FAIL!!");
    end 
    else begin
        $display("PASS!!");
    end
    div();

    $finish;

end
endmodule