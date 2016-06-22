#
# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

simpleperf_common_cppflags := -Wextra -Wunused -Wno-unknown-pragmas

simpleperf_cppflags_target := $(simpleperf_common_cppflags)

simpleperf_cppflags_host := $(simpleperf_common_cppflags) \
                            -DUSE_BIONIC_UAPI_HEADERS -I bionic/libc/kernel \

simpleperf_cppflags_host_darwin := -I $(LOCAL_PATH)/nonlinux_support/include
simpleperf_cppflags_host_windows := -I $(LOCAL_PATH)/nonlinux_support/include


LLVM_ROOT_PATH := external/llvm
include $(LLVM_ROOT_PATH)/llvm.mk

simpleperf_static_libraries_target := \
  libbacktrace_offline \
  libbacktrace \
  libunwind \
  libziparchive \
  libz \
  libbase \
  libcutils \
  liblog \
  libutils \
  liblzma \
  libLLVMObject \
  libLLVMBitReader \
  libLLVMMC \
  libLLVMMCParser \
  libLLVMCore \
  libLLVMSupport \
  libprotobuf-cpp-lite \
  libc \

simpleperf_static_libraries_host := \
  libziparchive-host \
  libbase \
  liblog \
  liblzma \
  libz \
  libutils \
  libLLVMObject \
  libLLVMBitReader \
  libLLVMMC \
  libLLVMMCParser \
  libLLVMCore \
  libLLVMSupport \
  libprotobuf-cpp-lite \

simpleperf_static_libraries_host_linux := \
  libbacktrace_offline \
  libbacktrace \
  libunwind \
  libcutils \

simpleperf_ldlibs_host_linux := -lrt

# libsimpleperf
# =========================================================
libsimpleperf_src_files := \
  cmd_dumprecord.cpp \
  cmd_help.cpp \
  cmd_kmem.cpp \
  cmd_report.cpp \
  cmd_report_sample.cpp \
  command.cpp \
  dso.cpp \
  event_attr.cpp \
  event_type.cpp \
  perf_regs.cpp \
  read_apk.cpp \
  read_elf.cpp \
  record.cpp \
  record_file_reader.cpp \
  report_sample.proto \
  thread_tree.cpp \
  tracing.cpp \
  utils.cpp \

libsimpleperf_src_files_linux := \
  cmd_list.cpp \
  cmd_record.cpp \
  cmd_stat.cpp \
  dwarf_unwind.cpp \
  environment.cpp \
  event_fd.cpp \
  event_selection_set.cpp \
  record_file_writer.cpp \
  workload.cpp \

libsimpleperf_src_files_darwin := \
  nonlinux_support/nonlinux_support.cpp \

libsimpleperf_src_files_windows := \
  nonlinux_support/nonlinux_support.cpp \

# libsimpleperf target
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := libsimpleperf
LOCAL_MODULE_TAGS := debug
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)
LOCAL_CPPFLAGS := $(simpleperf_cppflags_target)
LOCAL_SRC_FILES := \
  $(libsimpleperf_src_files) \
  $(libsimpleperf_src_files_linux) \

LOCAL_STATIC_LIBRARIES := $(simpleperf_static_libraries_target)
LOCAL_MULTILIB := both
LOCAL_PROTOC_OPTIMIZE_TYPE := lite-static
include $(LLVM_DEVICE_BUILD_MK)
include $(BUILD_STATIC_LIBRARY)

# libsimpleperf host
include $(CLEAR_VARS)
#LOCAL_CLANG := true  # Comment it to build on windows.
LOCAL_MODULE := libsimpleperf
LOCAL_MODULE_HOST_OS := darwin linux windows
LOCAL_CPPFLAGS := $(simpleperf_cppflags_host)
LOCAL_CPPFLAGS_darwin := $(simpleperf_cppflags_host_darwin)
LOCAL_CPPFLAGS_linux := $(simpleperf_cppflags_host_linux)
LOCAL_CPPFLAGS_windows := $(simpleperf_cppflags_host_windows)
LOCAL_SRC_FILES := $(libsimpleperf_src_files)
LOCAL_SRC_FILES_darwin := $(libsimpleperf_src_files_darwin)
LOCAL_SRC_FILES_linux := $(libsimpleperf_src_files_linux)
LOCAL_SRC_FILES_windows := $(libsimpleperf_src_files_windows)
LOCAL_STATIC_LIBRARIES := $(simpleperf_static_libraries_host)
LOCAL_STATIC_LIBRARIES_linux := $(simpleperf_static_libraries_host_linux)
LOCAL_LDLIBS_linux := $(simpleperf_ldlibs_host_linux)
LOCAL_MULTILIB := first
LOCAL_PROTOC_OPTIMIZE_TYPE := lite-static
include $(LLVM_HOST_BUILD_MK)
include $(BUILD_HOST_STATIC_LIBRARY)


