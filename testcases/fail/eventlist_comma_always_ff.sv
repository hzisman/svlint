module M;
  always_ff @(posedge clk, posedge arst) q <= d;
endmodule
////////////////////////////////////////////////////////////////////////////////
module M;
  always_ff @(a
            , b
            , c
            ) q <= d;
endmodule
////////////////////////////////////////////////////////////////////////////////
module M;
  always_ff @(posedge a or posedge b, c, d or e) q <= d;
endmodule
