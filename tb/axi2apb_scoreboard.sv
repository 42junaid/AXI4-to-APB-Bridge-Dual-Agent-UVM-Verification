// ============================================
// axi2apb_scoreboard.sv
// Actual comparison between AXI and APB (FIXED)
// ============================================

class axi2apb_scoreboard extends uvm_scoreboard;

    axi_seq_item axi_wr_queue[$];
    axi_seq_item axi_rd_queue[$];
    apb_seq_item apb_wr_queue[$];
    apb_seq_item apb_rd_queue[$];

    int axi_wr_count;
    int axi_rd_count;
    int apb_wr_count;
    int apb_rd_count;
    int match_count;
    int mismatch_count;

    `uvm_component_utils(axi2apb_scoreboard)

    function new(string name = "axi2apb_scoreboard", uvm_component parent);
        super.new(name, parent);
        axi_wr_count   = 0;
        axi_rd_count   = 0;
        apb_wr_count   = 0;
        apb_rd_count   = 0;
        match_count    = 0;
        mismatch_count = 0;
        `uvm_info("SCOREBOARD", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SCOREBOARD", "BUILD PHASE running", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SCOREBOARD", "CONNECT PHASE running", UVM_LOW)
    endfunction

    // ========================================
    // AXI TRANSACTION
    // ========================================
    function void write_axi(axi_seq_item tr);
        if (tr.is_read == 1'b0) begin
            // ---------- AXI WRITE ----------
            axi_wr_count++;
            `uvm_info("SCOREBOARD", $sformatf("[AXI-WR #%0d] AWADDR=0x%h, WDATA=0x%h, BID=0x%h",
                axi_wr_count, tr.AWADDR, tr.WDATA, tr.BID), UVM_LOW)

            axi_wr_queue.push_back(tr);
            `uvm_info("SCOREBOARD_DBG", $sformatf("After AXI-WR push: axi_wr_queue.size=%0d, apb_wr_queue.size=%0d",
                      axi_wr_queue.size(), apb_wr_queue.size()), UVM_LOW)

            if (apb_wr_queue.size() > 0) begin
                apb_seq_item apb_tr;
                apb_tr = apb_wr_queue[0];
                apb_wr_queue.pop_front();
                axi_wr_queue.pop_back();     // ? FIX: AXI queue se pop
                `uvm_info("SCOREBOARD_DBG", $sformatf("Popped APB-WR + AXI-WR. axi_wr_queue.size=%0d, apb_wr_queue.size=%0d",
                          axi_wr_queue.size(), apb_wr_queue.size()), UVM_LOW)
                compare_write(tr, apb_tr);
            end else begin
                `uvm_info("SCOREBOARD_DBG", "APB-WR queue empty, waiting...", UVM_LOW)
            end
        end else begin
            // ---------- AXI READ ----------
            axi_rd_count++;
            `uvm_info("SCOREBOARD", $sformatf("[AXI-RD #%0d] ARADDR=0x%h, RDATA=0x%h, RID=0x%h, RLAST=%0d",
                axi_rd_count, tr.ARADDR, tr.RDATA, tr.RID, tr.RLAST), UVM_LOW)

            axi_rd_queue.push_back(tr);
            `uvm_info("SCOREBOARD_DBG", $sformatf("After AXI-RD push: axi_rd_queue.size=%0d, apb_rd_queue.size=%0d",
                      axi_rd_queue.size(), apb_rd_queue.size()), UVM_LOW)

            if (apb_rd_queue.size() > 0) begin
                apb_seq_item apb_tr;
                apb_tr = apb_rd_queue[0];
                apb_rd_queue.pop_front();
                axi_rd_queue.pop_back();     // ? FIX: AXI queue se pop
                `uvm_info("SCOREBOARD_DBG", $sformatf("Popped APB-RD + AXI-RD. axi_rd_queue.size=%0d, apb_rd_queue.size=%0d",
                          axi_rd_queue.size(), apb_rd_queue.size()), UVM_LOW)
                compare_read(tr, apb_tr);
            end else begin
                `uvm_info("SCOREBOARD_DBG", "APB-RD queue empty, waiting...", UVM_LOW)
            end
        end
    endfunction

    // ========================================
    // APB TRANSACTION
    // ========================================
    function void write_apb(apb_seq_item tr);
        if (tr.PWRITE == 1'b1) begin
            // ---------- APB WRITE ----------
            apb_wr_count++;
            `uvm_info("SCOREBOARD", $sformatf("[APB-WR #%0d] PADDR=0x%h, PWDATA=0x%h",
                apb_wr_count, tr.PADDR, tr.PWDATA), UVM_LOW)

            apb_wr_queue.push_back(tr);
            `uvm_info("SCOREBOARD_DBG", $sformatf("After APB-WR push: axi_wr_queue.size=%0d, apb_wr_queue.size=%0d",
                      axi_wr_queue.size(), apb_wr_queue.size()), UVM_LOW)

            if (axi_wr_queue.size() > 0) begin
                axi_seq_item axi_tr;
                axi_tr = axi_wr_queue[0];
                axi_wr_queue.pop_front();
                apb_wr_queue.pop_back();     // ? FIX: APB queue se pop
                `uvm_info("SCOREBOARD_DBG", $sformatf("Popped AXI-WR + APB-WR. axi_wr_queue.size=%0d, apb_wr_queue.size=%0d",
                          axi_wr_queue.size(), apb_wr_queue.size()), UVM_LOW)
                compare_write(axi_tr, tr);
            end else begin
                `uvm_info("SCOREBOARD_DBG", "AXI-WR queue empty, waiting...", UVM_LOW)
            end
        end else begin
            // ---------- APB READ ----------
            apb_rd_count++;
            `uvm_info("SCOREBOARD", $sformatf("[APB-RD #%0d] PADDR=0x%h, PRDATA=0x%h",
                apb_rd_count, tr.PADDR, tr.PRDATA), UVM_LOW)

            apb_rd_queue.push_back(tr);
            `uvm_info("SCOREBOARD_DBG", $sformatf("After APB-RD push: axi_rd_queue.size=%0d, apb_rd_queue.size=%0d",
                      axi_rd_queue.size(), apb_rd_queue.size()), UVM_LOW)

            if (axi_rd_queue.size() > 0) begin
                axi_seq_item axi_tr;
                axi_tr = axi_rd_queue[0];
                axi_rd_queue.pop_front();
                apb_rd_queue.pop_back();     // ? FIX: APB queue se pop
                `uvm_info("SCOREBOARD_DBG", $sformatf("Popped AXI-RD + APB-RD. axi_rd_queue.size=%0d, apb_rd_queue.size=%0d",
                          axi_rd_queue.size(), apb_rd_queue.size()), UVM_LOW)
                compare_read(axi_tr, tr);
            end else begin
                `uvm_info("SCOREBOARD_DBG", "AXI-RD queue empty, waiting...", UVM_LOW)
            end
        end
    endfunction

    // ========================================
    // COMPARE WRITE
    // ========================================
    function void compare_write(axi_seq_item axi_tr, apb_seq_item apb_tr);
        bit addr_match = (axi_tr.AWADDR == apb_tr.PADDR);
        bit data_match = (axi_tr.WDATA  == apb_tr.PWDATA);

        if (addr_match && data_match) begin
            match_count++;
            `uvm_info("SCOREBOARD", 
                $sformatf("*** WRITE MATCH #%0d *** AWADDR=0x%h == PADDR=0x%h, WDATA=0x%h == PWDATA=0x%h",
                    match_count, axi_tr.AWADDR, apb_tr.PADDR, axi_tr.WDATA, apb_tr.PWDATA), UVM_LOW)
        end else begin
            mismatch_count++;
            if (!addr_match)
                `uvm_error("SCOREBOARD", 
                    $sformatf("*** WRITE ADDR MISMATCH *** AXI AWADDR=0x%h != APB PADDR=0x%h",
                        axi_tr.AWADDR, apb_tr.PADDR))
            if (!data_match)
                `uvm_error("SCOREBOARD", 
                    $sformatf("*** WRITE DATA MISMATCH *** AXI WDATA=0x%h != APB PWDATA=0x%h",
                        axi_tr.WDATA, apb_tr.PWDATA))
        end
    endfunction

    // ========================================
    // COMPARE READ
    // ========================================
    function void compare_read(axi_seq_item axi_tr, apb_seq_item apb_tr);
        bit addr_match = (axi_tr.ARADDR == apb_tr.PADDR);
        bit data_match = (axi_tr.RDATA  == apb_tr.PRDATA);

        if (addr_match && data_match) begin
            match_count++;
            `uvm_info("SCOREBOARD", 
                $sformatf("*** READ MATCH #%0d *** ARADDR=0x%h == PADDR=0x%h, RDATA=0x%h == PRDATA=0x%h",
                    match_count, axi_tr.ARADDR, apb_tr.PADDR, axi_tr.RDATA, apb_tr.PRDATA), UVM_LOW)
        end else begin
            mismatch_count++;
            if (!addr_match)
                `uvm_error("SCOREBOARD", 
                    $sformatf("*** READ ADDR MISMATCH *** AXI ARADDR=0x%h != APB PADDR=0x%h",
                        axi_tr.ARADDR, apb_tr.PADDR))
            if (!data_match)
                `uvm_error("SCOREBOARD", 
                    $sformatf("*** READ DATA MISMATCH *** AXI RDATA=0x%h != APB PRDATA=0x%h",
                        axi_tr.RDATA, apb_tr.PRDATA))
        end
    endfunction

    // ========================================
    // REPORT PHASE
    // ========================================
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", "======================================", UVM_LOW)
        `uvm_info("SCOREBOARD", "         SCOREBOARD SUMMARY", UVM_LOW)
        `uvm_info("SCOREBOARD", "======================================", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("AXI Write Transactions : %0d", axi_wr_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("AXI Read  Transactions : %0d", axi_rd_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("APB Write Transactions : %0d", apb_wr_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("APB Read  Transactions : %0d", apb_rd_count), UVM_LOW)
        `uvm_info("SCOREBOARD", "--------------------------------------", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("MATCHES    : %0d", match_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("MISMATCHES : %0d", mismatch_count), UVM_LOW)

        `uvm_info("SCOREBOARD", "--------------------------------------", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("LEFT IN axi_wr_queue : %0d", axi_wr_queue.size()), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("LEFT IN axi_rd_queue : %0d", axi_rd_queue.size()), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("LEFT IN apb_wr_queue : %0d", apb_wr_queue.size()), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("LEFT IN apb_rd_queue : %0d", apb_rd_queue.size()), UVM_LOW)

        if (mismatch_count == 0 && match_count > 0)
            `uvm_info("SCOREBOARD", "RESULT: *** ALL TRANSACTIONS PASSED ***", UVM_LOW)
        else if (mismatch_count > 0)
            `uvm_error("SCOREBOARD", "RESULT: *** SOME TRANSACTIONS FAILED ***")
        else
            `uvm_warning("SCOREBOARD", "RESULT: No transactions captured")

        `uvm_info("SCOREBOARD", "======================================", UVM_LOW)
    endfunction

endclass


// ============================================
// AXI Scoreboard Wrapper
// ============================================
class axi_scb_wrapper extends uvm_subscriber #(axi_seq_item);

    axi2apb_scoreboard scb;

    `uvm_component_utils(axi_scb_wrapper)

    function new(string name = "axi_scb_wrapper", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(axi_seq_item tr);
        scb.write_axi(tr);
    endfunction

endclass


// ============================================
// APB Scoreboard Wrapper
// ============================================
class apb_scb_wrapper extends uvm_subscriber #(apb_seq_item);

    axi2apb_scoreboard scb;

    `uvm_component_utils(apb_scb_wrapper)

    function new(string name = "apb_scb_wrapper", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(apb_seq_item tr);
        scb.write_apb(tr);
    endfunction

endclass
