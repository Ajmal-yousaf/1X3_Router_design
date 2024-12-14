module router_fifo(data_in,clock,resetn,soft_reset,write_enb,read_enb,lfd_state,full,empty,data_out);
input [7:0]data_in;
input clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
output reg full,empty;
output reg [7:0]data_out;
reg [8:0]fifo[15:0];
reg [3:0]wptr,rptr;
reg [4:0]incmtr;
reg [5:0] count;
reg temp;

always@(posedge clock) begin
if(~resetn)
temp <=0;
else
temp <=lfd_state; end

always@(posedge clock) begin // for full and empty flag
if(~resetn)
incmtr<=0;
 else if((write_enb&& !full)&&(read_enb&& !empty))
incmtr<=incmtr;
 else if(write_enb&& !full)
incmtr<=incmtr+1;
 else if(read_enb&& !empty)
incmtr<=incmtr-1;
 else
incmtr<=incmtr;
 end

//write logic
always@(posedge clock) begin
if(!resetn || soft_reset)
 begin
   data_out<=0;full=0;empty=1;wptr=0;rptr=0;incmtr=0;
 end
else 
begin
 if(write_enb&& !full)  
 {fifo[wptr[3:0]][8],fifo[wptr[3:0]][7:0]}={temp,data_in};
 end
end

//read logic
always@(posedge clock)begin
if(!resetn)
data_out <=8'b0;
else if(soft_reset)
data_out <=8'bzz;
else 
begin
  if(read_enb&&!empty) 
  data_out<=fifo[rptr[3:0]];
  if(count==0)
  data_out <=8'bzz;
end
end

// counter logic
always@(posedge clock)
 begin
 if(read_enb&&!empty) 
   begin
    if(fifo[rptr[3:0]][8])
       count<=fifo[rptr[3:0]][7:2]+1'b1;// length+parity
    else if(count!=6'd0)
       count<=count-1;
 end
 end
//pointer logic
always@(posedge clock)
begin
if(!resetn || soft_reset)
   begin
   rptr <=5'b0;
   wptr <=5'b0;
   end
else 
   begin
    if(write_enb&& !full)
       wptr=wptr+'b1;
    if(read_enb&&!empty) 
       rptr=rptr+1'b1;
   end
end

//full and empty
always@(incmtr)  
begin
    full=(incmtr==1111)?1:0;
    empty=(incmtr==0000)?1:0;
end
endmodule
