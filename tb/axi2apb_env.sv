// ============================================
// axi2apb_env.sv
// ============================================

class axi2apb_env extends uvm_env;

    axi_agent            axi_agt;
    apb_agent            apb_agt;
    axi2apb_scoreboard   scb;
    axi2apb_coverage     cov;

    axi_scb_wrapper      axi_scb_wrap;
    apb_scb_wrapper      apb_scb_wrap;

    axi_cov_wrapper      axi_cov_wrap;
    apb_cov_wrapper      apb_cov_wrap;

    `uvm_component_utils(axi2apb_env)

    function new(string name = "axi2apb_env", uvm_component parent);
        super.new(name, parent);
        `uvm_info("ENV", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ENV", "BUILD PHASE running", UVM_LOW)

        axi_agt      = axi_agent         ::type_id::create("axi_agt",      this);
        apb_agt      = apb_agent         ::type_id::create("apb_agt",      this);
        scb          = axi2apb_scoreboard::type_id::create("scb",          this);
        cov          = axi2apb_coverage  ::type_id::create("cov",          this);
        axi_scb_wrap = axi_scb_wrapper   ::type_id::create("axi_scb_wrap", this);
        apb_scb_wrap = apb_scb_wrapper   ::type_id::create("apb_scb_wrap", this);
        axi_cov_wrap = axi_cov_wrapper   ::type_id::create("axi_cov_wrap", this);
        apb_cov_wrap = apb_cov_wrapper   ::type_id::create("apb_cov_wrap", this);

        // Link wrappers to scoreboard and coverage
        axi_scb_wrap.scb = scb;
        apb_scb_wrap.scb = scb;
        axi_cov_wrap.cov = cov;
        apb_cov_wrap.cov = cov;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("ENV", "CONNECT PHASE running", UVM_LOW)

        // AXI Monitor ? Scoreboard
        axi_agt.mon.ap.connect(axi_scb_wrap.analysis_export);
        `uvm_info("ENV", "AXI Monitor ap connected to Scoreboard", UVM_LOW)

        // APB Monitor ? Scoreboard
        apb_agt.mon.ap.connect(apb_scb_wrap.analysis_export);
        `uvm_info("ENV", "APB Monitor ap connected to Scoreboard", UVM_LOW)

        // AXI Monitor ? Coverage
        axi_agt.mon.ap.connect(axi_cov_wrap.analysis_export);
        `uvm_info("ENV", "AXI Monitor ap connected to Coverage", UVM_LOW)

        // APB Monitor ? Coverage
        apb_agt.mon.ap.connect(apb_cov_wrap.analysis_export);
        `uvm_info("ENV", "APB Monitor ap connected to Coverage", UVM_LOW)
    endfunction

endclass
