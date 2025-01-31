
`ifndef AHBMASTERMONITORBFM_INCLUDED_
`define AHBMASTERMONITORBFM_INCLUDED_

import AhbGlobalPackage::*;

interface AhbMasterMonitorBFM(input  bit   hclk,
                              input  bit  hresetn,
    input logic [ADDR_WIDTH-1:0] haddr,
    input logic [2:0] hburst,
    input logic hmastlock,
    input logic [HPROT_WIDTH-1:0] hprot,
    input logic [2:0] hsize,
    input logic hnonsec,
    input logic hexcl,
    input logic [HMASTER_WIDTH-1:0] hmaster,
    input logic [1:0] htrans,
    input logic [DATA_WIDTH-1:0] hwdata,
    input logic [(DATA_WIDTH/8)-1:0] hwstrb,
    input logic hwrite,
    input logic [DATA_WIDTH-1:0] hrdata,
    input logic hreadyout,
    input logic hresp,
    input logic hexokay,
    input logic hready,
    input logic [NO_OF_SLAVES-1:0] hselx
);
  
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import AhbMasterPackage::*;

  AhbMasterMonitorProxy ahbMasterMonitorProxy;

  string name = "AHB_MASTER_MONITOR_BFM"; 
 
  initial begin
    `uvm_info(name, $sformatf("AHB MASTER MONITOR BFM"), UVM_LOW);
  end

  task waitForResetn();
      @(negedge hresetn);
    `uvm_info(name, $sformatf("system reset detected"), UVM_HIGH)
    
    @(posedge hresetn);
    `uvm_info(name, $sformatf("system reset deactivated"), UVM_HIGH)
  endtask : waitForResetn
  
    task sampleData (output ahbTransferCharStruct ahbDataPacket, input ahbTransferConfigStruct ahbConfigPacket);
   	
	@(negedge hclk);

	 while($countones(hselx)!== 1 && hresp == 1)begin
	   `uvm_info(name, $sformatf("Inside while loop:hready=%0d, hselx=%0d, hresp=%0d", hready, hselx, hresp), UVM_HIGH)
	 end

        while(hready !== 1) begin
	   `uvm_info(name, $sformatf("Inside while loop: penable =%0d, pready=%0d, pselx=%0d", penable, pready, pselx), UVM_HIGH)
	    @(negedge hclk);
	       ahbDataPacket.noOfWaitStates++;
	  end

	   	   ahbDataPacket.haddr  = dataPacket.haddr ; 
    	   ahbDataPacket.hsize  = dataPacket.hsize;  
           ahbDataPacket.hburst = dataPacket.hburst; 
           ahbDataPacket.htrans = dataPacket.htrans;  
           ahbDataPacket.hwrite = dataPacket.hwrite; 
           ahbDataPacket.hwdata = dataPacket.hwdata; 
           ahbDataPacket.hmasterlock = dataPacket.hmasterlock; 

	   if(hwrite == 1)begin
	      ahbDataPacket.hwdata = hwdata;
	   end
           
           else begin
              ahbDataPacket.hrdata = hrdata;
	   end
	`uvm_info(name, $sformatf("MASTER SAMPLE DATA=%p", ahbDataPacket), UVM_HIGH)
    endtask : sampleData

endinterface : AhbMasterMonitorBFM

`endif
