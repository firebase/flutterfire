// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.ProviderInfo;
import android.database.Cursor;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class FlutterFirebaseMessagingInitProvider extends ContentProvider {
  @Override
  public void attachInfo(Context context, ProviderInfo info) {
    super.attachInfo(context, info);
  }

  @Override
  public boolean onCreate() {
    if (ContextHolder.getApplicationContext() == null) {
      Context context = getContext();
      if (context != null && context.getApplicationContext() != null) {
        context = context.getApplicationContext();
      }
      ContextHolder.setApplicationContext(context);
    }
    return false;
  }

  @Nullable
  @Override
  public Cursor query(
      @NonNull Uri uri,
      String[] projection,
      String selection,
      String[] selectionArgs,
      String sortOrder) {
    return null;
  }

  @Nullable
  @Override
  public String getType(@NonNull Uri uri) {
    return null;
  }

  @Nullable
  @Override
  public Uri insert(@NonNull Uri uri, ContentValues values) {
    return null;
  }

  @Override
  public int delete(@NonNull Uri uri, String selection, String[] selectionArgs) {
    return 0;
  }

  @Override
  public int update(
      @NonNull Uri uri, ContentValues values, String selection, String[] selectionArgs) {
    return 0;
  }
}
