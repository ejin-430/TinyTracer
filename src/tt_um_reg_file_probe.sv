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

  logic [6:0] seed;
  logic [tinytracer_pkg::WLEN-1:0] write_data;
  logic [tinytracer_pkg::WLEN-1:0] read_data1;
  logic [tinytracer_pkg::WLEN-1:0] read_data2;
  tinytracer_pkg::vec3_t load_u;
  tinytracer_pkg::vec3_t load_v;
  tinytracer_pkg::vec3_t result;

  assign seed = {ui_in[7:3], uio_in[7:6]};
  assign write_data = expand_seed(seed);

  function automatic logic [tinytracer_pkg::WLEN-1:0] expand_seed(input logic [6:0] value);
    logic [tinytracer_pkg::WLEN-1:0] expanded;
    integer bit_index;
    integer offset;
    begin
      for (bit_index = 0; bit_index < tinytracer_pkg::WLEN; bit_index = bit_index + 1) begin
        offset = (bit_index / 7) + 1;
        expanded[bit_index] = value[bit_index % 7] ^ value[(bit_index % 7 + offset) % 7];
      end
      expand_seed = expanded;
    end
  endfunction

  assign load_u.x = write_data;
  assign load_u.y = {write_data[14:0], write_data[15]};
  assign load_u.z = {write_data[13:0], write_data[15:14]};
  assign load_v.x = {write_data[12:0], write_data[15:13]};
  assign load_v.y = {write_data[11:0], write_data[15:12]};
  assign load_v.z = {write_data[10:0], write_data[15:11]};

  reg_file u_reg_file (
      .clk    (clk),
      .rst_n  (rst_n),
      .load   (uio_in[4]),
      .load_u (load_u),
      .load_v (load_v),
      .result (result),
      .wen    (uio_in[3]),
      .waddr  (uio_in[2:0]),
      .wdata  (write_data),
      .raddr1 (uio_in[2:0]),
      .rdata1 (read_data1),
      .raddr2 (ui_in[2:0]),
      .rdata2 (read_data2)
  );

  assign uo_out = uio_in[5] ? read_data2[7:0] : read_data1[7:0];
  assign uio_out = uio_in[5] ? read_data2[15:8] : read_data1[15:8];
  assign uio_oe = 8'hff;

  wire _unused = &{ena, ui_in[1:0], 1'b0};

endmodule
