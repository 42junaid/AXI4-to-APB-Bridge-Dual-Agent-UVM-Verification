// ============================================
// axi2apb_seq.sv
// All Sequences
// ============================================

// ----------------------------------------
// Base Sequence
// ----------------------------------------
class axi2apb_base_seq extends uvm_sequence #(axi_seq_item);

    `uvm_object_utils(axi2apb_base_seq)

    function new(string name = "axi2apb_base_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("BASE_SEQ", "Base sequence body running", UVM_LOW)
    endtask

endclass


// ----------------------------------------
// Single Write Sequence
// ----------------------------------------
class axi_write_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi_write_seq)

    function new(string name = "axi_write_seq");
        super.new(name);
    endfunction

    task body();
        axi_seq_item tr;

        tr = axi_seq_item::type_id::create("wr_tr");
        start_item(tr);
        tr.is_read = 1'b0;
        if (!tr.randomize() with {
            AWADDR inside {32'h0000_0100};
            WDATA  == 32'hDEAD_BEEF;
        }) `uvm_error("WRITE_SEQ", "Randomization failed")
        finish_item(tr);

        `uvm_info("WRITE_SEQ", $sformatf("Write sequence sent: AWADDR=0x%h, WDATA=0x%h",
                                          tr.AWADDR, tr.WDATA), UVM_LOW)
    endtask

endclass


// ----------------------------------------
// Single Read Sequence
// ----------------------------------------
class axi_read_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi_read_seq)

    function new(string name = "axi_read_seq");
        super.new(name);
    endfunction

    task body();
        axi_seq_item tr;

        tr = axi_seq_item::type_id::create("rd_tr");
        start_item(tr);
        tr.is_read = 1'b1;
        if (!tr.randomize() with {
            ARADDR inside {32'h0000_0200};
        }) `uvm_error("READ_SEQ", "Randomization failed")
        finish_item(tr);

        `uvm_info("READ_SEQ", $sformatf("Read sequence sent: ARADDR=0x%h",
                                         tr.ARADDR), UVM_LOW)
    endtask

endclass


// ----------------------------------------
// Random Read/Write Sequence
// ----------------------------------------
class axi_random_seq extends axi2apb_base_seq;

    int num_transactions = 5;

    `uvm_object_utils(axi_random_seq)

    function new(string name = "axi_random_seq");
        super.new(name);
    endfunction

    task body();
        axi_seq_item tr;

        for (int i = 0; i < num_transactions; i++) begin
            tr = axi_seq_item::type_id::create($sformatf("rand_tr_%0d", i));
            start_item(tr);
            if (!tr.randomize()) `uvm_error("RAND_SEQ", "Randomization failed")
            finish_item(tr);

            `uvm_info("RAND_SEQ", $sformatf("Random transaction #%0d sent: is_read=%0d, ADDR=0x%h, DATA=0x%h",
                i+1, tr.is_read, tr.is_read ? tr.ARADDR : tr.AWADDR,
                tr.is_read ? 32'h0 : tr.WDATA), UVM_LOW)
        end
    endtask

endclass
