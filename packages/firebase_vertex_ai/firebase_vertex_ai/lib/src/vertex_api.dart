// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_vertex_ai/firebase_vertex_ai.dart';

import 'vertex_content.dart';
import 'vertex_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as googleAI;

final class CountTokensResponse {
  /// The number of tokens that the `model` tokenizes the `prompt` into.
  ///
  /// Always non-negative.
  final int totalTokens;

  CountTokensResponse(this.totalTokens);

  factory CountTokensResponse.fromGoogleAICountTokensResponse(
          googleAI.CountTokensResponse countTokensResponse) =>
      CountTokensResponse(countTokensResponse.totalTokens);

  /// Converts this response to a [googleAI.CountTokensResponse].
  googleAI.CountTokensResponse toGoogleAICountTokensResponse() =>
      googleAI.CountTokensResponse(totalTokens);
}

/// Response from the model; supports multiple candidates.
final class GenerateContentResponse {
  /// Candidate responses from the model.
  final List<Candidate> candidates;

  /// Returns the prompt's feedback related to the content filters.
  final PromptFeedback? promptFeedback;

  GenerateContentResponse(this.candidates, this.promptFeedback);

  factory GenerateContentResponse.fromGoogleAIGenerateContentResponse(
          googleAI.GenerateContentResponse generateContentResponse) =>
      GenerateContentResponse(
          generateContentResponse.candidates
              .map((candidate) => Candidate.fromGoogleAICandidate(candidate))
              .toList(),
          PromptFeedback.fromGoogleAIPromptFeedback(
              generateContentResponse.promptFeedback!));

  /// Converts this response to a [GenerateContentResponse].

  googleAI.GenerateContentResponse toGoogleAIGenerateContentResponse() =>
      googleAI.GenerateContentResponse(
          candidates
              .map(
                (candidate) => candidate.toGoogleAICandidate(),
              )
              .toList(),
          promptFeedback?.toGoogleAIPromptFeedback());

  /// The text content of the first part of the first of [candidates], if any.
  ///
  /// If the prompt was blocked, or the first candidate was finished for a reason
  /// of [FinishReason.recitation] or [FinishReason.safety], accessing this text
  /// will throw a [GenerativeAIException].
  ///
  /// If the first candidate's content starts with a text part, this value is
  /// that text.
  ///
  /// If there are no candidates, or if the first candidate does not start with
  /// a text part, this value is `null`.
  String? get text {
    return switch (candidates) {
      [] => switch (promptFeedback) {
          PromptFeedback(
            :final blockReason,
            :final blockReasonMessage,
          ) =>
            // TODO: Add a specific subtype for this exception?
            throw googleAI.GenerativeAIException('Response was blocked'
                '${blockReason != null ? ' due to $blockReason' : ''}'
                '${blockReasonMessage != null ? ': $blockReasonMessage' : ''}'),
          _ => null,
        },
      [
        Candidate(
          finishReason: (FinishReason.recitation || FinishReason.safety) &&
              final finishReason,
          :final finishMessage,
        ),
        ...
      ] =>
        throw googleAI.GenerativeAIException(
          // ignore: prefer_interpolation_to_compose_strings
          'Candidate was blocked due to $finishReason' +
              (finishMessage != null && finishMessage.isNotEmpty
                  ? ': $finishMessage'
                  : ''),
        ),
      [Candidate(content: Content(parts: [TextPart(:final text)])), ...] =>
        text,
      [Candidate(), ...] => null,
    };
  }
}

final class EmbedContentResponse {
  /// The embedding generated from the input content.
  final ContentEmbedding embedding;

  EmbedContentResponse(this.embedding);
  factory EmbedContentResponse.fromGoogleAIEmbedContentResponse(
          googleAI.EmbedContentResponse embedContentResponse) =>
      EmbedContentResponse(ContentEmbedding.fromGoogleAIContentEmbedding(
          embedContentResponse.embedding));

  /// Converts this response to a [EmbedContentResponse].

