// ============================================
// axi2apb_test.sv
// All Test Classes
// ============================================

// ============================================
// TEST 1: BASIC TEST (Purana - Write + Read + Random 5)
// ============================================
class axi2apb_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_test)

    function new(string name = "axi2apb_test", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TEST", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST", "BUILD PHASE running", UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("TEST", "========================================", UVM_LOW)
        `uvm_info("TEST", ">>> BASIC TEST: Write + Read + Random(5) <<<", UVM_LOW)
        `uvm_info("TEST", "========================================", UVM_LOW)

        phase.raise_objection(this);

        // ---- Write Sequence ----
        `uvm_info("TEST", "=== Starting Write Sequence ===", UVM_LOW)
        begin
            axi_write_seq wr_seq;
            wr_seq = axi_write_seq::type_id::create("wr_seq");
            wr_seq.start(env.axi_agt.sqr);
        end
        #200;

        // ---- Read Sequence ----
        `uvm_info("TEST", "=== Starting Read Sequence ===", UVM_LOW)
        begin
            axi_read_seq rd_seq;
            rd_seq = axi_read_seq::type_id::create("rd_seq");
            rd_seq.start(env.axi_agt.sqr);
        end
        #500;

        // ---- Random Sequence (5 transactions) ----
        `uvm_info("TEST", "=== Starting Random Sequence (5 transactions) ===", UVM_LOW)
        begin
            axi_random_seq rand_seq;
            rand_seq = axi_random_seq::type_id::create("rand_seq");
            rand_seq.num_transactions = 5;
            rand_seq.start(env.axi_agt.sqr);
        end

        #5000;
        phase.drop_objection(this);
        `uvm_info("TEST", "RUN PHASE complete", UVM_LOW)
    endtask

endclass


// ============================================
// TEST 2: Write with Wait States
// ============================================
class axi2apb_write_wait_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_write_wait_test)

    function new(string name = "axi2apb_write_wait_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("TEST", ">>> TEST: Write with 3 wait cycles <<<", UVM_LOW)
        phase.raise_objection(this);

        env.apb_agt.drv.wait_cycles = 3;

        begin
            axi_write_seq wr_seq;
            wr_seq = axi_write_seq::type_id::create("wr_seq");
            wr_seq.start(env.axi_agt.sqr);
        end

        #2000;
        env.apb_agt.drv.wait_cycles = 0;
        phase.drop_objection(this);
    endtask

endclass


// ============================================
// TEST 3: Read with Wait States
// ============================================
class axi2apb_read_wait_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_read_wait_test)

    function new(string name = "axi2apb_read_wait_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("TEST", ">>> TEST: Read with 3 wait cycles <<<", UVM_LOW)
        phase.raise_objection(this);

        env.apb_agt.drv.wait_cycles = 3;

        begin
            axi_read_seq rd_seq;
            rd_seq = axi_read_seq::type_id::create("rd_seq");
            rd_seq.start(env.axi_agt.sqr);
        end

        #2000;
        env.apb_agt.drv.wait_cycles = 0;
        phase.drop_objection(this);
    endtask

endclass


// ============================================
// TEST 4: Read with RREADY Delayed
// ============================================
class axi2apb_rready_delay_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_rready_delay_test)

    function new(string name = "axi2apb_rready_delay_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("TEST", ">>> TEST: Read with RREADY delayed 3 cycles <<<", UVM_LOW)
        phase.raise_objection(this);

        env.axi_agt.drv.rready_delay = 3;

        begin
            axi_read_seq rd_seq;
            rd_seq = axi_read_seq::type_id::create("rd_seq");
            rd_seq.start(env.axi_agt.sqr);
        end

        #2000;
        env.axi_agt.drv.rready_delay = 0;
        phase.drop_objection(this);
    endtask

endclass


// ============================================
// TEST 5: Write with BREADY Delayed
// ============================================
class axi2apb_bready_delay_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_bready_delay_test)

    function new(string name = "axi2apb_bready_delay_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("TEST", ">>> TEST: Write with BREADY delayed 3 cycles <<<", UVM_LOW)
        phase.raise_objection(this);

        env.axi_agt.drv.bready_delay = 3;

        begin
            axi_write_seq wr_seq;
            wr_seq = axi_write_seq::type_id::create("wr_seq");
            wr_seq.start(env.axi_agt.sqr);
        end

        #2000;
        env.axi_agt.drv.bready_delay = 0;
        phase.drop_objection(this);
    endtask

endclass


// ============================================
// ALL DIRECTED TEST - Saare directed tests ek saath
// ============================================
class axi2apb_all_directed_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_all_directed_test)

    function new(string name = "axi2apb_all_directed_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("TEST", "========================================", UVM_LOW)
        `uvm_info("TEST", ">>> ALL DIRECTED TESTS STARTING <<<", UVM_LOW)
        `uvm_info("TEST", "========================================", UVM_LOW)

        phase.raise_objection(this);

        // ---- Test 1: Write with Wait ----
        `uvm_info("TEST", "--- Directed Test 1: Write with Wait ---", UVM_LOW)
        env.apb_agt.drv.wait_cycles = 3;
        begin
            axi_write_seq wr_seq;
            wr_seq = axi_write_seq::type_id::create("wr_seq");
            wr_seq.start(env.axi_agt.sqr);
        end
        #500;
        env.apb_agt.drv.wait_cycles = 0;

        // ---- Test 2: Read with Wait ----
        `uvm_info("TEST", "--- Directed Test 2: Read with Wait ---", UVM_LOW)
        env.apb_agt.drv.wait_cycles = 3;
        begin
            axi_read_seq rd_seq;
            rd_seq = axi_read_seq::type_id::create("rd_seq");
            rd_seq.start(env.axi_agt.sqr);
        end
        #500;
        env.apb_agt.drv.wait_cycles = 0;

        // ---- Test 3: RREADY Delayed ----
        `uvm_info("TEST", "--- Directed Test 3: RREADY Delayed ---", UVM_LOW)
        env.axi_agt.drv.rready_delay = 3;
        begin
            axi_read_seq rd_seq;
            rd_seq = axi_read_seq::type_id::create("rd_seq");
            rd_seq.start(env.axi_agt.sqr);
        end
        #500;
        env.axi_agt.drv.rready_delay = 0;

        // ---- Test 4: BREADY Delayed ----
        `uvm_info("TEST", "--- Directed Test 4: BREADY Delayed ---", UVM_LOW)
        env.axi_agt.drv.bready_delay = 3;
        begin
            axi_write_seq wr_seq;
            wr_seq = axi_write_seq::type_id::create("wr_seq");
            wr_seq.start(env.axi_agt.sqr);
        end
        #500;
        env.axi_agt.drv.bready_delay = 0;

        `uvm_info("TEST", "========================================", UVM_LOW)
        `uvm_info("TEST", ">>> ALL DIRECTED TESTS COMPLETE <<<", UVM_LOW)
        `uvm_info("TEST", "========================================", UVM_LOW)

        #2000;
        phase.drop_objection(this);
    endtask

endclass
