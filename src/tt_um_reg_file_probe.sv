`default_nettype wire

module tt_um_reg_file_probe (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  logic [tinytracer_pkg::WLEN-1:0] wdata;
  logic [tinytracer_pkg::WLEN-1:0] read_data1;
  logic [tinytracer_pkg::WLEN-1:0] read_data2;
  tinytracer_pkg::vec3_t load_u;
  tinytracer_pkg::vec3_t load_v;
  tinytracer_pkg::vec3_t result;

  assign wdata = {8'h00, ui_in};
  assign load_u = '0;
  assign load_v = '0;

  reg_file u_reg_file (
      .clk    (clk),
      .rst_n  (rst_n),
      .load   (uio_in[4]),
      .load_u (load_u),
      .load_v (load_v),
      .result (result),
      .wen    (uio_in[3]),
      .waddr  (uio_in[2:0]),
      .wdata  (wdata),
      .raddr1 (uio_in[2:0]),
      .rdata1 (read_data1),
      .raddr2 (ui_in[2:0]),
      .rdata2 (read_data2)
  );

  assign uo_out = read_data1[7:0];
  assign uio_out = read_data1[15:8];
  assign uio_oe = 8'hff;

  wire _unused = &{ena, 1'b0};

endmodule
