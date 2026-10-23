////////////////////////////////////////////////
// Curso de Verificação de Circuitos Digitais
// Outubro 2026
// Description: UVM Testbench
// DUT: RSA_APB
////////////////////////////////////////////////


class vseq extends uvm_sequence;

    `uvm_object_utils(vseq)
    `uvm_declare_p_sequencer(vsequencer)

  	sequencer       	sequencer_h;
  
    env                 env_h;
  

////////////////////////////////////////////////
// Methods
////////////////////////////////////////////////
    // New
  extern function new(string name="vseq");

    // Tasks
    extern task body();
      
    extern task pre_start();

endclass : vseq


////////////////////////////////////////////////
// New
////////////////////////////////////////////////
function vseq::new(string name="vseq");
    super.new(name);
endfunction


////////////////////////////////////////////////
// Body
////////////////////////////////////////////////
task vseq::pre_start();
        
  	$cast(env_h, this.get_sequencer().get_parent());
  
    sequencer_h = p_sequencer.sequencer_h;

endtask


////////////////////////////////////////////////
// Body
////////////////////////////////////////////////
task vseq::body();
        
    sequence_rsa_operation sequence_rsa_operation_h;
  
    sequence_rsa_operation_h = sequence_rsa_operation::type_id::create("sequence_rsa_operation_h");
  
    sequence_rsa_operation_h.start(sequencer_h);

endtask
