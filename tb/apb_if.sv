// ============================================
// apb_if.sv
// Interface: APB_BUS (PULP compatible)
// ============================================

interface APB_BUS #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic PCLK,
    input logic PRESETn
);

    logic                    psel;
    logic                    penable;
    logic                    pwrite;
    logic [ADDR_WIDTH-1:0]   paddr;
    logic [DATA_WIDTH-1:0]   pwdata;
    logic [DATA_WIDTH-1:0]   prdata;
    logic                    pready;
    logic                    pslverr;

    // Modport: Master (DUT use karega)
    modport Master (
        input  PCLK, PRESETn,
        output psel, penable, pwrite, paddr, pwdata,
        input  prdata, pready, pslverr
    );

    // Modport: Slave (Agent use karega)
    modport Slave (
        input  PCLK, PRESETn,
        input  psel, penable, pwrite, paddr, pwdata,
        output prdata, pready, pslverr
    );

endinterface
