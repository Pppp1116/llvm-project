// RUN: %clang_cc1 -triple dxil--shadermodel6.6-compute -x hlsl -finclude-default-header \
// RUN:   -emit-llvm -disable-llvm-passes -o - %s | FileCheck %s

struct BufferWrapper {
  RWBuffer<float> Buf;

  void Store(float Value) {
    Buf[0] = Value;
  }
};

struct Outer {
  BufferWrapper Elements[2];
};

BufferWrapper One : register(u0);
BufferWrapper Two : register(u1);
Outer Nested : register(u2);

[numthreads(1, 1, 1)]
void main() {
  One.Store(1.0);
  Two.Store(2.0);
  Nested.Elements[1].Store(3.0);
}

// CHECK-LABEL: define void @main()
// CHECK: %[[ONE_FIELD:.*]] = getelementptr inbounds nuw %struct.BufferWrapper, ptr @One, i32 0, i32 0
// CHECK: store {{.*}}, ptr %[[ONE_FIELD]]
// CHECK: call void @{{.*Store.*}}(ptr noundef @One, float noundef 1.000000e+00)
// CHECK: %[[TWO_FIELD:.*]] = getelementptr inbounds nuw %struct.BufferWrapper, ptr @Two, i32 0, i32 0
// CHECK: store {{.*}}, ptr %[[TWO_FIELD]]
// CHECK: call void @{{.*Store.*}}(ptr noundef @Two, float noundef 2.000000e+00)
// CHECK: %[[NESTED_ELEM0_FIELD:.*]] = getelementptr inbounds nuw %struct.Outer, ptr @Nested, i32 0, i32 0, i64 0, i32 0
// CHECK: store {{.*}}, ptr %[[NESTED_ELEM0_FIELD]]
// CHECK: %[[NESTED_ELEM1_FIELD:.*]] = getelementptr inbounds nuw %struct.Outer, ptr @Nested, i32 0, i32 0, i64 1, i32 0
// CHECK: store {{.*}}, ptr %[[NESTED_ELEM1_FIELD]]
// CHECK: %[[NESTED_ELEM1:.*]] = getelementptr inbounds nuw %struct.Outer, ptr @Nested, i32 0, i32 0, i64 1
// CHECK: call void @{{.*Store.*}}(ptr noundef %[[NESTED_ELEM1]], float noundef 3.000000e+00)
