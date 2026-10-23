////////////////////////////////////////////////
// Curso de Verificação de Circuitos Digitais
// Outubro 2026
// Description: UVM Testbench
// DUT: RSA_APB
////////////////////////////////////////////////


class monitor  extends uvm_monitor;

  `uvm_component_param_utils(monitor)

////////////////////////////////////////////////
// Attributes
////////////////////////////////////////////////
    virtual interface apb_rsa_if vif;

////////////////////////////////////////////////
// Object instantiation
////////////////////////////////////////////////
    // Analysis Port
    uvm_analysis_port #(seq_item) monitor_ap;

    seq_item item;

////////////////////////////////////////////////
// Methods
////////////////////////////////////////////////
    // New
    extern function new(string name, uvm_component parent);

    // Phases
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass : monitor


////////////////////////////////////////////////
// New
////////////////////////////////////////////////
function monitor::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

////////////////////////////////////////////////
// Build phase
////////////////////////////////////////////////
function void monitor::build_phase(uvm_phase phase);
    
    super.build_phase(phase);

    this.monitor_ap = new(.name("monitor_ap"),.parent(this));

endfunction


////////////////////////////////////////////////
// Build phase
////////////////////////////////////////////////
task monitor::run_phase(uvm_phase phase);
   
   item = seq_item::type_id::create("item");

   repeat(2) @(posedge vif.pclk);
  
   forever begin
     
    // Monitoramos o barramento
    // Encapsulamos em itens de transação
    @(posedge vif.psel);

    if (vif.pwrite) begin
        item.transaction_type = WRITE;
        item.data    = vif.pwdata;
        item.address = vif.paddr;
    end
    else begin
        item.transaction_type = READ;
        @(posedge vif.penable);
        item.data    = vif.prdata;
        item.address = vif.paddr;
    end

    // Envia para analysis port
    monitor_ap.write(item);

   end
  
    phase.drop_objection(this);

endtask