  googleAI.EmbedContentResponse toGoogleAIEmbedContentResponse() =>
      googleAI.EmbedContentResponse(embedding.toGoogleAIContentEmbedding());
}

/// An embedding, as defined by a list of values.
final class ContentEmbedding {
  /// The embedding values.
  final List<double> values;

  ContentEmbedding(this.values);
  factory ContentEmbedding.fromGoogleAIContentEmbedding(
          googleAI.ContentEmbedding contentEmbedding) =>
      ContentEmbedding(contentEmbedding.values);

  /// Converts this embedding to a [googleAI.ContentEmbedding].
  googleAI.ContentEmbedding toGoogleAIContentEmbedding() =>
      googleAI.ContentEmbedding(values);
}

/// Feedback metadata of a prompt specified in a [GenerativeModel] request.
final class PromptFeedback {
  /// If set, the prompt was blocked and no candidates are returned.
  ///
  /// Rephrase your prompt.
  final BlockReason? blockReason;

  final String? blockReasonMessage;

  /// Ratings for safety of the prompt.
  ///
  /// There is at most one rating per category.
  final List<SafetyRating> safetyRatings;

  PromptFeedback(this.blockReason, this.blockReasonMessage, this.safetyRatings);
  factory PromptFeedback.fromGoogleAIPromptFeedback(
          googleAI.PromptFeedback promptFeedback) =>
      PromptFeedback(
        promptFeedback.blockReason != null
            ? BlockReason.fromGoogleAIBlockReason(promptFeedback.blockReason!)
            : null,
        promptFeedback.blockReasonMessage,
        promptFeedback.safetyRatings
            .map((safetyRating) =>
                SafetyRating.fromGoogleAISafetyRating(safetyRating))
            .toList(),
      );

  /// Converts this feedback to a [googleAI.PromptFeedback].
  googleAI.PromptFeedback toGoogleAIPromptFeedback() => googleAI.PromptFeedback(
        blockReason?.toGoogleAIBlockReason(),
        blockReasonMessage,
        safetyRatings
            .map((safetyRating) => safetyRating.toGoogleAISafetyRating())
            .toList(),
      );
}

/// Response candidate generated from a [GenerativeModel].
final class Candidate {
  /// Generated content returned from the model.
  final Content content;

  /// List of ratings for the safety of a response candidate.
  ///
  /// There is at most one rating per category.
  final List<SafetyRating>? safetyRatings;

  /// Citation information for model-generated candidate.
  ///
  /// This field may be populated with recitation information for any text
  /// included in the [content]. These are passages that are "recited" from
  /// copyrighted material in the foundational LLM's training data.
  final CitationMetadata? citationMetadata;

  /// The reason why the model stopped generating tokens.
  ///
  /// If empty, the model has not stopped generating the tokens.
  final FinishReason? finishReason;

  final String? finishMessage;

  // TODO: token count?
  Candidate(this.content, this.safetyRatings, this.citationMetadata,
      this.finishReason, this.finishMessage);
  factory Candidate.fromGoogleAICandidate(googleAI.Candidate candidate) =>
      Candidate(
          Content.fromGoogleAIContent(candidate.content),
          candidate.safetyRatings
              ?.map((s) => SafetyRating.fromGoogleAISafetyRating(s))
              .toList(),
          candidate.citationMetadata != null
              ? CitationMetadata.fromGoogleAICitationMetadata(
                  candidate.citationMetadata!)
              : null,
          candidate.finishReason != null
              ? FinishReason.fromGoogleAIFinishReason(candidate.finishReason!)
              : null,
          candidate.finishMessage);

  googleAI.Candidate toGoogleAICandidate() => googleAI.Candidate(
        content.toGoogleAIContent(),
        safetyRatings?.map((s) => s.toGoogleAISafetyRating()).toList(),
        citationMetadata?.toGoogleAICitationMetadata(),
        finishReason?.toGoogleAIFinishReason(),
        finishMessage,
      );
}

/// Safety rating for a piece of content.
///
/// The safety rating contains the category of harm and the harm probability
/// level in that category for a piece of content. Content is classified for
/// safety across a number of harm categories and the probability of the harm
/// classification is included here.
final class SafetyRating {
  /// The category for this rating.
  final HarmCategory category;

