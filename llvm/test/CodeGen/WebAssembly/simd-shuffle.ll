; RUN: llc < %s -asm-verbose=false -verify-machineinstrs -disable-wasm-fallthrough-return-opt -wasm-disable-explicit-locals -wasm-keep-registers -mattr=+simd128,+relaxed-simd | FileCheck %s
; RUN: llc < %s -asm-verbose=false -verify-machineinstrs -disable-wasm-fallthrough-return-opt -wasm-disable-explicit-locals -wasm-keep-registers -mattr=+simd128,+relaxed-simd -fast-isel | FileCheck %s

; Test SIMD128 shuffle lowering.

target triple = "wasm32-unknown-unknown"

; CHECK-LABEL: shuffle_v16i8:
; NO-CHECK-NOT: i8x16
; CHECK-NEXT: .functype shuffle_v16i8 (v128, v128) -> (v128){{$}}
; CHECK-NEXT: i8x16.shuffle $push[[R:[0-9]+]]=, $0, $1,
; CHECK-SAME: 0, 1, 2, 3, 4, 5, 6, 7, 16, 17, 18, 19, 20, 21, 22, 23{{$}}
; CHECK-NEXT: return $pop[[R]]{{$}}
define <16 x i8> @shuffle_v16i8(<16 x i8> %x, <16 x i8> %y) {
  %res = shufflevector <16 x i8> %x, <16 x i8> %y, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  ret <16 x i8> %res
}

; CHECK-LABEL: shuffle_undef_v16i8:
; NO-CHECK-NOT: i8x16
; CHECK-NEXT: .functype shuffle_undef_v16i8 (v128, v128) -> (v128){{$}}
; CHECK-NEXT: i8x16.shuffle $push[[R:[0-9]+]]=, $0, $1,
; CHECK-SAME: 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25{{$}}
; CHECK-NEXT: return $pop[[R]]{{$}}
define <16 x i8> @shuffle_undef_v16i8(<16 x i8> %x, <16 x i8> %y) {
  %res = shufflevector <16 x i8> %x, <16 x i8> %y, <16 x i32> <
      i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef,
      i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef,
      i32 undef, i32 undef, i32 undef, i32 25>
  ret <16 x i8> %res
}
