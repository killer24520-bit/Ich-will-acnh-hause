`default_nettype none

module tt_um_vga_example(
    input wire [7:0] ui_in, // Dedizierte Eingänge
    output wire [7:0] uo_out, // Dedizierte Ausgänge
    input wire [7:0] uio_in, // IOs: Eingangs-Pfad
    output wire [7:0] uio_out, // IOs: Ausgangs-Pfad
    output wire [7:0] uio_oe, // IOs: Enable-Pfad (aktiv High: 0=Eingang, 1=Ausgang)
    input wire ena, // immer 1, solange das Design mit Strom versorgt ist - kann ignoriert werden
    input wire clk, // Takt
    input wire rst_n // reset_n - Low = Reset
);

    // VGA Signale
    wire hsync;
    wire vsync;
    wire [1:0] R;
    wire [1:0] G;
    wire [1:0] B;
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;

    // VGA-Output - Mapping des Signals zu VGA-Ausgängen
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // Ungenutzte Ausgänge werden auf 0 gesetzt
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Unterdrückung von Warnungen bezüglich ungenutzter Signale
    wire _unused_ok = &{ena, ui_in, uio_in};

    // VGA-Signalgenerator Modul zur Erzeugung der Sync-Signale und Positionierung der Pixel
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // Definition des Rechtecks:
    // Positioniere das Rechteck in der Mitte des Bildschirms von x=240 bis x=400 und y=160 bis y=320
    wire rect_active = (pix_x >= 240) && (pix_x < 400) && (pix_y >= 160) && (pix_y < 320);

    // Farbe Gelb (Kombination von Rot und Grün auf volle Helligkeit)
    // Wenn das Video aktiviert ist und wir im Rechteck sind, dann färben wir Gelb
    assign R = video_active && rect_active ? 2'b11 : 2'b00;
    assign G = video_active && rect_active ? 2'b11 : 2'b00;
    assign B = video_active && rect_active ? 2'b00 : 2'b00; 

endmodule
