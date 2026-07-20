#!/usr/bin/env bash
# Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.
#
# Re-applies the mechanical patches required on the Pigeon (GObject) generated
# code for the Linux plugin implementations. Run after regenerating pigeons
# (invoked by `melos run generate:pigeon:linux`). Each transform is idempotent,
# so re-running on already-patched files is a no-op.
#
# Formatting (clang-format) of the generated files is handled by the existing
# `melos run format-ci` step in the `generate:pigeon` aggregate.
set -euo pipefail

cd "$(dirname "$0")/.."

# ---------------------------------------------------------------------------
# firebase_auth: `delete` is a C++ keyword, but the FirebaseAuthUserHostApi
# Dart method is named delete(), so pigeon emits a vtable member (and call
# sites) named `delete` that do not compile. Rename to `delete_`.
# ---------------------------------------------------------------------------
AUTH_LINUX=packages/firebase_auth/firebase_auth/linux
perl -i -pe 's/\(\*delete\)\(/(*delete_)(/' "$AUTH_LINUX/messages.g.h"
perl -i -pe 's/self->vtable->delete\b/self->vtable->delete_/g' "$AUTH_LINUX/messages.g.cc"

# ---------------------------------------------------------------------------
# firebase_core: same `delete` C++ keyword collision. The FirebaseAppHostApi
# Dart method delete() makes pigeon emit a vtable member (and call site)
# named `delete`. Rename to `delete_`.
# ---------------------------------------------------------------------------
CORE_LINUX=packages/firebase_core/firebase_core/linux
perl -i -pe 's/\(\*delete\)\(/(*delete_)(/' "$CORE_LINUX/messages.g.h"
perl -i -pe 's/self->vtable->delete\b/self->vtable->delete_/g' "$CORE_LINUX/messages.g.cc"

# ---------------------------------------------------------------------------
# firebase_storage: several host-API methods take an int64 parameter named
# `handle` (the task handle), which collides with the generated dispatch
# functions' local `g_autoptr(...) handle` response-handle variable. Rename
# the generated local to `response_handle_` in every dispatch function.
# ---------------------------------------------------------------------------
STORAGE_LINUX=packages/firebase_storage/firebase_storage/linux
perl -i -pe 's/HostApiResponseHandle\) handle = /HostApiResponseHandle) response_handle_ = /; s/, handle, self->user_data\);/, response_handle_, self->user_data);/' "$STORAGE_LINUX/messages.g.cc"

# ---------------------------------------------------------------------------
# cloud_firestore: the generated FlStandardMessageCodec subclass must delegate
# unknown custom types to the hand-written Firestore codec (mirroring how the
# Windows generated codec extends cloud_firestore_windows::FirestoreCodec),
# and cloud_firestore_message_codec_new() must be exposed so the plugin can
# attach the codec to Firestore event channels.
# ---------------------------------------------------------------------------
FIRESTORE_LINUX=packages/cloud_firestore/cloud_firestore/linux

perl -0777 -i -pe 's{(?<!#include "firestore_codec.h"\n)#include "messages.g.h"\n}{#include "firestore_codec.h"\n#include "messages.g.h"\n}' "$FIRESTORE_LINUX/messages.g.cc"

perl -0777 -i -pe 's{  return FL_STANDARD_MESSAGE_CODEC_CLASS\(cloud_firestore_message_codec_parent_class\)->write_value\(codec, buffer, value, error\);\n}{  // Modified from the generated fallback (which chains to the parent class):
  // delegate unknown types to the Firestore codec, mirroring how the Windows
  // generated codec extends cloud_firestore_windows::FirestoreCodec.
  return firestore_codec_write_value(codec, buffer, value, error);\n}' "$FIRESTORE_LINUX/messages.g.cc"

perl -0777 -i -pe 's{      return FL_STANDARD_MESSAGE_CODEC_CLASS\(cloud_firestore_message_codec_parent_class\)->read_value_of_type\(codec, buffer, offset, type, error\);\n}{      // Modified from the generated fallback (which chains to the parent
      // class): delegate unknown types to the Firestore codec, mirroring how
      // the Windows generated codec extends
      // cloud_firestore_windows::FirestoreCodec.
      return firestore_codec_read_value_of_type(codec, buffer, offset, type, error);\n}' "$FIRESTORE_LINUX/messages.g.cc"

perl -0777 -i -pe 's{static CloudFirestoreMessageCodec\* cloud_firestore_message_codec_new\(\) \{\n}{// Modified from the generated code: made non-static (and declared in
// messages.g.h) so the plugin can attach this codec to Firestore event
// channels, mirroring FirebaseFirestoreHostApiCodecSerializer::GetInstance()
// on Windows.
CloudFirestoreMessageCodec* cloud_firestore_message_codec_new() \{\n}' "$FIRESTORE_LINUX/messages.g.cc"

perl -0777 -i -pe 's{(G_DECLARE_FINAL_TYPE\(CloudFirestoreMessageCodec, cloud_firestore_message_codec, CLOUD_FIRESTORE, MESSAGE_CODEC, FlStandardMessageCodec\)\n\n)(?!/\*\*\n \* cloud_firestore_message_codec_new:)}{$1/**
 * cloud_firestore_message_codec_new:
 *
 * Creates a #CloudFirestoreMessageCodec.
 *
 * Modified from the generated code: exposed so the plugin can attach the
 * Pigeon-aware codec to Firestore event channels, mirroring
 * FirebaseFirestoreHostApiCodecSerializer::GetInstance() on Windows.
 *
 * Returns: a new #CloudFirestoreMessageCodec.
 */
CloudFirestoreMessageCodec* cloud_firestore_message_codec_new();

}' "$FIRESTORE_LINUX/messages.g.h"

echo "Linux pigeon post-processing complete."
