// ============================================
// axi2apb_pkg.sv
// ============================================


package axi2apb_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Seq Items
    `include "axi_seq_item.sv"
    `include "apb_seq_item.sv"

    // Sequencers
    `include "axi_sequencer.sv"
    `include "apb_sequencer.sv"

    // Drivers
    `include "axi_driver.sv"
    `include "apb_driver.sv"

    // Monitors
    `include "axi_monitor.sv"
    `include "apb_monitor.sv"

    // Agents
    `include "axi_agent.sv"
    `include "apb_agent.sv"

    // Scoreboard + Coverage
    `include "axi2apb_scoreboard.sv"
    `include "axi2apb_coverage.sv"

    // Environment
    `include "axi2apb_env.sv"

    // Sequences
    `include "axi2apb_seq.sv"

    // Tests
    `include "axi2apb_base_test.sv"
    `include "axi2apb_test.sv"

endpackage

