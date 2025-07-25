`ifndef AHBSLAVEDRIVERBFM_INCLUDED_
`define AHBSLAVEDRIVERBFM_INCLUDED_
 
import AhbGlobalPackage::*;
 
interface AhbSlaveDriverBFM (input  bit   hclk,
                             input  bit   hresetn,
	                  		     input  logic [2:0] hburst,
			                       input  logic hmastlock,
                             input  logic [ADDR_WIDTH-1:0] haddr,                             
                             input  logic [HPROT_WIDTH-1:0] hprot,
                             input  logic [2:0] hsize,
                             input  logic hnonsec,
                             input  logic hexcl,
                             input  logic [HMASTER_WIDTH-1:0] hmaster,
                             input  logic [1:0] htrans, 
   			                     input  logic [DATA_WIDTH-1:0] hwdata,
                             input  logic [(DATA_WIDTH/8)-1:0]hwstrb,
                             input  logic hwrite,                             
                             output logic [DATA_WIDTH-1:0] hrdata,
			                       output logic hreadyout,
			                       output logic hresp,
                             output logic hexokay,
                             input  logic hready,                                                           
                             input  logic [NO_OF_SLAVES-1:0]hselx
                            );
 
  import AhbSlavePackage::*;
 
  `include "uvm_macros.svh"
  import uvm_pkg::*;
 
 
  string name = "AHB_SLAVE_DRIVER_BFM";
 
  AhbSlaveDriverProxy ahbSlaveDriverProxy ;
  initial begin
    `uvm_info(name,$sformatf(name),UVM_LOW);
  end
 
  task waitForResetn();
	  @(negedge hresetn);
   	`uvm_info(name,$sformatf("SYSTEM RESET DETECTED"),UVM_LOW)  
    @(posedge hresetn);
    `uvm_info(name,$sformatf("SYSTEM RESET DEACTIVATED"),UVM_LOW)
  endtask: waitForResetn

  task slaveDriveToBFM(inout ahbTransferCharStruct dataPacket, input ahbTransferConfigStruct configPacket);
	  `uvm_info(name,$sformatf("DRIVE TO BFM TASK"), UVM_LOW);

	  wait(hselx)
    `uvm_info(name,$sformatf("AFTERHSELASSERTED HTRANSFER = %0d",htrans), UVM_LOW);
    if(hburst === SINGLE) begin
      slaveDriveSingleTransfer(dataPacket,configPacket);
	  end
    else if(hburst !== SINGLE) begin
      slavedriveBurstTransfer(dataPacket,configPacket);
	  end
  endtask: slaveDriveToBFM
 
  task slaveDriveSingleTransfer(inout ahbTransferCharStruct dataPacket,input ahbTransferConfigStruct configPacket);
    `uvm_info(name,$sformatf("DRIVING THE Single Transfer"),UVM_LOW)
    hreadyout 		       <= 1;
    dataPacket.haddr     <= haddr;
    dataPacket.htrans    <= ahbTransferEnum'(htrans);
    dataPacket.hsize     <= ahbHsizeEnum'(hsize); 
    dataPacket.hburst    <= ahbBurstEnum'(hburst);
    dataPacket.hwrite    <= ahbOperationEnum'(hwrite);  
    dataPacket.hmastlock <= hmastlock; 
    dataPacket.hselx     <= hselx;    

    waitCycles(configPacket);
    if(hwrite) begin
      dataPacket.hwdata[0] <= hwdata;
      dataPacket.hwstrb[0] <= hwstrb;
	    hresp <= 0;
    end

    else if(!hwrite) begin
      hrdata <= dataPacket.hrdata[0];
	    hresp  <= 0;
    end
    @(posedge hclk);
    hreadyout <= 0;

  endtask: slaveDriveSingleTransfer
 
  task slavedriveBurstTransfer(inout ahbTransferCharStruct dataPacket,input ahbTransferConfigStruct configPacket);

    int burst_length;
	  `uvm_info(name,$sformatf("STARTEDBURSTTRANSFERTASK"),UVM_LOW)
    case (hburst)
      3'b010, 3'b011: burst_length = 4;  
      3'b100, 3'b101: burst_length = 8;  
      3'b110, 3'b111: burst_length = 16; 
      default: burst_length = 1;
    endcase
 
	  for(int i = 0;i < burst_length;i++) begin
      hreadyout <= 1;
      dataPacket.haddr       <= haddr;
      dataPacket.hburst      <= ahbBurstEnum'(hburst);  
      dataPacket.hsize       <= ahbHsizeEnum'(hsize);  
      dataPacket.hwrite      <= ahbOperationEnum'(hwrite);
      dataPacket.htrans      <= ahbTransferEnum'(htrans); 
      dataPacket.hmastlock   <= hmastlock; 
      dataPacket.hselx       <= hselx;
	    `uvm_info(name, $sformatf("Busy = %0b",dataPacket.busyControl), UVM_LOW);      
      if(i==0)  
        waitCycles(configPacket);
      if(hwrite) begin
        //if(i!=0) begin
	        @(posedge hclk);
        //end
        dataPacket.hwdata[i]  <= hwdata;
        dataPacket.hwstrb[i]  <= hwstrb;
        hresp  <= 0;
      end
      else if(!hwrite) begin
        if(i!=0) begin
	        @(posedge hclk);
        end
	      `uvm_info(name, $sformatf("DEBUG Address=%0h, Burst=%0b, Size=%0b, Write=%0b,hrdata[%0d] = %0d",
				dataPacket.haddr, dataPacket.hburst, dataPacket.hsize, dataPacket.hwrite,i,dataPacket.hrdata[i]), UVM_LOW);
        hrdata <=dataPacket.hrdata[i];
       
        hresp  <= 0;
      end
    end
    hreadyout <= 0;
  endtask: slavedriveBurstTransfer
 
 
  task waitCycles(inout ahbTransferConfigStruct configPacket);
    @(posedge hclk);
    hresp <= 0;
    repeat(configPacket.noOfWaitStates) begin
	    `uvm_info(name,$sformatf(" DRIVING WAIT STATE"),UVM_LOW);
    	hreadyout <= 0;
      hresp <=  ~hreadyout;
      @(posedge hclk);
    end
    hreadyout<=1;
 
    `uvm_info(name, "Bus is now out of wait cycles", UVM_LOW);
  endtask: waitCycles
 
endinterface
`endif
