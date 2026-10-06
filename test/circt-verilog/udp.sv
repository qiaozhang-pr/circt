// RUN: circt-verilog %s | FileCheck %s
// REQUIRES: slang
// UNSUPPORTED: valgrind

// 2-to-1 multiplexer: out = (~sel & a) | (sel & b)
primitive udp_mux(out, sel, a, b);
  output out;
  input sel, a, b;
  table
    0  1  ? : 1 ;
    1  ?  1 : 1 ;
    0  0  ? : 0 ;
    1  ?  0 : 0 ;
  endtable
endprimitive

// CHECK-LABEL: hw.module @TestCombUdp(
module TestCombUdp(input logic sel, input logic a, input logic b, output logic out);
  // CHECK: [[NOT_SEL:%.+]] = comb.xor %sel, %true
  // CHECK: [[TERM1:%.+]] = comb.and [[NOT_SEL]], %a
  // CHECK: [[TERM2:%.+]] = comb.and %sel, %b
  // CHECK: [[OUT:%.+]] = comb.or [[TERM1]], [[TERM2]]
  // CHECK: hw.output [[OUT]]
  udp_mux u_mux (out, sel, a, b);
endmodule

// CHECK-LABEL: hw.module @TestCombUdpDelay(
module TestCombUdpDelay(input logic sel, input logic a, input logic b, output logic out);
  // CHECK: [[DELAYED:%.+]] = llhd.delay [[OUT:%.+]] by <5000000fs, 0d, 0e> : i1
  // CHECK: [[NOT_SEL:%.+]] = comb.xor %sel, %true
  // CHECK: [[TERM1:%.+]] = comb.and [[NOT_SEL]], %a
  // CHECK: [[TERM2:%.+]] = comb.and %sel, %b
  // CHECK: [[OUT]] = comb.or [[TERM1]], [[TERM2]]
  // CHECK: hw.output [[DELAYED]]
  udp_mux #5 u_mux_delay (out, sel, a, b);
endmodule

