// ============================================
// axi_if.sv
// Interface: AXI_BUS (PULP compatible)
// ============================================

interface AXI_BUS #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 16,
    parameter USER_WIDTH = 10
) (
    input logic ACLK,
    input logic ARESETn
);

    // AW Channel
    logic [ID_WIDTH-1:0]     aw_id;
    logic [ADDR_WIDTH-1:0]   aw_addr;
    logic [7:0]              aw_len;
    logic [2:0]              aw_size;
    logic [1:0]              aw_burst;
    logic                    aw_lock;
    logic [3:0]              aw_cache;
    logic [2:0]              aw_prot;
    logic [3:0]              aw_region;
    logic [USER_WIDTH-1:0]   aw_user;
    logic [3:0]              aw_qos;
    logic                    aw_valid;
    logic                    aw_ready;

    // W Channel
    logic [DATA_WIDTH-1:0]   w_data;
    logic [DATA_WIDTH/8-1:0] w_strb;
    logic                    w_last;
    logic [USER_WIDTH-1:0]   w_user;
    logic                    w_valid;
    logic                    w_ready;

    // B Channel
    logic [ID_WIDTH-1:0]     b_id;
    logic [1:0]              b_resp;
    logic                    b_valid;
    logic [USER_WIDTH-1:0]   b_user;
    logic                    b_ready;

    // AR Channel
    logic [ID_WIDTH-1:0]     ar_id;
    logic [ADDR_WIDTH-1:0]   ar_addr;
    logic [7:0]              ar_len;
    logic [2:0]              ar_size;
    logic [1:0]              ar_burst;
    logic                    ar_lock;
    logic [3:0]              ar_cache;
    logic [2:0]              ar_prot;
    logic [3:0]              ar_region;
    logic [USER_WIDTH-1:0]   ar_user;
    logic [3:0]              ar_qos;
    logic                    ar_valid;
    logic                    ar_ready;

    // R Channel
    logic [ID_WIDTH-1:0]     r_id;
    logic [DATA_WIDTH-1:0]   r_data;
    logic [1:0]              r_resp;
    logic                    r_last;
    logic [USER_WIDTH-1:0]   r_user;
    logic                    r_valid;
    logic                    r_ready;

    // Modport: Slave (DUT use karega)
    modport Slave (
        input  ACLK, ARESETn,
        input  aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock,
               aw_cache, aw_prot, aw_region, aw_user, aw_qos, aw_valid,
        output aw_ready,
        input  w_data, w_strb, w_last, w_user, w_valid,
        output w_ready,
        output b_id, b_resp, b_valid, b_user,
        input  b_ready,
        input  ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock,
               ar_cache, ar_prot, ar_region, ar_user, ar_qos, ar_valid,
        output ar_ready,
        output r_id, r_data, r_resp, r_last, r_user, r_valid,
        input  r_ready
    );

    // Modport: Master (Agent use karega)
    modport Master (
        input  ACLK, ARESETn,
        output aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock,
               aw_cache, aw_prot, aw_region, aw_user, aw_qos, aw_valid,
        input  aw_ready,
        output w_data, w_strb, w_last, w_user, w_valid,
        input  w_ready,
        input  b_id, b_resp, b_valid, b_user,
        output b_ready,
        output ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock,
               ar_cache, ar_prot, ar_region, ar_user, ar_qos, ar_valid,
        input  ar_ready,
        input  r_id, r_data, r_resp, r_last, r_user, r_valid,
        output r_ready
    );

endinterface
