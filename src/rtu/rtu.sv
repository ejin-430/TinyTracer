`default_nettype wire

module rtu (
    input  logic        clk,
    input  logic        rst_n,

    // I/O <-> RTU Interface
    render_if.sink      render,

    // RTU <-> SRAM Interface
    sram_rd_if.client   sram,

    // RTU <-> EXU Interface
    macro_if.client     macro,

    // RTU <-> Accumulator Interface
    colour_if.src       sample,
    output logic [tinytracer_pkg::SPP_LOG2_W-1:0] spp_log2
);

  // Stub: just tie off unused signals
  assign macro.req_valid = 1'b0;
  assign macro.req_op = '0;
  assign macro.resp_ready = 1'b1;
  
  assign sram.req_valid = 1'b0;
  assign sram.req_raddr = '0;
  assign sram.resp_ready = 1'b1;
  
  assign sample.valid = 1'b0;
  assign sample.colour = '0;
  
  assign spp_log2 = '0;

endmodule