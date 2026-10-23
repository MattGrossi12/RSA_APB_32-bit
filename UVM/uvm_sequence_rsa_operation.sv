////////////////////////////////////////////////
// Curso de Verificação de Circuitos Digitais
// Outubro 2026
// Description: UVM Testbench
// DUT: RSA_APB
////////////////////////////////////////////////


class sequence_rsa_operation extends uvm_sequence #(seq_item);

    `uvm_object_param_utils(sequence_rsa_operation)

    seq_item item;

////////////////////////////////////////////////
// Methods
////////////////////////////////////////////////
    // New
    extern function new(string name="sequence_rsa_operation");

    // Tasks
    extern task body();

endclass : sequence_rsa_operation


////////////////////////////////////////////////
// New
////////////////////////////////////////////////
function sequence_rsa_operation::new(string name="sequence_rsa_operation");
    super.new(name);
endfunction


////////////////////////////////////////////////
// Body
////////////////////////////////////////////////
task sequence_rsa_operation::body();
        
        item = seq_item::type_id::create("item");

        // 3) Carregar operandos:
        // 3.1) Escrever em 0x0C o valor <dado1>
        start_item(item);
        void'(item.randomize() with {
            transaction_type == WRITE;
            address          == 'h0C;
        });
        finish_item(item);

        // 3.2) Escrever em 0x10 o valor <dado2>
        start_item(item);
        void'(item.randomize() with {
            transaction_type == WRITE;
            address          == 'h10;
        });
        finish_item(item);

        //3.3) Escrever em 0x14 o valor <dado3>
        start_item(item);
        void'(item.randomize() with {
            transaction_type == WRITE;
            address == 'h14;
        });
        finish_item(item);
        
        // 4) Diparar o start da operação
        // 4.1) Escrever em 0x00 o valor 0x01
        start_item(item);
        void'(item.randomize() with {
            transaction_type == WRITE;
            address          == 'h00;
            data             == 'h01;
        });
        finish_item(item);

        //5) Pooling no status register
        start_item(item);
        void'(item.randomize() with {
            transaction_type == READ;
            address          == 'h04;
        });
        finish_item(item);
  

        // 6) Ler o resultado
        // 6.1) Ler do endereço 0x18
        start_item(item);
        void'(item.randomize() with {
            transaction_type == READ;
            address          == 'h18;
        });
        finish_item(item);

endtask



