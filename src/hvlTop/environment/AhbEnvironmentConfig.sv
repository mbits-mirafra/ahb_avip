`ifndef AHBENVIRONMENTCONFIG_INCLUDED_
`define AHBENVIRONMENTCONFIG_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: AhbEnvironmentConfig
// This class is used as configuration class for AhbEnvironment and its components
//--------------------------------------------------------------------------------------------
class AhbEnvironmentConfig extends uvm_object;
  `uvm_object_utils(AhbEnvironmentConfig)
  
  //Variable: hasScoreboard
  //Enables the scoreboard. Default value is 1
  bit hasScoreboard = 1;

  //Variable: hasVirtualSequencer
  //Enables the virtual sequencer. Default value is 1
  bit hasVirtualSequencer = 1;

//Variable: noOfMasters
  //Number of Masters connected to the SPI interface
  int noOfMasters=1;

  //Variable: noOfSlaves
  //Number of slaves connected to the SPI interface
  int noOfSlaves=1;

  //Operation mode
  ahbOperationEnum operationMode;

  //Variable: ahbMasterAgentConfig
  //Handle for master agent configuration
  AhbMasterAgentConfig ahbMasterAgentConfig[];

  //Variable: ahbSlaveAgentConfig
  //Dynamic array of slave agnet configuration handles
  AhbSlaveAgentConfig ahbSlaveAgentConfig[];

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "AhbEnvironmentConfig");
  extern function void do_print(uvm_printer printer);

endclass : AhbEnvironmentConfig

//--------------------------------------------------------------------------------------------
// Construct: new
//  Initialization of new memory
//
// Parameters:
//  name - AhbEnvironmentConfig
//--------------------------------------------------------------------------------------------
function  AhbEnvironmentConfig::new(string name = "AhbEnvironmentConfig");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: do_print method
//  Print method can be added to display the data members values
//
// Parameters :
//  printer - uvm_printer
//--------------------------------------------------------------------------------------------
function void AhbEnvironmentConfig::do_print(uvm_printer printer);
  super.do_print(printer);

  printer.print_field ("hasScoreboard", hasScoreboard, $bits(hasScoreboard), UVM_DEC);
  printer.print_field ("hasVirtualSequencer", hasVirtualSequencer, $bits(hasVirtualSequencer), UVM_DEC);
  printer.print_field ("noOfMasters",  noOfMasters,  $bits(noOfMasters), UVM_DEC);
  printer.print_field ("noOfSlaves",  noOfSlaves,  $bits(noOfSlaves), UVM_DEC);
  printer.print_field ("operationMode",  operationMode,  $bits(operationMode), UVM_DEC);
  printer.print_string ("operationMode",  operationMode.name());

endfunction : do_print

`endif
