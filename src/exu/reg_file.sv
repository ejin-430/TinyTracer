`default_nettype wire

module icg (
    input  logic clk,
    input  logic en,
    output logic gclk
);

`ifdef SYNTHESIS
    sg13cmos5l_lgcp_1 u_icg (.CLK(clk), .GATE(en), .GCLK(gclk));
`else
    logic en_l;
    always_latch if (!clk) en_l <= en;
    assign gclk = clk & en_l;
`endif
endmodule

module reg_file (
    input  logic        clk,

    // Parallel Load (Decode): R0-R2 <- load_u.{x,y,z}, R3-R5 <- load_v.{x,y,z}
    input  logic                   load,
    input  tinytracer_pkg::vec3_t  load_u,
    input  tinytracer_pkg::vec3_t  load_v,

    // Macro-op Result (Decode): {R2, R1, R0}
    output tinytracer_pkg::vec3_t  result,

    // Write Port (FU Control)
    input  logic            wen,
    input  logic [2:0]      waddr,
    input  logic [tinytracer_pkg::WLEN-1:0] wdata,

    // Read Ports (FU Control)
    input  logic [2:0]      raddr1,
    output logic [tinytracer_pkg::WLEN-1:0] rdata1,
    input  logic [2:0]      raddr2,
    output logic [tinytracer_pkg::WLEN-1:0] rdata2
);

logic [(tinytracer_pkg::WLEN-1) : 0] regs [7 : 0]; 
logic [1:0] load_cycle;
logic clk_gated;

icg u_reg_clk_gate (.clk(clk), .en(load || wen), .gclk(clk_gated));

always_ff @(posedge clk_gated) begin 
    if (load) begin 
        case (load_cycle)
            2'b00: begin
                // Cycle 0: load x
                regs[0] <= load_u.x;
                regs[3] <= load_v.x;
                load_cycle <= 2'b01;
            end
            2'b01: begin
                // Cycle 1: load y
                regs[1] <= load_u.y;
                regs[4] <= load_v.y;
                load_cycle <= 2'b10;
            end
            2'b10: begin
                // Cycle 2: load z
                regs[2] <= load_u.z;
                regs[5] <= load_v.z;
                load_cycle <= 2'b00;
            end
        endcase
    end else if (wen) begin 
        regs[waddr] <= wdata; 
    end 
end

always_comb begin 
    // Outputs 
    rdata1 = regs[raddr1]; 
    rdata2 = regs[raddr2]; 
    result.x = regs[0]; 
    result.y = regs[1]; 
    result.z = regs[2]; 
end

endmodule