  /// The probability of harm for this content.
  final HarmProbability probability;

  SafetyRating(this.category, this.probability);
  factory SafetyRating.fromGoogleAISafetyRating(
          googleAI.SafetyRating safetyRating) =>
      SafetyRating(HarmCategory.fromGoogleAIHarmCategory(safetyRating.category),
          HarmProbability.fromHarmProbability(safetyRating.probability));

  /// Converts this rating to a [googleAI.SafetyRating].
  googleAI.SafetyRating toGoogleAISafetyRating() => googleAI.SafetyRating(
      category.toGoogleAIHarmCategory(), probability.toHarmProbability());
}

/// The reason why a prompt was blocked.
enum BlockReason {
  /// Default value to use when a blocking reason isn't set.
  ///
  /// Never used as the reason for blocking a prompt.
  unspecified('BLOCK_REASON_UNSPECIFIED'),

  /// Prompt was blocked due to safety reasons.
  ///
  /// You can inspect `safetyRatings` to see which safety category blocked the
  /// prompt.
  safety('SAFETY'),

  /// Prompt was blocked due to other unspecified reasons.
  other('OTHER');

  static BlockReason _parseValue(String jsonObject) {
    return switch (jsonObject) {
      'BLOCK_REASON_UNSPECIFIED' => BlockReason.unspecified,
      'SAFETY' => BlockReason.safety,
      'OTHER' => BlockReason.other,
      _ => throw FormatException('Unhandled BlockReason format', jsonObject),
    };
  }

  const BlockReason(this._jsonString);

  static BlockReason fromGoogleAIBlockReason(
      googleAI.BlockReason googleAIBlockReason) {
    return switch (googleAIBlockReason) {
      googleAI.BlockReason.unspecified => BlockReason.unspecified,
      googleAI.BlockReason.safety => BlockReason.safety,
      googleAI.BlockReason.other => BlockReason.other,
    };
  }

  /// Converts this blocking reason to a [googleAI.BlockReason].

  googleAI.BlockReason toGoogleAIBlockReason() {
    return switch (this) {
      BlockReason.unspecified => googleAI.BlockReason.unspecified,
      BlockReason.safety => googleAI.BlockReason.safety,
      BlockReason.other => googleAI.BlockReason.other
    };
  }

  final String _jsonString;

  String toJson() => _jsonString;

  @override
  String toString() => name;
}

/// The category of a rating.
///
/// These categories cover various kinds of harms that developers may wish to
/// adjust.
enum HarmCategory {
  unspecified('HARM_CATEGORY_UNSPECIFIED'),

  /// Malicious, intimidating, bullying, or abusive comments targeting another
  /// individual.
  harassment('HARM_CATEGORY_HARASSMENT'),

  /// Negative or harmful comments targeting identity and/or protected
  /// attributes.
  hateSpeech('HARM_CATEGORY_HATE_SPEECH'),

  /// Contains references to sexual acts or other lewd content.
  sexuallyExplicit('HARM_CATEGORY_SEXUALLY_EXPLICIT'),

  /// Promotes or enables access to harmful goods, services, and activities.
  dangerousContent('HARM_CATEGORY_DANGEROUS_CONTENT');

