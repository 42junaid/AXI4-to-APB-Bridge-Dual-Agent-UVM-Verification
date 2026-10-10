// ============================================
// axi_seq_item.sv
// Complete AXI Transaction with Constraints
// ============================================

class axi_seq_item extends uvm_sequence_item;

    // AW Channel
    rand bit [15:0]  AWID;
    rand bit [31:0]  AWADDR;
    rand bit [7:0]   AWLEN;
    rand bit [2:0]   AWSIZE;
    rand bit [1:0]   AWBURST;
    rand bit         AWLOCK;
    rand bit [3:0]   AWCACHE;
    rand bit [2:0]   AWPROT;
    rand bit [3:0]   AWREGION;
    rand bit [9:0]   AWUSER;
    rand bit [3:0]   AWQOS;

    // W Channel
    rand bit [31:0]  WDATA;
    rand bit [3:0]   WSTRB;
    rand bit         WLAST;
    rand bit [9:0]   WUSER;

    // B Channel
    bit [15:0]       BID;
    bit [1:0]        BRESP;
    bit [9:0]        BUSER;

    // AR Channel
    rand bit [15:0]  ARID;
    rand bit [31:0]  ARADDR;
    rand bit [7:0]   ARLEN;
    rand bit [2:0]   ARSIZE;
    rand bit [1:0]   ARBURST;
    rand bit         ARLOCK;
    rand bit [3:0]   ARCACHE;
    rand bit [2:0]   ARPROT;
    rand bit [3:0]   ARREGION;
    rand bit [9:0]   ARUSER;
    rand bit [3:0]   ARQOS;

    // R Channel
    bit [15:0]       RID;
    bit [31:0]       RDATA;
    bit [1:0]        RRESP;
    bit              RLAST;
    bit [9:0]        RUSER;

    // Control
    rand bit         is_read;   // 1 = read, 0 = write

    // ----------------------------------------
    // UVM Macros
    // ----------------------------------------
    `uvm_object_utils_begin(axi_seq_item)
        `uvm_field_int(AWID,     UVM_ALL_ON)
        `uvm_field_int(AWADDR,   UVM_ALL_ON)
        `uvm_field_int(WDATA,    UVM_ALL_ON)
        `uvm_field_int(WSTRB,    UVM_ALL_ON)
        `uvm_field_int(BID,      UVM_ALL_ON)
        `uvm_field_int(BRESP,    UVM_ALL_ON)
        `uvm_field_int(ARID,     UVM_ALL_ON)
        `uvm_field_int(ARADDR,   UVM_ALL_ON)
        `uvm_field_int(RID,      UVM_ALL_ON)
        `uvm_field_int(RDATA,    UVM_ALL_ON)
        `uvm_field_int(RRESP,    UVM_ALL_ON)
        `uvm_field_int(RLAST,    UVM_ALL_ON)
        `uvm_field_int(is_read,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction

    // ----------------------------------------
    // Constraints (Legal Values)
    // ----------------------------------------
    constraint c_addr {
        AWADDR inside {[32'h0000_0000 : 32'h0000_FFFF]};
        ARADDR inside {[32'h0000_0000 : 32'h0000_FFFF]};
        AWADDR[1:0] == 2'b00;   // Word aligned
        ARADDR[1:0] == 2'b00;
    }

    constraint c_len {
        AWLEN == 8'h00;   // Single beat
        ARLEN == 8'h00;
    }

    constraint c_size {
        AWSIZE == 3'b010;  // 4 bytes
        ARSIZE == 3'b010;
    }

    constraint c_burst {
        AWBURST == 2'b01;  // INCR
        ARBURST == 2'b01;
    }

    constraint c_id {
        AWID inside {[16'h0000 : 16'h00FF]};
        ARID inside {[16'h0000 : 16'h00FF]};
    }

endclass
