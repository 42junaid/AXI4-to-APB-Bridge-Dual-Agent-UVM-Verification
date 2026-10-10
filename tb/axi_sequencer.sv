// ============================================
// axi_sequencer.sv
// ============================================


class axi_sequencer extends uvm_sequencer #(axi_seq_item);

    `uvm_component_utils(axi_sequencer)

    function new(string name = "axi_sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AXI_SEQUENCER", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI_SEQUENCER", "BUILD PHASE running", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AXI_SEQUENCER", "CONNECT PHASE running", UVM_LOW)
    endfunction

endclass