  static HarmCategory _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'HARM_CATEGORY_UNSPECIFIED' => HarmCategory.unspecified,
      'HARM_CATEGORY_HARASSMENT' => HarmCategory.harassment,
      'HARM_CATEGORY_HATE_SPEECH' => HarmCategory.hateSpeech,
      'HARM_CATEGORY_SEXUALLY_EXPLICIT' => HarmCategory.sexuallyExplicit,
      'HARM_CATEGORY_DANGEROUS_CONTENT' => HarmCategory.dangerousContent,
      _ => throw FormatException('Unhandled HarmCategory format', jsonObject),
    };
  }

  const HarmCategory(this._jsonString);
  factory HarmCategory.fromGoogleAIHarmCategory(
      googleAI.HarmCategory harmCategory) {
    return switch (harmCategory) {
      googleAI.HarmCategory.unspecified => HarmCategory.unspecified,
      googleAI.HarmCategory.harassment => HarmCategory.harassment,
      googleAI.HarmCategory.hateSpeech => HarmCategory.hateSpeech,
      googleAI.HarmCategory.sexuallyExplicit => HarmCategory.sexuallyExplicit,
      googleAI.HarmCategory.dangerousContent => HarmCategory.dangerousContent,
    };
  }

  @override
  String toString() => name;

  final String _jsonString;

  String toJson() => _jsonString;

  /// Converts this harm category to a [googleAI.HarmCategory].

  googleAI.HarmCategory toGoogleAIHarmCategory() {
    return switch (this) {
      HarmCategory.unspecified => googleAI.HarmCategory.unspecified,
      HarmCategory.harassment => googleAI.HarmCategory.harassment,
      HarmCategory.hateSpeech => googleAI.HarmCategory.hateSpeech,
      HarmCategory.sexuallyExplicit => googleAI.HarmCategory.sexuallyExplicit,
      HarmCategory.dangerousContent => googleAI.HarmCategory.dangerousContent,
    };
  }
}

/// The probability that a piece of content is harmful.
///
/// The classification system gives the probability of the content being unsafe.
/// This does not indicate the severity of harm for a piece of content.
enum HarmProbability {
  /// Probability is unspecified.
  unspecified('UNSPECIFIED'),

  /// Content has a negligible probability of being unsafe.
  negligible('NEGLIGIBLE'),

  /// Content has a low probability of being unsafe.
  low('LOW'),

  /// Content has a medium probability of being unsafe.
  medium('MEDIUM'),

  /// Content has a high probability of being unsafe.
  high('HIGH');

  static HarmProbability _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'UNSPECIFIED' => HarmProbability.unspecified,
      'NEGLIGIBLE' => HarmProbability.negligible,
      'LOW' => HarmProbability.low,
      'MEDIUM' => HarmProbability.medium,
      'HIGH' => HarmProbability.high,
      _ =>
        throw FormatException('Unhandled HarmProbability format', jsonObject),
    };
  }

  const HarmProbability(this._jsonString);

  factory HarmProbability.fromHarmProbability(
      googleAI.HarmProbability harmProbability) {
    return switch (harmProbability) {
      googleAI.HarmProbability.unspecified => HarmProbability.unspecified,
      googleAI.HarmProbability.negligible => HarmProbability.negligible,
      googleAI.HarmProbability.low => HarmProbability.low,
      googleAI.HarmProbability.medium => HarmProbability.medium,
      googleAI.HarmProbability.high => HarmProbability.high,
    };
  }

  googleAI.HarmProbability toHarmProbability() {
    return switch (this) {
      HarmProbability.unspecified => googleAI.HarmProbability.unspecified,
      HarmProbability.negligible => googleAI.HarmProbability.negligible,
      HarmProbability.low => googleAI.HarmProbability.low,
      HarmProbability.medium => googleAI.HarmProbability.medium,
      HarmProbability.high => googleAI.HarmProbability.high,
    };
  }

  final String _jsonString;

  String toJson() => _jsonString;

  @override
  String toString() => name;
}

/// Source attributions for a piece of content.
final class CitationMetadata {
  /// Citations to sources for a specific response.
  final List<CitationSource> citationSources;

  CitationMetadata(this.citationSources);
  factory CitationMetadata.fromGoogleAICitationMetadata(
          googleAI.CitationMetadata citationMetadata) =>
      CitationMetadata(citationMetadata.citationSources
          .map((e) => CitationSource.fromGoogleAICiationSource(e))
          .toList());

  googleAI.CitationMetadata toGoogleAICitationMetadata() =>
      googleAI.CitationMetadata(
          citationSources.map((e) => e.toGoogleAICiationSource()).toList());
}

/// Citation to a source for a portion of a specific response.
final class CitationSource {
  /// Start of segment of the response that is attributed to this source.
  ///
  /// Index indicates the start of the segment, measured in bytes.
  final int? startIndex;

