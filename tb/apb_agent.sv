// ============================================
// apb_agent.sv
// ============================================

class apb_agent extends uvm_agent;

    apb_sequencer sqr;
    apb_driver    drv;
    apb_monitor   mon;

    `uvm_component_utils(apb_agent)

    function new(string name = "apb_agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info("APB_AGENT", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("APB_AGENT", "BUILD PHASE running", UVM_LOW)

        sqr = apb_sequencer::type_id::create("sqr", this);
        drv = apb_driver   ::type_id::create("drv", this);
        mon = apb_monitor  ::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("APB_AGENT", "CONNECT PHASE running", UVM_LOW)

        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass

