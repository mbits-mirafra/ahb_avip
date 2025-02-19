`ifndef AHBSLAVE16BITSINGLEWRITESEQUENCE_INCLUDED_
`define AHBSLAVE16BITSINGLEWRITESEQUENCE_INCLUDED_  

class AhbSlave16bitSingleWriteSequence extends AhbSlaveBaseSequence;
  `uvm_object_utils(AhbSlave16bitSingleWriteSequence)
  extern function new(string name="AhbSlave16bitSingleWriteSequence");
  extern task body();
endclass : AhbSlave16bitSingleWriteSequence
 
function AhbSlave16bitSingleWriteSequence::new(string name="AhbSlave16bitSingleWriteSequence");
  super.new(name);
endfunction : new
 
task AhbSlave16bitSingleWriteSequence::body();
  req = AhbSlaveTransaction::type_id::create("req");
  start_item(req);
  if(!req.randomize() with {
			    req.noOfWaitStates == 32'h0000;
			    }) begin
    `uvm_fatal("APB","Rand failed");
  end
  req.print();
  finish_item(req);
endtask : body
`endif