  /// End of the attributed segment, exclusive.
  final int? endIndex;

  /// URI that is attributed as a source for a portion of the text.
  final Uri? uri;

  /// License for the GitHub project that is attributed as a source for segment.
  ///
  /// License info is required for code citations.
  final String? license;

  CitationSource(this.startIndex, this.endIndex, this.uri, this.license);
  factory CitationSource.fromGoogleAICiationSource(
          googleAI.CitationSource source) =>
      CitationSource(
          source.startIndex, source.endIndex, source.uri, source.license);

  googleAI.CitationSource toGoogleAICiationSource() =>
      googleAI.CitationSource(startIndex, endIndex, uri, license);
}

/// Reason why a model stopped generating tokens.
enum FinishReason {
  /// Default value to use when a finish reason isn't set.
  ///
  /// Never used as the reason for finshing.
  unspecified('UNSPECIFIED'),

  /// Natural stop point of the model or provided stop sequence.
  stop('STOP'),

  /// The maximum number of tokens as specified in the request was reached.
  maxTokens('MAX_TOKENS'),

  /// The candidate content was flagged for safety reasons.
  safety('SAFETY'),

  /// The candidate content was flagged for recitation reasons.
  recitation('RECITATION'),

  /// Unknown reason.
  other('OTHER');

  const FinishReason(this._jsonString);

  factory FinishReason.fromGoogleAIFinishReason(
      googleAI.FinishReason finishReason) {
    return switch (finishReason) {
      googleAI.FinishReason.unspecified => FinishReason.unspecified,
      googleAI.FinishReason.stop => FinishReason.stop,
      googleAI.FinishReason.maxTokens => FinishReason.maxTokens,
      googleAI.FinishReason.safety => FinishReason.safety,
      googleAI.FinishReason.recitation => FinishReason.recitation,
      googleAI.FinishReason.other => FinishReason.other,
    };
  }

  googleAI.FinishReason toGoogleAIFinishReason() {
    return switch (this) {
      FinishReason.unspecified => googleAI.FinishReason.unspecified,
      FinishReason.stop => googleAI.FinishReason.stop,
      FinishReason.maxTokens => googleAI.FinishReason.maxTokens,
      FinishReason.safety => googleAI.FinishReason.safety,
      FinishReason.recitation => googleAI.FinishReason.recitation,
      FinishReason.other => googleAI.FinishReason.other,
    };
  }

  final String _jsonString;

  String toJson() => _jsonString;

  static FinishReason _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'UNSPECIFIED' => FinishReason.unspecified,
      'STOP' => FinishReason.stop,
      'MAX_TOKENS' => FinishReason.maxTokens,
      'SAFETY' => FinishReason.safety,
      'RECITATION' => FinishReason.recitation,
      'OTHER' => FinishReason.other,
      _ => throw FormatException('Unhandled FinishReason format', jsonObject),
    };
  }

  @override
  String toString() => name;
}

/// Safety setting, affecting the safety-blocking behavior.
///
/// Passing a safety setting for a category changes the allowed probability that
/// content is blocked.
final class SafetySetting {
  /// The category for this setting.
  final HarmCategory category;

  /// Controls the probability threshold at which harm is blocked.
  final HarmBlockThreshold threshold;

  SafetySetting(this.category, this.threshold);
  factory SafetySetting.fromGoogleAISafetySetting(
          googleAI.SafetySetting setting) =>
      SafetySetting(HarmCategory.fromGoogleAIHarmCategory(setting.category),
          HarmBlockThreshold.fromGoogleAIHarmBlockThreshold(setting.threshold));

  googleAI.SafetySetting toGoogleAISafetySetting() => googleAI.SafetySetting(
      category.toGoogleAIHarmCategory(),
      threshold.toGoogleAIHarmBlockThreshold());

  Object toJson() =>
      {'category': category.toJson(), 'threshold': threshold.toJson()};
}

