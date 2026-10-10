// ============================================
// apb_seq_item.sv
// APB Transaction Class
// ============================================

class apb_seq_item extends uvm_sequence_item;

    // ----------------------------------------
    // APB SIGNALS
    // ----------------------------------------
    rand bit [31:0]  PADDR;
    rand bit         PWRITE;
    rand bit [31:0]  PWDATA;
    rand bit [31:0]  PRDATA;
    rand bit         PREADY;
    rand bit         PSLVERR;
    rand int         wait_cycles;

    // ----------------------------------------
    // UVM MACROS
    // ----------------------------------------
    `uvm_object_utils_begin(apb_seq_item)
        `uvm_field_int(PADDR,       UVM_ALL_ON)
        `uvm_field_int(PWRITE,      UVM_ALL_ON)
        `uvm_field_int(PWDATA,      UVM_ALL_ON)
        `uvm_field_int(PRDATA,      UVM_ALL_ON)
        `uvm_field_int(PREADY,      UVM_ALL_ON)
        `uvm_field_int(PSLVERR,     UVM_ALL_ON)
        `uvm_field_int(wait_cycles, UVM_ALL_ON)
    `uvm_object_utils_end

    // ----------------------------------------
    // CONSTRUCTOR
    // ----------------------------------------
    function new(string name = "apb_seq_item");
        super.new(name);
        `uvm_info("APB_SEQ_ITEM", "Class created", UVM_LOW)
    endfunction

endclass
