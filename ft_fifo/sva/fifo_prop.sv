// This property file was autogenerated by AutoSVA on 2023-09-09
// to check the behavior of the original RTL module, whose interface is described below: 

module fifo_prop
#(
		parameter ASSERT_INPUTS = 0,
		parameter INFLIGHT_IDX = 2,
		parameter SIZE = 4
)
(		// Clock + Reset
		input  wire                          clk,
		input  wire                          rst_n,
		input  wire                          in_val,
		input  wire                          in_rdy, //output
		input  wire [SIZE-1:0]               in_data,
		
		input  wire                          out_val, //output
		input  wire                          out_rdy,
		input  wire [SIZE-1:0]               out_data //output
	);

//==============================================================================
// Local Parameters
//==============================================================================
localparam INFLIGHT = 2**INFLIGHT_IDX;

genvar j;
default clocking cb @(posedge clk);
endclocking
default disable iff (!rst_n);

// Re-defined wires 
wire [INFLIGHT_IDX-1:0] in_transid;
wire [INFLIGHT_IDX-1:0] out_transid;

// Symbolics and Handshake signals
wire [INFLIGHT_IDX-1:0] symb_in_transid;
am__symb_in_transid_stable: assume property($stable(symb_in_transid));
wire out_hsk = out_val && out_rdy;
wire in_hsk = in_val && in_rdy;

//==============================================================================
// Modeling
//==============================================================================

// Modeling incoming request for fifo
if (ASSERT_INPUTS) begin
	as__fifo_fairness: assert property (out_val |-> s_eventually(out_rdy));
end else begin
	am__fifo_fairness: assume property (out_val |-> s_eventually(out_rdy));
end

// Generate sampling signals and model
reg [3:0] fifo_transid_sampled;
wire fifo_transid_set = in_hsk && in_transid == symb_in_transid;
wire fifo_transid_response = out_hsk && out_transid == symb_in_transid;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		fifo_transid_sampled <= '0;
	end else if (fifo_transid_set || fifo_transid_response ) begin
		fifo_transid_sampled <= fifo_transid_sampled + fifo_transid_set - fifo_transid_response;
	end
end
co__fifo_transid_sampled: cover property (|fifo_transid_sampled);
if (ASSERT_INPUTS) begin
	as__fifo_transid_sample_no_overflow: assert property (fifo_transid_sampled != '1 || !fifo_transid_set);
end else begin
	am__fifo_transid_sample_no_overflow: assume property (fifo_transid_sampled != '1 || !fifo_transid_set);
end


// Assert that if valid eventually ready or dropped valid
as__fifo_transid_hsk_or_drop: assert property (in_val |-> s_eventually(!in_val || in_rdy));
// Assert that every request has a response and that every reponse has a request
as__fifo_transid_eventual_response: assert property (|fifo_transid_sampled |-> s_eventually(out_val && (out_transid == symb_in_transid) ));
as__fifo_transid_was_a_request: assert property (fifo_transid_response |-> fifo_transid_set || fifo_transid_sampled);


// Modeling data integrity for fifo_transid
reg [SIZE-1:0] fifo_transid_data_model;
always_ff @(posedge clk) begin
	if(!rst_n) begin
		fifo_transid_data_model <= '0;
	end else if (fifo_transid_set) begin
		fifo_transid_data_model <= in_data;
	end
end

as__fifo_transid_data_unique: assert property (|fifo_transid_sampled |-> !fifo_transid_set);
as__fifo_transid_data_integrity: assert property (|fifo_transid_sampled && fifo_transid_response |-> (out_data == fifo_transid_data_model));

assign out_transid = fifo.buffer_tail_reg;
assign in_transid = fifo.buffer_head_reg;

//====DESIGNER-ADDED-SVA====//


// Property File for FIFO module

// Ensure that when 'in_val' is high and 'in_rdy' is not set, then the FIFO is full
as__fifo_full_when_not_ready:
assert property (fifo.in_val && !fifo.in_rdy |-> &fifo.buffer_val_reg);

// Ensure that when 'out_val' is high and 'out_rdy' is not set, then the FIFO is empty
as__fifo_empty_when_not_valid:
assert property (fifo.out_val && !fifo.out_rdy |-> !(|fifo.buffer_val_reg));

// When data is written to FIFO, the 'buffer_head_reg' should increment in the next cycle
as__head_incremented_on_write:
assert property (fifo.in_hsk |=> $past(fifo.buffer_head_reg) + 1'b1 == fifo.buffer_head_reg[INFLIGHT_IDX-1:0]);

// When data is read from FIFO, the 'buffer_tail_reg' should increment in the next cycle
as__tail_incremented_on_read:
assert property (fifo.out_hsk |=> $past(fifo.buffer_tail_reg) + 1'b1 == fifo.buffer_tail_reg[INFLIGHT_IDX-1:0]);

// If FIFO is not full and input handshake is true, the data at 'buffer_head_reg' index should be 'in_data' in the next cycle
generate
    for (genvar i = 0; i < INFLIGHT; i = i + 1) begin: check_data_on_write
        as__data_correctly_written:
        assert property (fifo.in_hsk && !(|fifo.buffer_val_reg) && (fifo.buffer_head_reg == i) |=> fifo.buffer_data_reg[i] == $past(fifo.in_data));
    end
endgenerate

// If FIFO is not empty and output handshake is true, the data at 'buffer_tail_reg' index should be sent out in the same cycle
generate
    for (genvar i = 0; i < INFLIGHT; i = i + 1) begin: check_data_on_read
        as__data_correctly_read:
        assert property (fifo.out_hsk && |fifo.buffer_val_reg && (fifo.buffer_tail_reg == i) |-> fifo.out_data == fifo.buffer_data_reg[i]);
    end
endgenerate

// If the buffer is full, 'in_rdy' should be low
as__input_not_ready_when_full:
assert property (&fifo.buffer_val_reg |-> !fifo.in_rdy);

// If the buffer is empty, 'out_val' should be low
as__output_not_valid_when_empty:
assert property (!(|fifo.buffer_val_reg) |-> !fifo.out_val);





endmodule