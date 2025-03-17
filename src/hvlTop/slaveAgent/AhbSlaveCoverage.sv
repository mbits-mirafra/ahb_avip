`ifndef AHBSLAVECOVERAGE_INCLUDED_
`define AHBSLAVECOVERAGE_INCLUDED_

class AhbSlaveCoverage extends uvm_subscriber #(AhbSlaveTransaction);
  `uvm_component_utils(AhbSlaveCoverage)
 
  AhbSlaveAgentConfig ahbSlaveAgentConfig;
  
    covergroup ahbSlaveCovergroup with function sample (AhbSlaveAgentConfig AhbSlaveAgentConfig , AhbSlaveTransaction ahbSlaveTransaction);
    option.per_instance=1;
    
    HREADY_CP:coverpoint ahbSlaveTransaction.hreadyout{
      option.comment="ahb ready";
      bins ahbReady0={0};
      bins ahbReady1={1};
    }

    HRESP_CP:coverpoint ahbSlaveTransaction.hresp{
      option.comment="ahb response";
      bins ahbResp0={0};
      bins ahbResp1={1};
    }

/*     HRDATA_CP:coverpoint ahbSlaveTransaction.hrdata{
      option.comment="ahb read data";
       bins ahbRdata1       ={0};
       bins ahbRdata2       ={1};
       bins ahbRdata4       ={3};
       bins ahbRdata8       ={7};
       bins ahbRdata16		={15};
       bins ahbRdata32		={31};
       bins ahbRdata64		={63};
       bins ahbRdata128	    ={127};
       bins ahbRdata256	    ={255};
       bins ahbRdataDefault =default;
    }*/

    /* HEXOKAY_CP:coverpoint ahbSlaveTransaction.hexokay{
      option.comment="ahb exclusive okay";
       bins ahbExokay0={0};
       bins ahbExokay1={1};
    }*/
    
   // HREADY_CP_x_HRDATA_CP_x_HRESP_CP:cross HREADY_CP,HRDATA_CP,HRESP_CP;
  
  endgroup: ahbSlaveCovergroup

  extern function new(string name = "AhbSlaveCoverage", uvm_component parent = null);
  extern function void write(AhbSlaveTransaction t);
  extern virtual function void report_phase(uvm_phase phase);

endclass : AhbSlaveCoverage

function  AhbSlaveCoverage::new(string name = "AhbSlaveCoverage", uvm_component parent = null);
  super.new(name, parent);
  ahbSlaveCovergroup = new();
endfunction : new

function void AhbSlaveCoverage::write(AhbSlaveTransaction t);
  
  `uvm_info(get_type_name(),"AHB SLAVE COVERAGE",UVM_LOW);
  ahbSlaveCovergroup .sample(ahbSlaveAgentConfig,t);
  
endfunction : write

function void AhbSlaveCoverage::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("Entered the report_phase of AHB Slave Coverage"), UVM_NONE);
  `uvm_info(get_type_name(), $sformatf("AHB Slave Agent Coverage = %0.2f %%", ahbSlaveCovergroup.get_coverage()), UVM_NONE);
endfunction: report_phase

`endif
