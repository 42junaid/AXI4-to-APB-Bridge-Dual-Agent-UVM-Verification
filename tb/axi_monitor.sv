// ============================================
// axi_monitor.sv
// Captures AXI transactions from signals
// ============================================

class axi_monitor extends uvm_monitor;

    virtual AXI_BUS vif;
    uvm_analysis_port #(axi_seq_item) ap;

    `uvm_component_utils(axi_monitor)

    function new(string name = "axi_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
        `uvm_info("AXI_MONITOR", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI_MONITOR", "BUILD PHASE running", UVM_LOW)

        if (!uvm_config_db #(virtual AXI_BUS)::get(this, "", "axi_vif", vif))
            `uvm_fatal("AXI_MONITOR", "axi_vif not found!")
        else
            `uvm_info("AXI_MONITOR", "axi_vif successfully received!", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AXI_MONITOR", "CONNECT PHASE running", UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("AXI_MONITOR", "RUN PHASE running", UVM_LOW)

        fork
            monitor_write_channel();
            monitor_read_channel();
        join
    endtask

    // ----------------------------------------
    // WRITE CHANNEL MONITOR
    // AW ? W ? B (in order)
    // ----------------------------------------
    task monitor_write_channel();
        axi_seq_item tr;

        forever begin
            tr = axi_seq_item::type_id::create("wr_tr");
            tr.is_read = 1'b0;

            // ---- Step 1: Capture AW ----
            @(posedge vif.ACLK);
            while (!(vif.aw_valid && vif.aw_ready)) @(posedge vif.ACLK);
            tr.AWID   = vif.aw_id;
            tr.AWADDR = vif.aw_addr;
            tr.AWLEN  = vif.aw_len;
            tr.AWSIZE = vif.aw_size;
            tr.AWBURST = vif.aw_burst;
            `uvm_info("AXI_MONITOR", $sformatf("[WRITE-MON] AW captured: AWID=0x%h, AWADDR=0x%h",
                                                vif.aw_id, vif.aw_addr), UVM_LOW)

            // ---- Step 2: Capture W ----
            @(posedge vif.ACLK);
            while (!(vif.w_valid && vif.w_ready)) @(posedge vif.ACLK);
            tr.WDATA = vif.w_data;
            tr.WSTRB = vif.w_strb;
            tr.WLAST = vif.w_last;
            `uvm_info("AXI_MONITOR", $sformatf("[WRITE-MON] W captured: WDATA=0x%h",
                                                vif.w_data), UVM_LOW)

            // ---- Step 3: Capture B ----
            @(posedge vif.ACLK);
            while (!(vif.b_valid && vif.b_ready)) @(posedge vif.ACLK);
            tr.BID   = vif.b_id;
            tr.BRESP = vif.b_resp;
            tr.BUSER = vif.b_user;
            `uvm_info("AXI_MONITOR", $sformatf("[WRITE-MON] B captured: BID=0x%h, BRESP=0x%h",
                                                vif.b_id, vif.b_resp), UVM_LOW)

            // ---- Send to Scoreboard ----
            ap.write(tr);
            `uvm_info("AXI_MONITOR", "[WRITE-MON] Write transaction sent to scoreboard", UVM_LOW)
        end
    endtask

    // ----------------------------------------
    // READ CHANNEL MONITOR
    // AR ? R (in order)
    // ----------------------------------------
    task monitor_read_channel();
        axi_seq_item tr;

        forever begin
            tr = axi_seq_item::type_id::create("rd_tr");
            tr.is_read = 1'b1;

            // ---- Step 1: Capture AR ----
            @(posedge vif.ACLK);
            while (!(vif.ar_valid && vif.ar_ready)) @(posedge vif.ACLK);
            tr.ARID    = vif.ar_id;
            tr.ARADDR  = vif.ar_addr;
            tr.ARLEN   = vif.ar_len;
            tr.ARSIZE  = vif.ar_size;
            tr.ARBURST = vif.ar_burst;
            `uvm_info("AXI_MONITOR", $sformatf("[READ-MON] AR captured: ARID=0x%h, ARADDR=0x%h",
                                                vif.ar_id, vif.ar_addr), UVM_LOW)

            // ---- Step 2: Capture R ----
            @(posedge vif.ACLK);
            while (!(vif.r_valid && vif.r_ready)) @(posedge vif.ACLK);
            tr.RID   = vif.r_id;
            tr.RDATA = vif.r_data;
            tr.RRESP = vif.r_resp;
            tr.RLAST = vif.r_last;
            tr.RUSER = vif.r_user;
            `uvm_info("AXI_MONITOR", $sformatf("[READ-MON] R captured: RID=0x%h, RDATA=0x%h, RLAST=%0d",
                                                vif.r_id, vif.r_data, vif.r_last), UVM_LOW)

            // ---- Send to Scoreboard ----
            ap.write(tr);
            `uvm_info("AXI_MONITOR", "[READ-MON] Read transaction sent to scoreboard", UVM_LOW)
        end
    endtask

endclass
