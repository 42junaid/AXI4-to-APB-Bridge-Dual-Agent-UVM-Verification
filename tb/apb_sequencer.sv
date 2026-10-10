// ============================================
// apb_sequencer.sv
// ============================================


class apb_sequencer extends uvm_sequencer #(apb_seq_item);

    `uvm_component_utils(apb_sequencer)

    function new(string name = "apb_sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info("APB_SEQUENCER", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("APB_SEQUENCER", "BUILD PHASE running", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("APB_SEQUENCER", "CONNECT PHASE running", UVM_LOW)
    endfunction

endclass


