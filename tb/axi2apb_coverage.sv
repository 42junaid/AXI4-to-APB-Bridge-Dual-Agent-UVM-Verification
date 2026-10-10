// ============================================
// axi2apb_coverage.sv
// Functional Coverage Collector
// ============================================

class axi2apb_coverage extends uvm_subscriber #(axi_seq_item);

    // AXI transaction handle
    axi_seq_item tr;

    // APB transaction handle
    apb_seq_item apb_tr;

    // ----------------------------------------
    // Covergroup 1: AXI Transaction Coverage
    // ----------------------------------------
    covergroup cg_axi;
        option.per_instance = 1;

        // Transaction type
        cp_is_read : coverpoint tr.is_read {
            bins write = {1'b0};
            bins read  = {1'b1};
        }

        // Write Address
        cp_awaddr : coverpoint tr.AWADDR {
            bins zero = {32'h0000_0000};
            bins low  = {[32'h0000_0001 : 32'h0000_00FF]};
            bins mid  = {[32'h0000_0100 : 32'h0000_7FFF]};
            bins high = {[32'h0000_8000 : 32'h0000_FFFE]};
            bins max  = {32'h0000_FFFF};
        }

        // Read Address
        cp_araddr : coverpoint tr.ARADDR {
            bins zero = {32'h0000_0000};
            bins low  = {[32'h0000_0001 : 32'h0000_00FF]};
            bins mid  = {[32'h0000_0100 : 32'h0000_7FFF]};
            bins high = {[32'h0000_8000 : 32'h0000_FFFE]};
            bins max  = {32'h0000_FFFF};
        }

        // Write Data Pattern
        cp_wdata : coverpoint tr.WDATA {
            bins all_zero = {32'h0000_0000};
            bins all_one  = {32'hFFFF_FFFF};
            bins alt_aa   = {32'hAAAA_AAAA};
            bins alt_55   = {32'h5555_5555};
            bins walking  = {32'h0000_0001, 32'h0000_0002, 32'h0000_0004,
                             32'h0000_0008, 32'h0000_0010};
            bins others   = default;
        }

        // Write ID
        cp_awid : coverpoint tr.AWID {
            bins low  = {[16'h0000 : 16'h003F]};
            bins mid  = {[16'h0040 : 16'h00BF]};
            bins high = {[16'h00C0 : 16'h00FF]};
        }

        // Read ID
        cp_arid : coverpoint tr.ARID {
            bins low  = {[16'h0000 : 16'h003F]};
            bins mid  = {[16'h0040 : 16'h00BF]};
            bins high = {[16'h00C0 : 16'h00FF]};
        }

        // Write Response
        cp_bresp : coverpoint tr.BRESP {
            bins okay   = {2'b00};
            bins exokay = {2'b01};
            bins slverr = {2'b10};
            bins decerr = {2'b11};
        }

        // Read Response
        cp_rresp : coverpoint tr.RRESP {
            bins okay   = {2'b00};
            bins exokay = {2'b01};
            bins slverr = {2'b10};
            bins decerr = {2'b11};
        }

        // Read Last
        cp_rlast : coverpoint tr.RLAST {
            bins not_last = {1'b0};
            bins last     = {1'b1};
        }

        // Cross Coverage (YAHAN ANDAR RAKHO)
        cx_type_addr : cross cp_is_read, cp_awaddr;

    endgroup

    // ----------------------------------------
    // Covergroup 2: APB Coverage
    // ----------------------------------------
    covergroup cg_apb;
        option.per_instance = 1;

        cp_pwrite : coverpoint apb_tr.PWRITE {
            bins read  = {1'b0};
            bins write = {1'b1};
        }

        cp_pready : coverpoint apb_tr.PREADY {
            bins ready = {1'b1};
        }

        cp_pslverr : coverpoint apb_tr.PSLVERR {
            bins no_error = {1'b0};
            bins error    = {1'b1};
        }

    endgroup

    `uvm_component_utils(axi2apb_coverage)

    function new(string name = "axi2apb_coverage", uvm_component parent);
        super.new(name, parent);
        cg_axi = new();
        cg_apb = new();
        `uvm_info("COVERAGE", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("COVERAGE", "BUILD PHASE running", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("COVERAGE", "CONNECT PHASE running", UVM_LOW)
    endfunction

    // ----------------------------------------
    // Sample AXI Transaction
    // ----------------------------------------
    function void write(axi_seq_item t);
        tr = t;
        cg_axi.sample();
        `uvm_info("COVERAGE", $sformatf("Sampled AXI: is_read=%0d", t.is_read), UVM_HIGH)
    endfunction

    // ----------------------------------------
    // Sample APB Transaction
    // ----------------------------------------
    function void sample_apb(apb_seq_item t);
        apb_tr = t;
        cg_apb.sample();
        `uvm_info("COVERAGE", "Sampled APB", UVM_HIGH)
    endfunction

    // ----------------------------------------
    // Report Phase
    // ----------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COVERAGE", "======================================", UVM_LOW)
        `uvm_info("COVERAGE", "         COVERAGE SUMMARY", UVM_LOW)
        `uvm_info("COVERAGE", "======================================", UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("AXI Coverage   : %0.2f%%", cg_axi.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("APB Coverage   : %0.2f%%", cg_apb.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", "======================================", UVM_LOW)
    endfunction

endclass


// ============================================
// AXI Coverage Wrapper
// ============================================
class axi_cov_wrapper extends uvm_subscriber #(axi_seq_item);

    axi2apb_coverage cov;

    `uvm_component_utils(axi_cov_wrapper)

    function new(string name = "axi_cov_wrapper", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(axi_seq_item tr);
        cov.write(tr);
    endfunction

endclass


// ============================================
// APB Coverage Wrapper
// ============================================
class apb_cov_wrapper extends uvm_subscriber #(apb_seq_item);

    axi2apb_coverage cov;

    `uvm_component_utils(apb_cov_wrapper)

    function new(string name = "apb_cov_wrapper", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(apb_seq_item tr);
        cov.sample_apb(tr);
    endfunction

endclass
