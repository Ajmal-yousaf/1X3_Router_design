module router_fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2
       ,parity_done, low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid;
input [1:0] data_in;
output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
reg [2:0] present_state, next_state;
reg [1:0] addr;
parameter  decode_address = 3'b000,
           load_first_data = 3'b001,
           load_data = 3'b010,
           load_parity = 3'b011,
           fifo_full_state = 3'b100,
           load_after_full = 3'b101,
           wait_till_empty = 3'b110,
           check_parity_error = 3'b111;

always@(posedge clock) begin
if(!resetn)
addr<=2'b00;
else if(detect_add)         
addr<=data_in;
end 

always@(posedge clock) begin
 if(!resetn)
   present_state<=decode_address;
 else if(((addr == 2'b00)&&soft_reset_0)||((addr == 2'b01)&&soft_reset_1)||((addr == 2'b10)&&soft_reset_2))
   present_state<=decode_address;
 else
  present_state<=next_state;
end


always@(*) begin
case(present_state)
 decode_address:begin
                if((pkt_valid&&(addr==2'b00) && fifo_empty_0)||(pkt_valid&&(addr==2'b01) && fifo_empty_1)||(pkt_valid&&(addr==2'b10) && fifo_empty_2))
                 next_state<=load_first_data;
                else if ((pkt_valid && (addr == 2'b00) && !fifo_empty_0) || (pkt_valid && (addr == 2'b01) && !fifo_empty_1) || (pkt_valid && (addr == 2'b10) && !fifo_empty_2))
                 next_state<=wait_till_empty;
                else
                  next_state<=decode_address;
                end

 load_first_data:next_state<=load_data;

 wait_till_empty:begin
                 if ((fifo_empty_0 && (addr==0))||(fifo_empty_1 && (addr==1))||(fifo_empty_2 && (addr==2)))
                 next_state<=load_first_data;
                 else
                 next_state<=wait_till_empty;
                 end

load_data:begin
          if(fifo_full)
          next_state<=fifo_full_state;
          else if(!fifo_full&&!pkt_valid)
          next_state<=load_parity;
          else
          next_state<=load_data;
          end

fifo_full_state:begin
          if(!fifo_full)
          next_state<=load_after_full;
          else if(fifo_full)
          next_state<=fifo_full_state;
          end

load_after_full:begin
          if(!parity_done&&low_packet_valid)
          next_state<=load_parity;
          else if(!parity_done&&!low_packet_valid)
          next_state<=load_data;
          else if(parity_done)
          next_state<=decode_address;
          else
          next_state<=load_after_full;
          end

load_parity:next_state<=check_parity_error;

check_parity_error:begin
          if(fifo_full)
          next_state<=fifo_full_state;
          else if (!fifo_full)
          next_state<=decode_address; end
 endcase 
end
assign busy=((present_state==load_first_data)||(present_state==fifo_full_state)||
             (present_state==load_after_full)||(present_state==load_parity)||(
              present_state==check_parity_error)||(present_state==wait_till_empty))?1:0;
assign detect_add=(present_state==decode_address)?1:0;
assign lfd_state=(present_state==load_first_data)?1:0;
assign ld_state=(present_state==load_data)?1:0;
assign write_enb_reg=((present_state==load_data)||(present_state==load_after_full)||(present_state==load_parity))?1:0;
assign laf_state=(present_state==load_after_full)?1:0;
assign full_state=(present_state==fifo_full_state)?1:0;
assign rst_int_reg=(present_state==check_parity_error)?1:0;
endmodule