# simpleperf
# =========================================================

# simpleperf target
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := simpleperf
LOCAL_MODULE_TAGS := debug
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)
LOCAL_CPPFLAGS := $(simpleperf_cppflags_target)
LOCAL_SRC_FILES := main.cpp
LOCAL_STATIC_LIBRARIES := libsimpleperf $(simpleperf_static_libraries_target)
ifdef TARGET_2ND_ARCH
LOCAL_MULTILIB := both
LOCAL_MODULE_STEM_32 := simpleperf32
LOCAL_MODULE_STEM_64 := simpleperf
endif
LOCAL_FORCE_STATIC_EXECUTABLE := true
include $(LLVM_DEVICE_BUILD_MK)
include $(BUILD_EXECUTABLE)

$(call dist-for-goals,sdk,$(ALL_MODULES.simpleperf.BUILT))
ifdef TARGET_2ND_ARCH
$(call dist-for-goals,sdk,$(ALL_MODULES.simpleperf$(TARGET_2ND_ARCH_MODULE_SUFFIX).BUILT))
endif

# simpleperf host
include $(CLEAR_VARS)
LOCAL_MODULE := simpleperf
LOCAL_MODULE_HOST_OS := darwin linux windows
LOCAL_CPPFLAGS := $(simpleperf_cppflags_host)
LOCAL_CPPFLAGS_darwin := $(simpleperf_cppflags_host_darwin)
LOCAL_CPPFLAGS_linux := $(simpleperf_cppflags_host_linux)
LOCAL_CPPFLAGS_windows := $(simpleperf_cppflags_host_windows)
LOCAL_SRC_FILES := main.cpp
LOCAL_STATIC_LIBRARIES := libsimpleperf $(simpleperf_static_libraries_host)
LOCAL_STATIC_LIBRARIES_linux := $(simpleperf_static_libraries_host_linux)
LOCAL_LDLIBS_linux := $(simpleperf_ldlibs_host_linux)
LOCAL_MULTILIB := first
include $(LLVM_HOST_BUILD_MK)
include $(BUILD_HOST_EXECUTABLE)

$(call dist-for-goals,sdk,$(LOCAL_BUILT_MODULE):simpleperf_host)
$(call dist-for-goals,win_sdk,$(ALL_MODULES.host_cross_simpleperf.BUILT))

# simpleperf_unit_test
# =========================================================
simpleperf_unit_test_src_files := \
  cmd_kmem_test.cpp \
  cmd_report_test.cpp \
  cmd_report_sample_test.cpp \
  command_test.cpp \
  gtest_main.cpp \
  read_apk_test.cpp \
  read_elf_test.cpp \
  record_test.cpp \
  sample_tree_test.cpp \
  utils_test.cpp \

simpleperf_unit_test_src_files_linux := \
  cmd_dumprecord_test.cpp \
  cmd_list_test.cpp \
  cmd_record_test.cpp \
  cmd_stat_test.cpp \
  environment_test.cpp \
  record_file_test.cpp \
  workload_test.cpp \

# simpleperf_unit_test target
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := simpleperf_unit_test
LOCAL_CPPFLAGS := $(simpleperf_cppflags_target)
LOCAL_SRC_FILES := \
  $(simpleperf_unit_test_src_files) \
  $(simpleperf_unit_test_src_files_linux) \

LOCAL_STATIC_LIBRARIES += libsimpleperf $(simpleperf_static_libraries_target)
LOCAL_POST_LINK_CMD = \
  TMP_FILE=`mktemp $(OUT_DIR)/simpleperf-post-link-XXXXXXXXXX` && \
  (cd $(LOCAL_PATH)/testdata && zip - -0 -r .) > $$TMP_FILE && \
  $($(LOCAL_2ND_ARCH_VAR_PREFIX)TARGET_OBJCOPY) --add-section .testzipdata=$$TMP_FILE $(linked_module) && \
  rm -f $$TMP_FILE

LOCAL_MULTILIB := first
LOCAL_FORCE_STATIC_EXECUTABLE := true
include $(LLVM_DEVICE_BUILD_MK)
include $(BUILD_NATIVE_TEST)

