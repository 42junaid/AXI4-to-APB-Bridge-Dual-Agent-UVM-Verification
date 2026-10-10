// ============================================
// apb_driver.sv
// APB Slave Driver with configurable wait states
// ============================================

class apb_driver extends uvm_driver #(apb_seq_item);

    virtual APB_BUS vif;

    // Wait states - configurable
    int unsigned wait_cycles = 0;   // Default: 0 (immediate PREADY)

    `uvm_component_utils(apb_driver)

    function new(string name = "apb_driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info("APB_DRIVER", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("APB_DRIVER", "BUILD PHASE running", UVM_LOW)

        if (!uvm_config_db #(virtual APB_BUS)::get(this, "", "apb_vif", vif))
            `uvm_fatal("APB_DRIVER", "apb_vif not found!")
        else
            `uvm_info("APB_DRIVER", "apb_vif successfully received!", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("APB_DRIVER", "CONNECT PHASE running", UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("APB_DRIVER", "RUN PHASE running", UVM_LOW)

        // Initialize APB signals
        vif.prdata  = 32'h0;
        vif.pready  = 1'b0;
        vif.pslverr = 1'b0;

        forever begin
            @(posedge vif.PCLK);

            if (vif.psel && vif.penable) begin
                if (vif.pwrite) begin
                    `uvm_info("APB_DRIVER", $sformatf("[APB-WRITE] PADDR=0x%h, PWDATA=0x%h",
                                                        vif.paddr, vif.pwdata), UVM_LOW)
                end else begin
                    `uvm_info("APB_DRIVER", $sformatf("[APB-READ] PADDR=0x%h",
                                                        vif.paddr), UVM_LOW)
                    vif.prdata = 32'hCAFE_BABE;
                end

                vif.pslverr = 1'b0;

                // ----------------------------------------
                // WAIT STATES (configurable)
                // ----------------------------------------
                if (wait_cycles > 0) begin
                    `uvm_info("APB_DRIVER", $sformatf("Inserting %0d wait cycles", wait_cycles), UVM_LOW)
                    repeat (wait_cycles) @(posedge vif.PCLK);
                end

                // Assert PREADY
                vif.pready = 1'b1;
                `uvm_info("APB_DRIVER", "PREADY=1 asserted", UVM_LOW)

                @(posedge vif.PCLK);
                vif.pready = 1'b0;
                `uvm_info("APB_DRIVER", "APB transfer completed", UVM_LOW)
            end
        end
    endtask

endclass
