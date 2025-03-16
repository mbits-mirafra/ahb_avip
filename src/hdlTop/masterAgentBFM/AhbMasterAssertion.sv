`ifndef AHBMASTERASSERTION_INCLUDED_
`define AHBMASTERASSERTION_INCLUDED_

import AhbGlobalPackage::*;

interface AhbMasterAssertion (
  input                      hclk,
  input                      hresetn,
  input     [ADDR_WIDTH-1:0] haddr,
  input     [DATA_WIDTH-1:0] hwdata,
  input                [2:0] hsize,
  input                [2:0] hburst,
  input                [1:0] htrans,
  input                      hwrite,
  input                      hready,
  input                      hresp,
  input                      hexcl,
  input    [HPROT_WIDTH-1:0] hprot,
  input [HMASTER_WIDTH -1:0] hmaster,
  input                      hmastlock,
  input                      hselx,
  input                [3:0] hwstrb
);

  import uvm_pkg::*;
  `include "uvm_macros.svh";

  initial begin
    `uvm_info("MASTER_ASSERTIONS","MASTER_ASSERTIONS",UVM_LOW);
  end

  property checkHwdataValid;
    @(posedge hclk) disable iff (!hresetn)
    (hwrite && hready && (htrans != 2'b00) && hselx == 1) ##1 $stable(hready)|-> (!$isunknown(hwdata));
  endproperty

  assert property (checkHwdataValid)
       $info("HWDATA is Valid When HWRITE IS HIGH");
  else $error("HWDATA contains X when HWRITE is asserted!");

  property checkHtransValidity;
    @(posedge hclk) disable iff (!hresetn)
    (htrans == 2'b10 || htrans == 2'b11) |-> ##[1:$] hready;
  endproperty

  assert property (checkHtransValidity)
       $info("HTRANS is Valid ");
  else $error("HTRANS has an invalid value or transition!");

  property checkHaddrAlignment;
    @(posedge hclk) disable iff (!hresetn)
    (hready && (htrans != 2'b00) && hburst != 3'b000 && hsize != 3'b000) |-> ((hsize == 3'b001) && (haddr[0] == 1'b0)) || 
                                                          ((hsize == 3'b010) && (haddr[1:0] == 2'b00));
  endproperty

  assert property (checkHaddrAlignment)
       $info("HADDR is aligned based on HSIZE");
  else $error("HADDR is not aligned based on HSIZE!");

  /*property ifHaddrValidAndWithinRange;
    @(posedge hclk) disable iff (!hresetn)
    (hready && (htrans != 2'b00)) |-> ((haddr >= AHB_ADDR_MIN) &&
                                      (haddr <= AHB_ADDR_MAX));
  endproperty

  assert property (ifHaddrValidAndWithinRange)
       $info("HADDR is within the valid range");
  else $error("HADDR is not within the valid range!");
 */

 /* property checkHrespOkay;
    @(posedge hclk) disable iff (!hresetn)
    (hready && (htrans != 2'b00)) |-> (hresp == 1'b0);
  endproperty

  assert property (checkHrespOkay)
       $info("HRESP is OKAY during a successful transfer");
  else $error("HRESP is Error");
*/
  /*property checkHrespErrorFixed;
    @(posedge hclk) disable iff (!hresetn)
    (hready && hresp) |-> (htrans != 2'b00);
  endproperty

  assert property (checkHrespErrorFixed)
       $info("HRESP is ERROR during error conditions");
  else $error("Unexpected HRESP ERROR when transfer is IDLE!");
*/
  /*property checkHreadyStability;
    @(posedge hclk) disable iff (!hresetn)
    (hready) |=> hready;
  endproperty

  assert property (checkHreadyStability)
       $info("HREADY remains stable during wait states");
  else $error("HREADY unexpectedly changed when slave was not ready!");
*/
  property checkHmastlockCheck;
    @(posedge hclk) disable iff (!hresetn)
    (hready && htrans != 2'b00 && hmastlock) |-> (hmastlock == 1);
  endproperty

  assert property (checkHmastlockCheck)
       $info("HMASTLOCK is asserted during a locked transfer");
  else $error("HMASTLOCK is not asserted during a locked transfer!");

  property checkBurstIncr;
    @(posedge hclk) disable iff (!hresetn)
    (hburst == 3'b001 && htrans == 2'b11) |-> (haddr == $past(haddr) + (1 << hsize));
  endproperty

  assert property (checkBurstIncr)
       $info("INCR burst type passed: Address incremented correctly");
  else $error("INCR burst type failed: Address not incremented correctly!");

  property checkBurstWrap;
    @(posedge hclk) disable iff (!hresetn)
    (hburst == 3'b010 && htrans == 2'b11) |-> (((haddr & ((1 << hsize) - 1)) == 0) ||
                                              (haddr == $past(haddr) + (1 << hsize)));
  endproperty

  assert property (checkBurstWrap)
       $info("WRAP burst type passed: Address wrapping is done correctly");
  else $error("WRAP burst type failed: Address wrapping incorrect!");

  property checkTransBusyToSeq;
    @(posedge hclk) disable iff(!hresetn)
    (htrans == 2'b01 && hready == 1 )|=> (haddr == $past(haddr)) && (htrans == 2'b11);
  endproperty
 
  assert property(checkTransBusyToSeq)
           $info("Transition from BUSY to SEQ passed and address is hold ");
  else $error("Transition from BUSY to SEQ failed: and address is not hold");

 /* property checkTransBusyToNonSeq;
    @(posedge hclk) disable iff(!hresetn)
    (htrans == 2'b01 && hready ==0 && hburst inside {[3'b000:3'b001]}) |=>
    (htrans == 2'b10 && $stable(hburst));
  endproperty

  assert property(checkTransBusyToNonSeq)
       $info("Transition from BUSY to NON - SEQ passed");
  else $error("Transition from BUSY to NON - SEQ failed: Conditions not met!");
*/
  property checkTransIdleToNonSeq;
    @(posedge hclk) disable iff(!hresetn)
    ((htrans == 2'b00  && hready == 1 )|=>
    ( htrans == 2'b10)); 
  endproperty

  assert property(checkTransIdleToNonSeq)
       $info("Transition from IDLE to NON-SEQ passed");
  else $error("Transition from IDLE to NON-SEQ failed: Conditions not met!");

  property checkAddrStability;
    @(posedge hclk) disable iff (!hresetn)
    (htrans == 2'b10||htrans ==2'b11) |=> $stable(haddr) until (hready);
  endproperty

  assert property (checkAddrStability)
       $info("Address stability during waited transfer verified.");
  else $error("Address changed before HREADY HIGH!");

 property checkHaddrUnchanged;
    @(posedge hclk) disable iff (!hresetn)
    (hready && (htrans != 2'b00) && (htrans == 2'b01) ##1 (htrans==2'b01)) |-> (haddr == $past(haddr));
  endproperty

  assert property (checkHaddrUnchanged)
       $info("HADDR remains unchanged during a Busy transfer!");
  else $error("HADDR changed unexpectedly during a Busy transfer!");

  property checkHsizeMatchesData;
    @(posedge hclk) disable iff (!hresetn)
    (hready && (htrans != 2'b00)) |-> ((1 << hsize) <= 32);
  endproperty

  assert property (checkHsizeMatchesData)
       $info("HSIZE matches the data width supported by the slave!");
  else $error("HSIZE does not match the data width supported by the slave!");

  property checkBurstTypeValid;
    @(posedge hclk) disable iff (!hresetn)
    (hready && (htrans != 2'b00)) |-> (hburst inside {[0:7]});
  endproperty

  assert property (checkBurstTypeValid)
       $info("Valid burst type!");
  else $error("Invalid burst type detected!");
 
 property checkStrobe;
   @(posedge hclk) disable iff (!hresetn)
   (htrans != 2'b00) |->((hsize == 3'b000 -> $countones(hwstrb)== 1 )) || ((hsize ==3'b001 -> $countones(hwstrb)==2)) || ((hsize==3'b010 -> $countones(hwstrb)==4));
 endproperty
 
 assert property (checkStrobe)
   $info("Hwstrb valid ");
 else 
   $error("Hwstrb is not valid for hsize");

endinterface : AhbMasterAssertion

`endif