# simpleperf_unit_test host
include $(CLEAR_VARS)
LOCAL_MODULE := simpleperf_unit_test
LOCAL_MODULE_HOST_OS := darwin linux windows
LOCAL_CPPFLAGS := $(simpleperf_cppflags_host)
LOCAL_CPPFLAGS_darwin := $(simpleperf_cppflags_host_darwin)
LOCAL_CPPFLAGS_linux := $(simpleperf_cppflags_host_linux)
LOCAL_CPPFLAGS_windows := $(simpleperf_cppflags_host_windows)
LOCAL_SRC_FILES := $(simpleperf_unit_test_src_files)
LOCAL_SRC_FILES_linux := $(simpleperf_unit_test_src_files_linux)
LOCAL_STATIC_LIBRARIES := libsimpleperf $(simpleperf_static_libraries_host)
LOCAL_STATIC_LIBRARIES_linux := $(simpleperf_static_libraries_host_linux)
LOCAL_LDLIBS_linux := $(simpleperf_ldlibs_host_linux)
LOCAL_MULTILIB := first
include $(LLVM_HOST_BUILD_MK)
include $(BUILD_HOST_NATIVE_TEST)


# simpleperf_cpu_hotplug_test
# =========================================================
simpleperf_cpu_hotplug_test_src_files := \
  cpu_hotplug_test.cpp \

# simpleperf_cpu_hotplug_test target
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := simpleperf_cpu_hotplug_test
LOCAL_CPPFLAGS := $(simpleperf_cppflags_target)
LOCAL_SRC_FILES := $(simpleperf_cpu_hotplug_test_src_files)
LOCAL_STATIC_LIBRARIES := libsimpleperf $(simpleperf_static_libraries_target)
LOCAL_MULTILIB := both
LOCAL_FORCE_STATIC_EXECUTABLE := true
include $(LLVM_DEVICE_BUILD_MK)
include $(BUILD_NATIVE_TEST)

# simpleperf_cpu_hotplug_test linux host
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := simpleperf_cpu_hotplug_test
LOCAL_MODULE_HOST_OS := linux
LOCAL_CPPFLAGS := $(simpleperf_cppflags_host)
LOCAL_CPPFLAGS_linux := $(simpleperf_cppflags_host_linux)
LOCAL_SRC_FILES := $(simpleperf_cpu_hotplug_test_src_files)
LOCAL_STATIC_LIBRARIES := libsimpleperf $(simpleperf_static_libraries_host)
LOCAL_STATIC_LIBRARIES_linux := $(simpleperf_static_libraries_host_linux)
LOCAL_LDLIBS_linux := $(simpleperf_ldlibs_host_linux)
LOCAL_MULTILIB := first
include $(LLVM_HOST_BUILD_MK)
include $(BUILD_HOST_NATIVE_TEST)


# libsimpleperf_cts_test
# =========================================================
libsimpleperf_cts_test_src_files := \
  $(libsimpleperf_src_files) \
  $(libsimpleperf_src_files_linux) \
  $(simpleperf_unit_test_src_files) \
  $(simpleperf_unit_test_src_files_linux) \

# libsimpleperf_cts_test target
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := libsimpleperf_cts_test
LOCAL_CPPFLAGS := $(simpleperf_cppflags_target)
LOCAL_SRC_FILES := $(libsimpleperf_cts_test_src_files)
LOCAL_STATIC_LIBRARIES := $(simpleperf_static_libraries_target)
LOCAL_MULTILIB := both
LOCAL_FORCE_STATIC_EXECUTABLE := true
include $(LLVM_DEVICE_BUILD_MK)
include $(BUILD_STATIC_TEST_LIBRARY)

# libsimpleperf_cts_test linux host
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := libsimpleperf_cts_test
LOCAL_MODULE_HOST_OS := linux
LOCAL_CPPFLAGS := $(simpleperf_cppflags_host)
LOCAL_CPPFLAGS_linux := $(simpleperf_cppflags_host_linux)
LOCAL_SRC_FILES := $(libsimpleperf_cts_test_src_files)
LOCAL_STATIC_LIBRARIES := $(simpleperf_static_libraries_host)
LOCAL_STATIC_LIBRARIES_linux := $(simpleperf_static_libraries_host_linux)
LOCAL_LDLIBS_linux := $(simpleperf_ldlibs_host_linux)
LOCAL_MULTILIB := both
include $(LLVM_HOST_BUILD_MK)
include $(BUILD_HOST_STATIC_TEST_LIBRARY)

include $(call first-makefiles-under,$(LOCAL_PATH))
