// ============================================
// tb_top.sv
// Top Testbench Module with Waveform Dump
// ============================================

`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH   = 16;
    parameter USER_WIDTH = 10;

    // Clock & Reset
    logic ACLK;
    logic ARESETn;

    initial ACLK = 0;
    always #5 ACLK = ~ACLK;

    initial begin
        ARESETn = 0;
        repeat (5) @(posedge ACLK);
        ARESETn = 1;
    end

    // Test enable
    logic test_en_i;
    assign test_en_i = 1'b0;

    // Interface Instances
    AXI_BUS axi_vif (.ACLK(ACLK), .ARESETn(ARESETn));
    APB_BUS apb_vif (.PCLK(ACLK), .PRESETn(ARESETn));

    // DUT
    axi2apb_wrap #(
        .AXI_ADDR_WIDTH (32),
        .AXI_DATA_WIDTH (32),
        .AXI_USER_WIDTH (10),
        .AXI_ID_WIDTH   (16),
        .APB_ADDR_WIDTH (32),
        .APB_DATA_WIDTH (32)
    ) dut (
        .clk_i      (ACLK),
        .rst_ni     (ARESETn),
        .test_en_i  (test_en_i),
        .axi_slave  (axi_vif.Slave),
        .apb_master (apb_vif.Master)
    );

    // ============================================
    // WAVEFORM DUMP
    // ============================================
    initial begin
        // VCS VPD dump
        $vcdplusfile("waveform.vpd");
        $vcdpluson(0, tb_top);     // 0 = all signals, tb_top = scope
        `uvm_info("TB_TOP", "Waveform dump started: waveform.vpd", UVM_LOW)
    end

    // ============================================
    // UVM Start
    // ============================================
    initial begin
        `uvm_info("TB_TOP", "======================================", UVM_LOW)
        `uvm_info("TB_TOP", "Testbench starting...", UVM_LOW)
        `uvm_info("TB_TOP", "======================================", UVM_LOW)

        uvm_config_db #(virtual AXI_BUS)::set(null, "*", "axi_vif", axi_vif);
        uvm_config_db #(virtual APB_BUS)::set(null, "*", "apb_vif", apb_vif);

        run_test("axi2apb_test");
    end

endmodule
