#!/bin/bash

# Copyright (C) 2015 The MoKee OpenSource Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This works, but there has to be a better way of reliably getting the root build directory...
if [ $# -eq 1 ]; then
    TOP=$1
    DEVICE=$MK_BUILD
elif [ -n "$(gettop)" ]; then
    TOP=$(gettop)
    DEVICE=$MK_BUILD
else
    echo "Please run envsetup.sh and lunch before running this script,"
    echo "or provide the build root directory as the first parameter."
    return 1
fi

TARGET_DIR=$OUT
PREBUILT_DIR=$TOP/prebuilts/chromium/$DEVICE

if [ -d $PREBUILT_DIR ]; then
    rm -rf $PREBUILT_DIR
fi

if [ $MK_CPU_ABI -eq "arm64-v8a" ]; then
    LIB_FILENAME=lib64
else
    LIB_FILENAME=lib
fi

mkdir -p $PREBUILT_DIR
mkdir -p $PREBUILT_DIR/$LIB_FILENAME


if [ -d $TARGET_DIR ]; then
    echo "Copying files..."
    cp -r $TARGET_DIR/system/app/webview $PREBUILT_DIR
    rm -r $PREBUILT_DIR/webview/$LIB_FILENAME
    cp $TARGET_DIR/system/$LIB_FILENAME/libwebviewchromium*.so $PREBUILT_DIR/$LIB_FILENAME
else
    echo "Please ensure that you have ran a full build prior to running this script!"
    exit 1;
fi

echo "Generating Makefiles..."

HASH1=$(git --git-dir=$TOP/external/chromium_org/.git --work-tree=$TOP/external/chromium_org rev-parse --verify HEAD)
HASH2=$(git --git-dir=$TOP/frameworks/webview/.git --work-tree=$TOP/frameworks/webview rev-parse --verify HEAD)
echo $HASH1 > $PREBUILT_DIR/hash_chromium.txt
echo $HASH2 > $PREBUILT_DIR/hash_webview.txt

cat > $PREBUILT_DIR/chromium_prebuilt.mk <<EOF
# Copyright (C) 2015 The MoKee OpenSource Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := prebuilts/chromium/$DEVICE

STUB := \$(shell mkdir -p out/target/product/$DEVICE/system/app/webview/$LIB_FILENAME/arm;ln -sf /system/$LIB_FILENAME/libwebviewchromium.so out/target/product/$DEVICE/system/app/webview/$LIB_FILENAME/arm/libwebviewchromium.so)

PRODUCT_COPY_FILES += \\
    \$(call find-copy-subdir-files,*,\$(LOCAL_PATH)/webview,system/app/webview) \\
    \$(call find-copy-subdir-files,*,\$(LOCAL_PATH)/$LIB_FILENAME,system/$LIB_FILENAME)

EOF

echo "Done!"
