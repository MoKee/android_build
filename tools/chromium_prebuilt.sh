#!/bin/bash

# Copyright (C) 2014 The MoKee OpenSource Project
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

mkdir -p $PREBUILT_DIR
mkdir -p $PREBUILT_DIR/lib

if [ -d $TARGET_DIR ]; then
    echo "Copying files..."
    cp -r $TARGET_DIR/system/app/webview $PREBUILT_DIR
    rm -r $PREBUILT_DIR/webview/lib
    cp $TARGET_DIR/system/lib/libwebviewchromium*.so $PREBUILT_DIR/lib
else
    echo "Please ensure that you have ran a full build prior to running this script!"
    exit 1;
fi

echo "Generating Makefiles..."

HASH=$(git --git-dir=$TOP/external/chromium_org/.git --work-tree=$TOP/external/chromium_org rev-parse --verify HEAD)
echo $HASH > $PREBUILT_DIR/hash.txt

cat > $PREBUILT_DIR/chromium_prebuilt.mk <<EOF
# Copyright (C) 2014 The MoKee OpenSource Project
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

STUB := \$(shell mkdir -p out/target/product/$DEVICE/system/app/webview/lib/arm;ln -sf /system/lib/libwebviewchromium.so out/target/product/$DEVICE/system/app/webview/lib/arm/libwebviewchromium.so)

PRODUCT_COPY_FILES += \\
    \$(call find-copy-subdir-files,*,\$(LOCAL_PATH)/webview,system/app/webview) \\
    \$(call find-copy-subdir-files,*,\$(LOCAL_PATH)/lib,system/lib)

EOF

echo "Done!"
