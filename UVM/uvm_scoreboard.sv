////////////////////////////////////////////////
// Curso de Verificação de Circuitos Digitais
// Outubro 2026
// Description: UVM Testbench
// DUT: RSA_APB
////////////////////////////////////////////////


class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)

////////////////////////////////////////////////
// Analysis Export
////////////////////////////////////////////////
    `uvm_analysis_imp_decl(_apb_rsa)
    uvm_analysis_imp_apb_rsa #(seq_item, scoreboard) analysis_export_apb_rsa_aep;

    //protected uvm_tlm_analysis_fifo #(seq_item) apb_rsa_fifo;

////////////////////////////////////////////////
// Methods
////////////////////////////////////////////////
    // New
    extern function new(string name, uvm_component parent);

    // Phases
    extern function void build_phase(uvm_phase phase);
    extern function void write_apb_rsa(seq_item t);


endclass : scoreboard


////////////////////////////////////////////////
// New
////////////////////////////////////////////////
function scoreboard::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

////////////////////////////////////////////////
// Build phase
////////////////////////////////////////////////
function void scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    analysis_export_apb_rsa_aep = new("analysis_export_apb_rsa_aep", this);
    
    //apb_rsa_fifo = new("apb_rsa_fifo", this);
    
endfunction : build_phase



////////////////////////////////////////////////
// Write function
////////////////////////////////////////////////
function void scoreboard::write_apb_rsa(seq_item t);
    
   t.print();

endfunction