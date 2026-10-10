// ============================================
// axi_driver.sv
// AXI Driver with RREADY/BREADY delay support
// ============================================

class axi_driver extends uvm_driver #(axi_seq_item);

    virtual AXI_BUS vif;

    // Delay counters (configurable)
    int unsigned rready_delay = 0;
    int unsigned bready_delay = 0;

    `uvm_component_utils(axi_driver)

    function new(string name = "axi_driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AXI_DRIVER", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI_DRIVER", "BUILD PHASE running", UVM_LOW)

        if (!uvm_config_db #(virtual AXI_BUS)::get(this, "", "axi_vif", vif))
            `uvm_fatal("AXI_DRIVER", "axi_vif not found!")
        else
            `uvm_info("AXI_DRIVER", "axi_vif successfully received!", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AXI_DRIVER", "CONNECT PHASE running", UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("AXI_DRIVER", "RUN PHASE running", UVM_LOW)

        vif.aw_valid = 1'b0;
        vif.w_valid  = 1'b0;
        vif.ar_valid = 1'b0;
        vif.b_ready  = 1'b0;
        vif.r_ready  = 1'b0;

        wait (vif.ARESETn == 1'b1);
        @(posedge vif.ACLK);
        `uvm_info("AXI_DRIVER", "Reset released, ready to receive transactions", UVM_LOW)

        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("AXI_DRIVER", $sformatf("Got transaction from sequence: is_read=%0d",
                                               req.is_read), UVM_LOW)

            if (req.is_read == 1'b0)
                do_write_transaction(req);
            else
                do_read_transaction(req);

            seq_item_port.item_done();
            `uvm_info("AXI_DRIVER", "Transaction done, sent item_done()", UVM_LOW)
        end
    endtask

    // ----------------------------------------
    // WRITE TRANSACTION
    // ----------------------------------------
    task do_write_transaction(axi_seq_item tr);

        // ---- AW Channel ----
        @(posedge vif.ACLK);
        vif.aw_id     = tr.AWID;
        vif.aw_addr   = tr.AWADDR;
        vif.aw_len    = tr.AWLEN;
        vif.aw_size   = tr.AWSIZE;
        vif.aw_burst  = tr.AWBURST;
        vif.aw_lock   = 1'b0;
        vif.aw_cache  = 4'h0;
        vif.aw_prot   = 3'h0;
        vif.aw_region = 4'h0;
        vif.aw_user   = tr.AWUSER;
        vif.aw_qos    = 4'h0;
        vif.aw_valid  = 1'b1;

        `uvm_info("AXI_DRIVER", $sformatf("[WRITE] AW: AWVALID=1, AWADDR=0x%h", tr.AWADDR), UVM_LOW)
        wait (vif.aw_ready == 1'b1);
        @(posedge vif.ACLK);
        vif.aw_valid = 1'b0;

        // ---- W Channel ----
        @(posedge vif.ACLK);
        vif.w_data   = tr.WDATA;
        vif.w_strb   = tr.WSTRB;
        vif.w_last   = tr.WLAST;
        vif.w_user   = tr.WUSER;
        vif.w_valid  = 1'b1;

        `uvm_info("AXI_DRIVER", $sformatf("[WRITE] W: WVALID=1, WDATA=0x%h", tr.WDATA), UVM_LOW)
        wait (vif.w_ready == 1'b1);
        @(posedge vif.ACLK);
        vif.w_valid = 1'b0;

        // ---- B Channel (with configurable delay) ----
        if (bready_delay > 0) begin
            `uvm_info("AXI_DRIVER", $sformatf("[WRITE] B: Delaying BREADY by %0d cycles", bready_delay), UVM_LOW)
            repeat (bready_delay) @(posedge vif.ACLK);
        end

        @(posedge vif.ACLK);
        vif.b_ready = 1'b1;
        wait (vif.b_valid == 1'b1);
        tr.BID   = vif.b_id;
        tr.BRESP = vif.b_resp;
        tr.BUSER = vif.b_user;
        `uvm_info("AXI_DRIVER", $sformatf("[WRITE] B: BID=0x%h, BRESP=0x%h", tr.BID, tr.BRESP), UVM_LOW)
        @(posedge vif.ACLK);
        vif.b_ready = 1'b0;
        `uvm_info("AXI_DRIVER", "[WRITE] COMPLETE!", UVM_LOW)
    endtask

    // ----------------------------------------
    // READ TRANSACTION
    // ----------------------------------------
    task do_read_transaction(axi_seq_item tr);

        // ---- AR Channel ----
        @(posedge vif.ACLK);
        vif.ar_id     = tr.ARID;
        vif.ar_addr   = tr.ARADDR;
        vif.ar_len    = tr.ARLEN;
        vif.ar_size   = tr.ARSIZE;
        vif.ar_burst  = tr.ARBURST;
        vif.ar_lock   = 1'b0;
        vif.ar_cache  = 4'h0;
        vif.ar_prot   = 3'h0;
        vif.ar_region = 4'h0;
        vif.ar_user   = tr.ARUSER;
        vif.ar_qos    = 4'h0;
        vif.ar_valid  = 1'b1;

        `uvm_info("AXI_DRIVER", $sformatf("[READ] AR: ARVALID=1, ARADDR=0x%h", tr.ARADDR), UVM_LOW)
        wait (vif.ar_ready == 1'b1);
        @(posedge vif.ACLK);
        vif.ar_valid = 1'b0;

        // ---- R Channel (with configurable delay) ----
        if (rready_delay > 0) begin
            `uvm_info("AXI_DRIVER", $sformatf("[READ] R: Delaying RREADY by %0d cycles", rready_delay), UVM_LOW)
            repeat (rready_delay) @(posedge vif.ACLK);
        end

        @(posedge vif.ACLK);
        vif.r_ready = 1'b1;
        wait (vif.r_valid == 1'b1);
        tr.RID   = vif.r_id;
        tr.RDATA = vif.r_data;
        tr.RRESP = vif.r_resp;
        tr.RLAST = vif.r_last;
        tr.RUSER = vif.r_user;
        `uvm_info("AXI_DRIVER", $sformatf("[READ] R: RID=0x%h, RDATA=0x%h, RLAST=%0d",
                                           tr.RID, tr.RDATA, tr.RLAST), UVM_LOW)
        @(posedge vif.ACLK);
        vif.r_ready = 1'b0;
        `uvm_info("AXI_DRIVER", "[READ] COMPLETE!", UVM_LOW)
    endtask

endclass
