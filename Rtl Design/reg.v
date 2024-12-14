module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);
input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,lfd_state,laf_state,full_state,rst_int_reg;
input [7:0]data_in;
output reg err,parity_done,low_packet_valid;
output reg [7:0] dout;
reg [7:0] header_reg,fifo_full_reg,internal_parity_reg,packet_parity_reg;

always@(posedge clock) begin
 if(~resetn || detect_add) 
parity_done<=1'b0;
 else begin
  if(ld_state&&!fifo_full&& !pkt_valid)
parity_done<=1'b1;
  else if (laf_state&&low_packet_valid&& !parity_done)
parity_done<=1'b1;
  end
  end

always@(posedge clock) begin
 if(~resetn || rst_int_reg)
low_packet_valid<=1'b0;
 else if (ld_state==1'b1&& pkt_valid==1'b0)
low_packet_valid<=1'b1;
end

always@(posedge clock) begin
 if(!resetn)
  begin
   packet_parity_reg<=8'b0;
  end
 else begin
   if(ld_state&& !pkt_valid)
     packet_parity_reg<=data_in;
   end
end

always@(posedge clock) begin
if(!resetn)
dout=8'b0;
else begin
  if(detect_add && pkt_valid)
   header_reg <= data_in;
  else if(lfd_state)
   dout<=header_reg;
  else if(ld_state&&!fifo_full)
   dout<=data_in;
  else if(ld_state&&fifo_full)
   fifo_full_reg<= data_in;
  else if(laf_state)
   dout<=fifo_full_reg;

  end
end

always@(posedge clock) begin
  if(!resetn)
    internal_parity_reg<=8'b0;
  else if(lfd_state)
    internal_parity_reg<=internal_parity_reg^header_reg;
  else if(pkt_valid&&ld_state&& !full_state)
   internal_parity_reg<=internal_parity_reg^data_in;
  else begin
   if(detect_add)
       internal_parity_reg<=8'b0;
   end
end


always@(posedge clock) begin
if(~resetn)
  err<=1'b0;
else begin
   if(parity_done)
      begin
       if(internal_parity_reg != packet_parity_reg)
           err<=1'b1;
       else 
           err<=1'b0;
      end
    end
end
endmodule
