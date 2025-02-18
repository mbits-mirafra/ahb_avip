`ifndef AHBMASTER32BITSINGLEWRITESEQUENCEWITHWAITSTATE_INCLUDED_
`define AHBMASTER32BITSINGLEWRITESEQUENCEWITHWAITSTATE_INCLUDED_

class AhbMaster32bitSingleWriteSequenceWithWaitState extends AhbMasterBaseSequence;
  `uvm_object_utils(AhbMaster32bitSingleWriteSequenceWithWaitState)
 
  AhbMasterTransaction req;

  extern function new(string name ="AhbMaster32bitSingleWriteSequenceWithWaitState");
  extern task body();
  
endclass :AhbMaster32bitSingleWriteSequenceWithWaitState
    
 function AhbMaster32bitSingleWriteSequenceWithWaitState::new(string name="AhbMaster32bitSingleWriteSequenceWithWaitState");
  super.new(name);
endfunction : new

task AhbMaster32bitSingleWriteSequenceWithWaitState::body();
  super.body();
  req = AhbMasterTransaction::type_id::create("req");

  start_item(req);
  `uvm_info("AHB", $sformatf("req is of type: %s", req.get_type_name()), UVM_LOW)

  if (!req.randomize() with { 
                              req.hwrite == 1;         // Write operation
                              req.htrans == NONSEQ;     // NONSEQ transaction
                              req.hsize  == WORD;    // 32-bit transfer
                              req.hburst == SINGLE;    // SINGLE transfer
                            }) begin
    `uvm_fatal("AHB", "Randomization failed for 32-bit Write")
  end
  finish_item(req);
endtask: body
`endif