/// Probability of harm which causes content to be blocked.
///
/// When provided in [SafetySetting.threshold], a predicted harm probability at
/// or above this level will block content from being returned.
enum HarmBlockThreshold {
  /// Threshold is unspecified, block using default threshold.
  unspecified('HARM_BLOCK_THRESHOLD_UNSPECIFIED'),

  /// Block when medium or high probability of unsafe content.
  low('BLOCK_LOW_AND_ABOVE'),

  /// Block when medium or high probability of unsafe content.
  medium('BLOCK_MEDIUM_AND_ABOVE'),

  /// Block when high probability of unsafe content.
  high('BLOCK_ONLY_HIGH'),

  /// Always show regardless of probability of unsafe content.
  none('BLOCK_NONE');

  static HarmBlockThreshold _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'HARM_BLOCK_THRESHOLD_UNSPECIFIED' => HarmBlockThreshold.unspecified,
      'BLOCK_LOW_AND_ABOVE' => HarmBlockThreshold.low,
      'BLOCK_MEDIUM_AND_ABOVE' => HarmBlockThreshold.medium,
      'BLOCK_ONLY_HIGH' => HarmBlockThreshold.high,
      'BLOCK_NONE' => HarmBlockThreshold.none,
      _ => throw FormatException(
          'Unhandled HarmBlockThreshold format', jsonObject),
    };
  }

  final String _jsonString;

  const HarmBlockThreshold(this._jsonString);
  factory HarmBlockThreshold.fromGoogleAIHarmBlockThreshold(
      googleAI.HarmBlockThreshold threshold) {
    return switch (threshold) {
      googleAI.HarmBlockThreshold.unspecified => HarmBlockThreshold.unspecified,
      googleAI.HarmBlockThreshold.low => HarmBlockThreshold.low,
      googleAI.HarmBlockThreshold.medium => HarmBlockThreshold.medium,
      googleAI.HarmBlockThreshold.high => HarmBlockThreshold.high,
      googleAI.HarmBlockThreshold.none => HarmBlockThreshold.none,
    };
  }

  googleAI.HarmBlockThreshold toGoogleAIHarmBlockThreshold() {
    return switch (this) {
      HarmBlockThreshold.unspecified => googleAI.HarmBlockThreshold.unspecified,
      HarmBlockThreshold.low => googleAI.HarmBlockThreshold.low,
      HarmBlockThreshold.medium => googleAI.HarmBlockThreshold.medium,
      HarmBlockThreshold.high => googleAI.HarmBlockThreshold.high,
      HarmBlockThreshold.none => googleAI.HarmBlockThreshold.none,
    };
  }

  @override
  String toString() => name;

  Object toJson() => _jsonString;
}

/// Configuration options for model generation and outputs.
final class GenerationConfig {
  /// Number of generated responses to return.
  ///
  /// This value must be between [1, 8], inclusive. If unset, this will default
  /// to 1.
  final int? candidateCount;

  /// The set of character sequences (up to 5) that will stop output generation.
  ///
  /// If specified, the API will stop at the first appearance of a stop
  /// sequence. The stop sequence will not be included as part of the response.
  final List<String> stopSequences;

  /// The maximum number of tokens to include in a candidate.
  ///
  /// If unset, this will default to output_token_limit specified in the `Model`
  /// specification.
  final int? maxOutputTokens;

  /// Controls the randomness of the output.
  ///
  /// Note: The default value varies by model.
  ///
  /// Values can range from `[0.0, infinity]`, inclusive. A value temperature
  /// must be greater than 0.0.
  final double? temperature;

  /// The maximum cumulative probability of tokens to consider when sampling.
  ///
  /// The model uses combined Top-k and nucleus sampling. Tokens are sorted
  /// based on their assigned probabilities so that only the most likely tokens
  /// are considered. Top-k sampling directly limits the maximum number of
  /// tokens to consider, while Nucleus sampling limits number of tokens based
  /// on the cumulative probability.
  ///
  /// Note: The default value varies by model.
  final double? topP;

  /// The maximum number of tokens to consider when sampling.
  ///
  /// The model uses combined Top-k and nucleus sampling. Top-k sampling
  /// considers the set of `top_k` most probable tokens. Defaults to 40.
  ///
  /// Note: The default value varies by model.
  final int? topK;

