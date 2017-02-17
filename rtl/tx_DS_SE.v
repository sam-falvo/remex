`timescale 1ns / 1ps

// This module implements the transmitter PHY for an IEEE-1355 link.
// The TxClk signal determines the actual transmission rate: one bit
// per rising edge of TxClk.
//
// The input-side of this module consists mainly of three signals:
//
// TxReset - if asserted, it forces D and S outputs 0.
// Tx1 - If asserted, it flips D and S outputs so as to reproduce
//       a binary 1 at the receiver.
// Tx0 - If asserted, it flips D and S outputs so as to reproduce
//       a binary 0 at the receiver.
//
// Under normal conditions, either Tx0 or Tx1 should be asserted;
// never both at the same time.  Negating both Tx0 and Tx1 is
// useful for link reset situations, where the transmitter is
// attempting to emulate a disconnect condition.

module tx_DS_SE(
    input           TxClk,
    input           TxReset,
    input           Tx1,
    input           Tx0,
    output          D,
    output          S
);
    reg D, S;

    wire nextD = Tx1;
    wire nextS = (Tx0 & ~(D^S)) | (Tx1 & (D^S));

    always @(posedge TxClk) begin
        D <= D;
        S <= S;

        if(TxReset) begin
            {D, S} <= 2'b00;
        end
        else if(Tx0 | Tx1) begin
            {D, S} <= {nextD, nextS};
        end
    end
endmodule

