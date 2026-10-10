// ============================================
// axi_agent.sv
// ============================================


class axi_agent extends uvm_agent;

    axi_sequencer sqr;
    axi_driver    drv;
    axi_monitor   mon;

    `uvm_component_utils(axi_agent)

    function new(string name = "axi_agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AXI_AGENT", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI_AGENT", "BUILD PHASE running", UVM_LOW)

        sqr = axi_sequencer::type_id::create("sqr", this);
        drv = axi_driver   ::type_id::create("drv", this);
        mon = axi_monitor  ::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AXI_AGENT", "CONNECT PHASE running", UVM_LOW)

        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass

