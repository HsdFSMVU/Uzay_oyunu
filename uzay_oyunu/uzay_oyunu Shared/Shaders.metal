// Shaders.metal
#include <metal_stdlib>
using namespace metal;

// 1. Basit Toplama Kernel'i
kernel void simpleAddition(device float *numbers [[buffer(0)]],
                           device float *result  [[buffer(1)]],
                           uint id [[thread_position_in_grid]]) {
    // numbers[0] ve numbers[1] toplayıp result[0]'a yaz
    result[0] = numbers[0] + numbers[1];
}

// (Mevcut updatePhysics fonksiyonun burada durabilir, silmene gerek yok)
