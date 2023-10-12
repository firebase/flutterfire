/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

// Wrapper for com.google.firebase.firestore.QuerySnapshot, since it does
// not have a public constructor at this time.

// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.flutter.plugins.firebase.firestore.streamhandler;

import static com.google.firebase.firestore.util.Preconditions.checkNotNull;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.MetadataChanges;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SnapshotMetadata;
import java.util.Iterator;
import java.util.List;

public class QuerySnapshotWrapper {
  private final QuerySnapshot querySnapshot;

  public QuerySnapshotWrapper(QuerySnapshot querySnapshot) {
    this.querySnapshot = checkNotNull(querySnapshot);
  }

  @NonNull
  public Query getQuery() {
    return querySnapshot.getQuery();
  }

  /** @return The metadata for this query snapshot. */
  @NonNull
  public SnapshotMetadata getMetadata() {
    return querySnapshot.getMetadata();
  }

  /**
   * Returns the list of documents that changed since the last snapshot. If it's the first snapshot
   * all documents will be in the list as added changes.
   *
   * <p>Documents with changes only to their metadata will not be included.
   *
   * @return The list of document changes since the last snapshot.
   */
  @NonNull
  public List<DocumentChange> getDocumentChanges() {
    return querySnapshot.getDocumentChanges();
  }

  /**
   * Returns the list of documents that changed since the last snapshot. If it's the first snapshot
   * all documents will be in the list as added changes.
   *
   * @param metadataChanges Indicates whether metadata-only changes (i.e. only {@code
   *     DocumentSnapshot.getMetadata()} changed) should be included.
   * @return The list of document changes since the last snapshot.
   */
  @NonNull
  public List<DocumentChange> getDocumentChanges(@NonNull MetadataChanges metadataChanges) {

    return querySnapshot.getDocumentChanges(metadataChanges);
  }

  /**
   * Returns the documents in this {@code QuerySnapshot} as a List in order of the query.
   *
   * @return The list of documents.
   */
  @NonNull
  public List<DocumentSnapshot> getDocuments() {

    return querySnapshot.getDocuments();
  }

  /** Returns true if there are no documents in the {@code QuerySnapshot}. */
  public boolean isEmpty() {
    return querySnapshot.isEmpty();
  }

  /** Returns the number of documents in the {@code QuerySnapshot}. */
  public int size() {
    return querySnapshot.size();
  }

  @NonNull
  public Iterator<QueryDocumentSnapshot> iterator() {
    return querySnapshot.iterator();
  }

  /**
   * Returns the contents of the documents in the {@code QuerySnapshot}, converted to the provided
   * class, as a list.
   *
   * @param clazz The POJO type used to convert the documents in the list.
   */
  @NonNull
  public <T> List<T> toObjects(@NonNull Class<T> clazz) {
    return querySnapshot.toObjects(clazz);
  }

  /**
   * Returns the contents of the documents in the {@code QuerySnapshot}, converted to the provided
   * class, as a list.
   *
   * @param clazz The POJO type used to convert the documents in the list.
   * @param serverTimestampBehavior Configures the behavior for server timestamps that have not yet
   *     been set to their final value.
   */
  @NonNull
  public <T> List<T> toObjects(
      @NonNull Class<T> clazz,
      @NonNull DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior) {

    return querySnapshot.toObjects(clazz, serverTimestampBehavior);
  }

  @Override
  public boolean equals(@Nullable Object obj) {
    return querySnapshot.equals(obj);
  }

  @Override
  public int hashCode() {
    return querySnapshot.hashCode();
  }
}
