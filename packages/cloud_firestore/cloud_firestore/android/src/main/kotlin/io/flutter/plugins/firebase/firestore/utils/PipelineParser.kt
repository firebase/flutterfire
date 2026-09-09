/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils

import com.google.android.gms.tasks.Tasks
import com.google.firebase.firestore.DocumentReference
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Pipeline
import com.google.firebase.firestore.Pipeline.Snapshot
import com.google.firebase.firestore.PipelineSource

object PipelineParser {
  @Throws(Exception::class)
  fun executePipeline(
      firestore: FirebaseFirestore,
      stages: List<Map<String, Any>>,
      options: Map<String, Any>?
  ): Snapshot {
    val pipeline = buildPipeline(firestore, stages)
    val task =
        if (options != null && options.isNotEmpty()) {
          pipeline.execute(parseExecuteOptions(options))
        } else {
          pipeline.execute()
        }
    return Tasks.await(task)
  }

  private fun parseExecuteOptions(options: Map<String, Any>): Pipeline.ExecuteOptions {
    var executeOptions = Pipeline.ExecuteOptions()
    val indexModeObj = options["indexMode"]
    if (indexModeObj is String && indexModeObj.equals("recommended", ignoreCase = true)) {
      executeOptions = executeOptions.withIndexMode(Pipeline.ExecuteOptions.IndexMode.RECOMMENDED)
    }
    return executeOptions
  }

  /**
   * Builds a Pipeline from a list of stage maps without executing it. Used when a stage (e.g.
   * union) requires another pipeline as an argument.
   */
  @Suppress("UNCHECKED_CAST")
  fun buildPipeline(firestore: FirebaseFirestore, stages: List<Map<String, Any>>): Pipeline {
    require(stages.isNotEmpty()) { "Pipeline must have at least one stage (source)." }
    val expressionParsers = ExpressionParsers(firestore)
    val stageHandlers = PipelineStageHandlers(expressionParsers)
    val pipelineSource = firestore.pipeline()
    var pipeline: Pipeline? = null

    for (i in stages.indices) {
      val stageMap = stages[i]
      val stageName =
          stageMap["stage"] as String?
              ?: throw IllegalArgumentException("Stage must have a 'stage' field")
      val args = stageMap["args"] as Map<String, Any>?
      pipeline =
          if (i == 0) {
            applySourceStage(pipelineSource, stageName, args, firestore)
          } else {
            stageHandlers.applyStage(pipeline!!, stageName, args, firestore)
          }
    }
    return pipeline!!
  }

  @Suppress("UNCHECKED_CAST")
  private fun applySourceStage(
      pipelineSource: PipelineSource,
      stageName: String,
      args: Map<String, Any>?,
      firestore: FirebaseFirestore
  ): Pipeline {
    if (args == null && stageName != "database") {
      throw IllegalArgumentException("Stage args must not be null for stage: $stageName")
    }
    return when (stageName) {
      "collection" -> pipelineSource.collection(args!!["path"] as String)
      "collection_group" -> pipelineSource.collectionGroup(args!!["path"] as String)
      "database" -> pipelineSource.database()
      "documents" -> {
        val docMaps = args as List<Map<String, Any>>
        val docRefs = ArrayList<DocumentReference>()
        for (docMap in docMaps) {
          docRefs.add(firestore.document(docMap["path"] as String))
        }
        pipelineSource.documents(*docRefs.toTypedArray())
      }
      else ->
          throw IllegalArgumentException(
              "First stage must be one of: collection, collection_group, documents, database. Got: $stageName")
    }
  }
}