  GenerationConfig(
      {this.candidateCount,
      this.stopSequences = const [],
      this.maxOutputTokens,
      this.temperature,
      this.topP,
      this.topK});

  factory GenerationConfig.fromGoogleAIGenerationConfig(
          googleAI.GenerationConfig config) =>
      GenerationConfig(
          candidateCount: config.candidateCount,
          stopSequences: config.stopSequences,
          maxOutputTokens: config.maxOutputTokens,
          temperature: config.temperature,
          topP: config.topP,
          topK: config.topK);

  Map<String, Object?> toJson() => {
        if (candidateCount case final candidateCount?)
          'candidateCount': candidateCount,
        if (stopSequences.isNotEmpty) 'stopSequences': stopSequences,
        if (maxOutputTokens case final maxOutputTokens?)
          'maxOutputTokens': maxOutputTokens,
        if (temperature case final temperature?) 'temperature': temperature,
        if (topP case final topP?) 'topP': topP,
        if (topK case final topK?) 'topK': topK,
      };

  googleAI.GenerationConfig toGoogleAIGenerationConfig() =>
      googleAI.GenerationConfig(
          candidateCount: candidateCount,
          stopSequences: stopSequences,
          maxOutputTokens: maxOutputTokens,
          temperature: temperature,
          topP: topP,
          topK: topK);
}

/// Type of task for which the embedding will be used.
enum TaskType {
  /// Unset value, which will default to one of the other enum values.
  unspecified('TASK_TYPE_UNSPECIFIED'),

  /// Specifies the given text is a query in a search/retrieval setting.
  retrievalQuery('RETRIEVAL_QUERY'),

  /// Specifies the given text is a document from the corpus being searched.
  retrievalDocument('RETRIEVAL_DOCUMENT'),

  /// Specifies the given text will be used for STS.
  semanticSimilarity('SEMANTIC_SIMILARITY'),

  /// Specifies that the given text will be classified.
  classification('CLASSIFICATION'),

  /// Specifies that the embeddings will be used for clustering.
  clustering('CLUSTERING');

  final String _jsonString;

  const TaskType(this._jsonString);
  factory TaskType.fromGoogleAITaskType(googleAI.TaskType type) {
    return switch (type) {
      googleAI.TaskType.unspecified => TaskType.unspecified,
      googleAI.TaskType.retrievalQuery => TaskType.retrievalQuery,
      googleAI.TaskType.retrievalDocument => TaskType.retrievalDocument,
      googleAI.TaskType.semanticSimilarity => TaskType.semanticSimilarity,
      googleAI.TaskType.classification => TaskType.classification,
      googleAI.TaskType.clustering => TaskType.clustering,
    };
  }

  static TaskType _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'TASK_TYPE_UNSPECIFIED' => TaskType.unspecified,
      'RETRIEVAL_QUERY' => TaskType.retrievalQuery,
      'RETRIEVAL_DOCUMENT' => TaskType.retrievalDocument,
      'SEMANTIC_SIMILARITY' => TaskType.semanticSimilarity,
      'CLASSIFICATION' => TaskType.classification,
      'CLUSTERING' => TaskType.clustering,
      _ => throw FormatException('Unhandled TaskType format', jsonObject),
    };
  }

  Object toJson() => _jsonString;
  googleAI.TaskType toGoogleAITaskType() {
    return switch (this) {
      TaskType.unspecified => googleAI.TaskType.unspecified,
      TaskType.retrievalQuery => googleAI.TaskType.retrievalQuery,
      TaskType.retrievalDocument => googleAI.TaskType.retrievalDocument,
      TaskType.semanticSimilarity => googleAI.TaskType.semanticSimilarity,
      TaskType.classification => googleAI.TaskType.classification,
      TaskType.clustering => googleAI.TaskType.clustering,
    };
  }
}

