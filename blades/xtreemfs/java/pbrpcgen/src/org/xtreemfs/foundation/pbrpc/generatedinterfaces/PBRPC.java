// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: PBRPC.proto

package org.xtreemfs.foundation.pbrpc.generatedinterfaces;

public final class PBRPC {
  private PBRPC() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
    registry.add(org.xtreemfs.foundation.pbrpc.generatedinterfaces.PBRPC.procId);
    registry.add(org.xtreemfs.foundation.pbrpc.generatedinterfaces.PBRPC.dataIn);
    registry.add(org.xtreemfs.foundation.pbrpc.generatedinterfaces.PBRPC.dataOut);
    registry.add(org.xtreemfs.foundation.pbrpc.generatedinterfaces.PBRPC.interfaceId);
  }
  public static final int PROC_ID_FIELD_NUMBER = 50001;
  /**
   * <code>extend .google.protobuf.MethodOptions { ... }</code>
   */
  public static final
    com.google.protobuf.GeneratedMessage.GeneratedExtension<
      com.google.protobuf.DescriptorProtos.MethodOptions,
      java.lang.Integer> procId = com.google.protobuf.GeneratedMessage
          .newFileScopedGeneratedExtension(
        java.lang.Integer.class,
        null);
  public static final int DATA_IN_FIELD_NUMBER = 50004;
  /**
   * <code>extend .google.protobuf.MethodOptions { ... }</code>
   */
  public static final
    com.google.protobuf.GeneratedMessage.GeneratedExtension<
      com.google.protobuf.DescriptorProtos.MethodOptions,
      java.lang.Boolean> dataIn = com.google.protobuf.GeneratedMessage
          .newFileScopedGeneratedExtension(
        java.lang.Boolean.class,
        null);
  public static final int DATA_OUT_FIELD_NUMBER = 50003;
  /**
   * <code>extend .google.protobuf.MethodOptions { ... }</code>
   */
  public static final
    com.google.protobuf.GeneratedMessage.GeneratedExtension<
      com.google.protobuf.DescriptorProtos.MethodOptions,
      java.lang.Boolean> dataOut = com.google.protobuf.GeneratedMessage
          .newFileScopedGeneratedExtension(
        java.lang.Boolean.class,
        null);
  public static final int INTERFACE_ID_FIELD_NUMBER = 50002;
  /**
   * <code>extend .google.protobuf.ServiceOptions { ... }</code>
   */
  public static final
    com.google.protobuf.GeneratedMessage.GeneratedExtension<
      com.google.protobuf.DescriptorProtos.ServiceOptions,
      java.lang.Integer> interfaceId = com.google.protobuf.GeneratedMessage
          .newFileScopedGeneratedExtension(
        java.lang.Integer.class,
        null);

  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\013PBRPC.proto\022\016xtreemfs.pbrpc\032 google/pr" +
      "otobuf/descriptor.proto:1\n\007proc_id\022\036.goo" +
      "gle.protobuf.MethodOptions\030\321\206\003 \001(\007:1\n\007da" +
      "ta_in\022\036.google.protobuf.MethodOptions\030\324\206" +
      "\003 \001(\010:2\n\010data_out\022\036.google.protobuf.Meth" +
      "odOptions\030\323\206\003 \001(\010:7\n\014interface_id\022\037.goog" +
      "le.protobuf.ServiceOptions\030\322\206\003 \001(\007B3\n1or" +
      "g.xtreemfs.foundation.pbrpc.generatedint" +
      "erfaces"
    };
    com.google.protobuf.Descriptors.FileDescriptor.InternalDescriptorAssigner assigner =
      new com.google.protobuf.Descriptors.FileDescriptor.InternalDescriptorAssigner() {
        public com.google.protobuf.ExtensionRegistry assignDescriptors(
            com.google.protobuf.Descriptors.FileDescriptor root) {
          descriptor = root;
          procId.internalInit(descriptor.getExtensions().get(0));
          dataIn.internalInit(descriptor.getExtensions().get(1));
          dataOut.internalInit(descriptor.getExtensions().get(2));
          interfaceId.internalInit(descriptor.getExtensions().get(3));
          return null;
        }
      };
    com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
          com.google.protobuf.DescriptorProtos.getDescriptor(),
        }, assigner);
  }

  // @@protoc_insertion_point(outer_class_scope)
}
