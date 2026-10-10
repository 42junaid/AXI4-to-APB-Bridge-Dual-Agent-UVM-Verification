// ============================================
// apb_monitor.sv
// Captures APB transactions from signals
// ============================================

class apb_monitor extends uvm_monitor;

    virtual APB_BUS vif;
    uvm_analysis_port #(apb_seq_item) ap;

    `uvm_component_utils(apb_monitor)

    function new(string name = "apb_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
        `uvm_info("APB_MONITOR", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("APB_MONITOR", "BUILD PHASE running", UVM_LOW)

        if (!uvm_config_db #(virtual APB_BUS)::get(this, "", "apb_vif", vif))
            `uvm_fatal("APB_MONITOR", "apb_vif not found!")
        else
            `uvm_info("APB_MONITOR", "apb_vif successfully received!", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("APB_MONITOR", "CONNECT PHASE running", UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("APB_MONITOR", "RUN PHASE running", UVM_LOW)

        forever begin
            @(posedge vif.PCLK);

            // Wait for complete APB transfer (PSEL + PENABLE + PREADY)
            if (vif.psel && vif.penable && vif.pready) begin
                apb_seq_item tr = apb_seq_item::type_id::create("apb_tr");

                tr.PADDR   = vif.paddr;
                tr.PWRITE  = vif.pwrite;
                tr.PWDATA  = vif.pwdata;
                tr.PRDATA  = vif.prdata;
                tr.PREADY  = vif.pready;
                tr.PSLVERR = vif.pslverr;

                if (vif.pwrite) begin
                    `uvm_info("APB_MONITOR", $sformatf("[APB-MON] WRITE captured: PADDR=0x%h, PWDATA=0x%h",
                                                        vif.paddr, vif.pwdata), UVM_LOW)
                end else begin
                    `uvm_info("APB_MONITOR", $sformatf("[APB-MON] READ captured: PADDR=0x%h, PRDATA=0x%h",
                                                        vif.paddr, vif.prdata), UVM_LOW)
                end

                // Send to analysis port
                ap.write(tr);
                `uvm_info("APB_MONITOR", "[APB-MON] Transaction sent to scoreboard", UVM_LOW)
            end
        end
    endtask

endclass