GenerateContentResponse parseGenerateContentResponse(Object jsonObject) {
  return switch (jsonObject) {
    {'candidates': final List<Object?> candidates} => GenerateContentResponse(
        candidates.map(_parseCandidate).toList(),
        switch (jsonObject) {
          {'promptFeedback': final promptFeedback?} =>
            _parsePromptFeedback(promptFeedback),
          _ => null
        }),
    {'promptFeedback': final promptFeedback?} =>
      GenerateContentResponse([], _parsePromptFeedback(promptFeedback)),
    _ => throw FormatException(
        'Unhandled GenerateContentResponse format', jsonObject)
  };
}

CountTokensResponse parseCountTokensResponse(Object jsonObject) {
  return switch (jsonObject) {
    {'totalTokens': final int totalTokens} => CountTokensResponse(totalTokens),
    _ =>
      throw FormatException('Unhandled CountTokensResponse format', jsonObject)
  };
}

EmbedContentResponse parseEmbedContentResponse(Object jsonObject) {
  return switch (jsonObject) {
    {'embedding': final Object embedding} =>
      EmbedContentResponse(_parseContentEmbedding(embedding)),
    _ =>
      throw FormatException('Unhandled EmbedContentResponse format', jsonObject)
  };
}

Candidate _parseCandidate(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw FormatException('Unhandled Candidate format', jsonObject);
  }

  return Candidate(
    jsonObject.containsKey('content')
        ? parseContent(jsonObject['content'] as Object)
        : Content(null, []),
    switch (jsonObject) {
      {'safetyRatings': final List<Object?> safetyRatings} =>
        safetyRatings.map(_parseSafetyRating).toList(),
      _ => null
    },
    switch (jsonObject) {
      {'citationMetadata': final Object citationMetadata} =>
        _parseCitationMetadata(citationMetadata),
      _ => null
    },
    switch (jsonObject) {
      {'finishReason': final Object finishReason} =>
        FinishReason._parseValue(finishReason),
      _ => null
    },
    switch (jsonObject) {
      {'finishMessage': final String finishMessage} => finishMessage,
      _ => null
    },
  );
}

PromptFeedback _parsePromptFeedback(Object jsonObject) {
  return switch (jsonObject) {
    {
      'safetyRatings': final List<Object?> safetyRatings,
    } =>
      PromptFeedback(
          switch (jsonObject) {
            {'blockReason': final String blockReason} =>
              BlockReason._parseValue(blockReason),
            _ => null,
          },
          switch (jsonObject) {
            {'blockReasonMessage': final String blockReasonMessage} =>
              blockReasonMessage,
            _ => null,
          },
          safetyRatings.map(_parseSafetyRating).toList()),
    _ => throw FormatException('Unhandled PromptFeedback format', jsonObject),
  };
}

SafetyRating _parseSafetyRating(Object? jsonObject) {
  return switch (jsonObject) {
    {
      'category': final Object category,
      'probability': final Object probability
    } =>
      SafetyRating(HarmCategory._parseValue(category),
          HarmProbability._parseValue(probability)),
    _ => throw FormatException('Unhandled SafetyRating format', jsonObject),
  };
}

ContentEmbedding _parseContentEmbedding(Object? jsonObject) {
  return switch (jsonObject) {
    {'values': final List<Object?> values} => ContentEmbedding(<double>[
        ...values.cast<double>(),
      ]),
    _ => throw FormatException('Unhandled ContentEmbedding format', jsonObject),
  };
}

CitationMetadata _parseCitationMetadata(Object? jsonObject) {
  return switch (jsonObject) {
    {'citationSources': final List<Object?> citationSources} =>
      CitationMetadata(citationSources.map(_parseCitationSource).toList()),
    _ => throw FormatException('Unhandled CitationMetadata format', jsonObject),
  };
}

CitationSource _parseCitationSource(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw FormatException('Unhandled CitationSource format', jsonObject);
  }

  final uriString = jsonObject['uri'] as String?;

  return CitationSource(
    jsonObject['startIndex'] as int?,
    jsonObject['endIndex'] as int?,
    uriString != null ? Uri.parse(uriString) : null,
    jsonObject['license'] as String?,
  );
}
