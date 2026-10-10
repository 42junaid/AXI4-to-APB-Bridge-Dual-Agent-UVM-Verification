// ============================================
// axi2apb_base_test.sv
// ============================================

class axi2apb_base_test extends uvm_test;

    axi2apb_env env;

    `uvm_component_utils(axi2apb_base_test)

    function new(string name = "axi2apb_base_test", uvm_component parent);
        super.new(name, parent);
        `uvm_info("BASE_TEST", "Class created", UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("BASE_TEST", "BUILD PHASE running", UVM_LOW)

        env = axi2apb_env::type_id::create("env", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("BASE_TEST", "CONNECT PHASE running", UVM_LOW)
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("BASE_TEST", "END_OF_ELABORATION PHASE running", UVM_LOW)
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("BASE_TEST", "RUN PHASE running", UVM_LOW)
    endtask

endclass


