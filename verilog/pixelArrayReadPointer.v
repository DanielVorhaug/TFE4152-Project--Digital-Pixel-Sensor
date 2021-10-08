module pixelArrayReadPointer (
    input logic [$clog2(HEIGHT)-1:0] CONTROL,
    input logic ENABLE,
    output logic [HEIGHT-1:0] ROW_SELECT
);

parameter integer HEIGHT = 2;

assign ROW_SELECT = ENABLE ? (1 << CONTROL) : '0;


endmodule