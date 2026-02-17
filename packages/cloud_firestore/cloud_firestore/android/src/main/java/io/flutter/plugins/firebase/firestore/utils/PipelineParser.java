/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Pipeline;
import com.google.firebase.firestore.Pipeline.Snapshot;
import com.google.firebase.firestore.PipelineSource;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class PipelineParser {
  private static final String TAG = "PipelineParser";
  private static final ExpressionParsers expressionParsers = new ExpressionParsers();
  private static final PipelineStageHandlers stageHandlers =
      new PipelineStageHandlers(expressionParsers);

  /**
   * Executes a pipeline from a list of stage maps.
   *
   * @param firestore The Firestore instance
   * @param stages List of stage maps, each with 'stage' and 'args' fields
   * @param options Optional execution options
   * @return The pipeline snapshot result
   */
  public static Snapshot executePipeline(
      @NonNull FirebaseFirestore firestore,
      @NonNull List<Map<String, Object>> stages,
      @Nullable Map<String, Object> options)
      throws Exception {
    if (stages == null || stages.isEmpty()) {
      throw new IllegalArgumentException("Pipeline must have at least one stage");
    }

    PipelineSource pipelineSource = firestore.pipeline();
    Pipeline pipeline = null;

    // Process each stage in order
    for (int i = 0; i < stages.size(); i++) {
      Map<String, Object> stageMap = stages.get(i);
      String stageName = (String) stageMap.get("stage");
      if (stageName == null) {
        throw new IllegalArgumentException("Stage must have a 'stage' field");
      }

      @SuppressWarnings("unchecked")
      Map<String, Object> args = (Map<String, Object>) stageMap.get("args");

      if (i == 0) {
        // First stage must be a source stage (collection, collection_group, documents, database)
        pipeline = applySourceStage(pipelineSource, stageName, args, firestore);
      } else {
        // Subsequent stages are methods on the Pipeline instance
        pipeline = stageHandlers.applyStage(pipeline, stageName, args, firestore);
      }
    }

    // Execute the pipeline
    Task<Snapshot> task = pipeline.execute();
    return Tasks.await(task);
  }

  /**
   * Applies a source stage (collection, collection_group, documents, database) to PipelineSource.
   * These are the only stages that can be the first stage and return a Pipeline instance.
   */
  @SuppressWarnings("unchecked")
  private static Pipeline applySourceStage(
      @NonNull PipelineSource pipelineSource,
      @NonNull String stageName,
      @Nullable Map<String, Object> args,
      @NonNull FirebaseFirestore firestore) {
    switch (stageName) {
      case "collection":
        {
          String path = (String) args.get("path");
          return pipelineSource.collection(path);
        }
      case "collection_group":
        {
          String path = (String) args.get("path");
          return pipelineSource.collectionGroup(path);
        }
      case "database":
        {
          return pipelineSource.database();
        }
      case "documents":
        {
          List<Map<String, Object>> docMaps = (List<Map<String, Object>>) args;
          List<DocumentReference> docRefs = new ArrayList<>();
          for (Map<String, Object> docMap : docMaps) {
            String docPath = (String) docMap.get("path");
            docRefs.add(firestore.document(docPath));
          }
          return pipelineSource.documents(docRefs.toArray(new DocumentReference[0]));
        }
      default:
        throw new IllegalArgumentException(
            "First stage must be one of: collection, collection_group, documents, database. Got: "
                + stageName);
    }
  }
}
