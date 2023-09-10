// This property file was autogenerated by AutoSVA on 2023-09-10
// to check the behavior of the original RTL module, whose interface is described below: 
/*
This is the Specification of a FIFO queue.

# REQUIREMENTS
- The push_* interface pushes data into the FIFO
- The pop_* iterface pops data from the FIFO
- pop_data MUST BE usable the same cycle that pop_val is active.
- The module MUST handle push and pop at the same time.

Implement the following module only using synthesizable Verilog.
Append "_reg" to the name of ALL registers.
*/

module fifo_gen_prop
#(
		parameter ASSERT_INPUTS = 0,
		parameter INFLIGHT_IDX = 2, // Log2 of the number of slots
		parameter SIZE = 4 // Width of the data slot
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

// Symbolics and Handshake signals

//==============================================================================
// Modeling
//==============================================================================


//====DESIGNER-ADDED-SVA====//


// Property File for fifo_gen

// If input is valid and the FIFO is not full, then the FIFO should be ready to accept the data.
as__input_ready_when_not_full:
    assert property (fifo_gen.in_val && !fifo_gen.full_reg |-> fifo_gen.in_rdy);

// If output is requested and the FIFO is not empty, then output should be valid.
as__output_valid_when_not_empty:
    assert property (!fifo_gen.empty_reg |-> fifo_gen.out_val);

// If input is valid and FIFO is ready (not full), then the write pointer should increment in the next cycle.
as__write_pointer_increment:
    assert property (fifo_gen.in_val && fifo_gen.in_rdy |=> $past(fifo_gen.wr_ptr_reg) + 1'b1 == fifo_gen.wr_ptr_reg);

// If output is valid and FIFO is ready (not empty), then the read pointer should increment in the next cycle.
as__read_pointer_increment:
    assert property (fifo_gen.out_rdy && fifo_gen.out_val |=> $past(fifo_gen.rd_ptr_reg) + 1'b1 == fifo_gen.rd_ptr_reg);

// If write pointer wraps around, it should not increment but reset to zero.
as__write_pointer_wrap_around:
    assert property ((fifo_gen.wr_ptr_reg) == INFLIGHT-1 && fifo_gen.in_val && fifo_gen.in_rdy |=> fifo_gen.wr_ptr_reg == 0);

// If read pointer wraps around, it should not increment but reset to zero.
as__read_pointer_wrap_around:
    assert property ((fifo_gen.rd_ptr_reg) == INFLIGHT-1 && fifo_gen.out_rdy && fifo_gen.out_val |=> fifo_gen.rd_ptr_reg == 0);

as__pointers_equal_when_empty:
    assert property (fifo_gen.in_val && fifo_gen.in_rdy && (((fifo_gen.wr_ptr_reg + 1'b1) % INFLIGHT) == fifo_gen.rd_ptr_reg) && !(fifo_gen.out_val && fifo_gen.out_rdy) |=> fifo_gen.empty_reg);

as__fifo_full_condition:
    assert property (fifo_gen.out_val && fifo_gen.out_rdy && (((fifo_gen.rd_ptr_reg + 1) % INFLIGHT) == fifo_gen.wr_ptr_reg) && !(fifo_gen.in_val && fifo_gen.in_rdy) |=> fifo_gen.full_reg);

// If FIFO is not empty and output is ready, the out_data should get the value at the current read pointer.
as__out_data_on_read:
    assert property (!fifo_gen.empty_reg && fifo_gen.out_rdy |-> fifo_gen.out_data == fifo_gen.fifo_storage_reg[fifo_gen.rd_ptr_reg]);

// When input is valid, data should be written to the FIFO at the current write pointer.
as__in_data_on_write:
    assert property (fifo_gen.in_val && fifo_gen.in_rdy |=> fifo_gen.fifo_storage_reg[$past(fifo_gen.wr_ptr_reg)] == $past(fifo_gen.in_data));



endmodule