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

import 'package:google_generative_ai/google_generative_ai.dart' as google_ai;
// ignore: implementation_imports, tightly coupled packages
import 'package:google_generative_ai/src/vertex_hooks.dart' as google_ai_hooks;

import 'vertex_content.dart';

/// Response for Count Tokens
final class CountTokensResponse {
  /// Constructor
  CountTokensResponse(this.totalTokens, {this.totalBillableCharacters});

  /// The number of tokens that the `model` tokenizes the `prompt` into.
  ///
  /// Always non-negative.
  final int totalTokens;

  /// The number of characters that the `model` could bill at.
  ///
  /// Always non-negative.
  final int? totalBillableCharacters;
}

/// Conversion utilities for [google_ai.CountTokensResponse].
extension GoogleAICountTokensResponseConversion
    on google_ai.CountTokensResponse {
  /// Returns this response as a [CountTokensResponse].
  CountTokensResponse toVertex() => CountTokensResponse(
        totalTokens,
        totalBillableCharacters: totalBillableCharacters,
      );
}

/// Extension on [google_ai.CountTokensResponse] to access extra fields
extension CountTokensResponseFields on google_ai.CountTokensResponse {
  /// Total billable Characters for the prompt.
  int? get totalBillableCharacters => google_ai_hooks
      .countTokensResponseFields(this)?['totalBillableCharacters'] as int?;
}

/// Response from the model; supports multiple candidates.
final class GenerateContentResponse {
  /// Constructor
  GenerateContentResponse(this.candidates, this.promptFeedback,
      {this.usageMetadata});

  /// Candidate responses from the model.
  final List<Candidate> candidates;

  /// Returns the prompt's feedback related to the content filters.
  final PromptFeedback? promptFeedback;

  /// Meta data for the response
  final UsageMetadata? usageMetadata;

  /// The text content of the first part of the first of [candidates], if any.
  ///
  /// If the prompt was blocked, or the first candidate was finished for a reason
  /// of [FinishReason.recitation] or [FinishReason.safety], accessing this text
  /// will throw a [google_ai.GenerativeAIException].
  ///
  /// If the first candidate's content contains any text parts, this value is
  /// the concatenation of the text.
  ///
  /// If there are no candidates, or if the first candidate does not contain any
  /// text parts, this value is `null`.
  String? get text {
    return switch (candidates) {
      [] => switch (promptFeedback) {
          PromptFeedback(
            :final blockReason,
            :final blockReasonMessage,
          ) =>
            // TODO: Add a specific subtype for this exception?
            throw google_ai.GenerativeAIException('Response was blocked'
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
        throw google_ai.GenerativeAIException(
          // ignore: prefer_interpolation_to_compose_strings
          'Candidate was blocked due to $finishReason' +
              (finishMessage != null && finishMessage.isNotEmpty
                  ? ': $finishMessage'
                  : ''),
        ),
      // Special case for a single TextPart to avoid iterable chain.
      [Candidate(content: Content(parts: [TextPart(:final text)])), ...] =>
        text,
      [Candidate(content: Content(:final parts)), ...]
          when parts.any((p) => p is TextPart) =>
        parts.whereType<TextPart>().map((p) => p.text).join(),
      [Candidate(), ...] => null,
    };
  }

  /// The function call parts of the first candidate in [candidates], if any.
  ///
  /// Returns an empty list if there are no candidates, or if the first
  /// candidate has no [FunctionCall] parts. There is no error thrown if the
  /// prompt or response were blocked.
  Iterable<FunctionCall> get functionCalls =>
      candidates.firstOrNull?.content.parts.whereType<FunctionCall>() ??
      const [];
}

/// Conversion utilities for [google_ai.GenerateContentResponse].
extension GoogleAIGenerateContentResponseConversion
    on google_ai.GenerateContentResponse {
  /// Returns this response as a [GenerateContentResponse].
  GenerateContentResponse toVertex() => GenerateContentResponse(
        candidates.map((c) => c.toVertex()).toList(),
        promptFeedback?.toVertex(),
        usageMetadata: usageMetadata?.toVertex(),
      );
}

/// Response for Embed Content.
final class EmbedContentResponse {
  /// Constructor
  EmbedContentResponse(this.embedding);

  /// The embedding generated from the input content.
  final ContentEmbedding embedding;
}

/// Conversion utilities for [google_ai.EmbedContentResponse].
extension GoogleAIEmbedContentResponseConversion
    on google_ai.EmbedContentResponse {
  /// Returns this response as a [EmbedContentResponse].
  EmbedContentResponse toVertex() => EmbedContentResponse(embedding.toVertex());
}

/// Response for Embed Content in batch.
final class BatchEmbedContentsResponse {
  /// Constructor
  BatchEmbedContentsResponse(this.embeddings);

  /// The embeddings generated from the input content for each request, in the
  /// same order as provided in the batch request.
  final List<ContentEmbedding> embeddings;
}

/// Conversion utilities for [google_ai.BatchEmbedContentsResponse].
extension GoogleAIBatchEmbedContentsResponseConversion
    on google_ai.BatchEmbedContentsResponse {
  /// Returns this response as a [BatchEmbedContentsResponse].
  BatchEmbedContentsResponse toVertex() =>
      BatchEmbedContentsResponse(embeddings.map((e) => e.toVertex()).toList());
}

/// Request for Embed Content.
final class EmbedContentRequest {
  /// Constructor
  EmbedContentRequest(this.content, {this.taskType, this.title, this.model});

  /// The content to embed.
  final Content content;

  /// The type of task to perform.
  final TaskType? taskType;

  /// The title of the content.
  final String? title;

  /// The model to use.
  final String? model;

  /// Converts this request to a json object.
  Object toJson({String? defaultModel}) => {
        'content': content.toJson(),
        if (taskType case final taskType?) 'taskType': taskType.toJson(),
        if (title != null) 'title': title,
        if (model ?? defaultModel case final model?) 'model': model,
      };
}

/// Conversion utilities for [EmbedContentRequest].
extension EmbedContentRequestConversion on EmbedContentRequest {
  /// Converts this response to a [EmbedContentResponse].
  google_ai.EmbedContentRequest toGoogleAI() =>
      google_ai.EmbedContentRequest(content.toGoogleAI(),
          taskType: taskType?.toGoogleAI(), title: title, model: model);
}

/// An embedding, as defined by a list of values.
final class ContentEmbedding {
  /// Constructor
  ContentEmbedding(this.values);

  /// The embedding values.
  final List<double> values;
}

/// Conversion utilities for [google_ai.ContentEmbedding].
extension GoogleAIContentEmbeddingConversion on google_ai.ContentEmbedding {
  /// Returns this embedding as a [ContentEmbedding].
  ContentEmbedding toVertex() => ContentEmbedding(values);
}

/// Feedback metadata of a prompt specified in a [GenerativeModel] request.
final class PromptFeedback {
  /// Constructor
  PromptFeedback(this.blockReason, this.blockReasonMessage, this.safetyRatings);

  /// If set, the prompt was blocked and no candidates are returned.
  ///
  /// Rephrase your prompt.
  final BlockReason? blockReason;

  /// Message for the block reason.
  final String? blockReasonMessage;

  /// Ratings for safety of the prompt.
  ///
  /// There is at most one rating per category.
  final List<SafetyRating> safetyRatings;
}

/// Conversion utilities for [google_ai.PromptFeedback].
extension GoogleAIPromptFeedback on google_ai.PromptFeedback {
  /// Returns this feedback a [PromptFeedback].
  PromptFeedback toVertex() => PromptFeedback(
        blockReason?.toVertex(),
        blockReasonMessage,
        safetyRatings.map((r) => r.toVertex()).toList(),
      );
}

/// Metadata on the generation request's token usage.
final class UsageMetadata {
  /// Constructor
  UsageMetadata({
    this.promptTokenCount,
    this.candidatesTokenCount,
    this.totalTokenCount,
  });

  /// Number of tokens in the prompt.
  final int? promptTokenCount;

  /// Total number of tokens across the generated candidates.
  final int? candidatesTokenCount;

  /// Total token count for the generation request (prompt + candidates).
  final int? totalTokenCount;
}

/// Conversion utilities for [google_ai.UsageMetadata].
extension GoogleAIUsageMetadata on google_ai.UsageMetadata {
  /// Returns this as a [UsageMetadata].
  UsageMetadata toVertex() => UsageMetadata(
        promptTokenCount: promptTokenCount,
        candidatesTokenCount: candidatesTokenCount,
        totalTokenCount: totalTokenCount,
      );
}

/// Response candidate generated from a [GenerativeModel].
final class Candidate {
  // TODO: token count?
  /// Constructor
  Candidate(this.content, this.safetyRatings, this.citationMetadata,
      this.finishReason, this.finishMessage);

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

  /// Message for finish reason.
  final String? finishMessage;
}

/// Conversion utilities for [google_ai.Candidate].
extension GooglAICandidateConversion on google_ai.Candidate {
  /// Returns this candidate as a [Candidate].
  Candidate toVertex() => Candidate(
        content.toVertex(),
        safetyRatings?.map((r) => r.toVertex()).toList(),
        citationMetadata?.toVertex(),
        finishReason?.toVertex(),
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
  /// Constructor
  SafetyRating(this.category, this.probability);

  /// The category for this rating.
  final HarmCategory category;

  /// The probability of harm for this content.
  final HarmProbability probability;
}

/// Conversion utilities for [google_ai.SafetyRating].
extension GoogleAISafetyRatingConversion on google_ai.SafetyRating {
  /// Returns this safety rating as a [SafetyRating].
  SafetyRating toVertex() =>
      SafetyRating(category.toVertex(), probability.toVertex());
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

  const BlockReason(this._jsonString);
  // ignore: unused_element
  static BlockReason _parseValue(String jsonObject) {
    return switch (jsonObject) {
      'BLOCK_REASON_UNSPECIFIED' => BlockReason.unspecified,
      'SAFETY' => BlockReason.safety,
      'OTHER' => BlockReason.other,
      _ => throw FormatException('Unhandled BlockReason format', jsonObject),
    };
  }

  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;

  @override
  String toString() => name;
}

/// Conversion utilities for [google_ai.BlockReason].
extension GoogleAIBlockReasonConversion on google_ai.BlockReason {
  /// Returns this block reason as a [BlockReason].
  BlockReason toVertex() => switch (this) {
        google_ai.BlockReason.unspecified => BlockReason.unspecified,
        google_ai.BlockReason.safety => BlockReason.safety,
        google_ai.BlockReason.other => BlockReason.other,
      };
}

/// The category of a rating.
///
/// These categories cover various kinds of harms that developers may wish to
/// adjust.
enum HarmCategory {
  /// Harm category is not specified.
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

  const HarmCategory(this._jsonString);
  // ignore: unused_element
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

  @override
  String toString() => name;

  final String _jsonString;

  /// Convert to json format.
  String toJson() => _jsonString;
}

/// Conversion utilities for [google_ai.HarmCategory].
extension GoogleAIHarmCategoryConversion on google_ai.HarmCategory {
  /// Returns this harm category as a [HarmCategory].
  HarmCategory toVertex() => switch (this) {
        google_ai.HarmCategory.unspecified => HarmCategory.unspecified,
        google_ai.HarmCategory.harassment => HarmCategory.harassment,
        google_ai.HarmCategory.hateSpeech => HarmCategory.hateSpeech,
        google_ai.HarmCategory.sexuallyExplicit =>
          HarmCategory.sexuallyExplicit,
        google_ai.HarmCategory.dangerousContent =>
          HarmCategory.dangerousContent,
      };
}

/// Conversion utilities for [HarmCategory].
extension HarmCategoryConversion on HarmCategory {
  /// Returns this harm category as a [google_ai.HarmCategory].
  google_ai.HarmCategory toGoogleAI() {
    return switch (this) {
      HarmCategory.unspecified => google_ai.HarmCategory.unspecified,
      HarmCategory.harassment => google_ai.HarmCategory.harassment,
      HarmCategory.hateSpeech => google_ai.HarmCategory.hateSpeech,
      HarmCategory.sexuallyExplicit => google_ai.HarmCategory.sexuallyExplicit,
      HarmCategory.dangerousContent => google_ai.HarmCategory.dangerousContent,
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

  const HarmProbability(this._jsonString);

  // ignore: unused_element
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

  final String _jsonString;

  /// Convert to json format.
  String toJson() => _jsonString;

  @override
  String toString() => name;
}

/// Conversion utilities for [google_ai.HarmProbability].
extension GoogleAIHarmProbabilityConverison on google_ai.HarmProbability {
  /// Returns this harm probability as a [HarmProbability].
  HarmProbability toVertex() => switch (this) {
        google_ai.HarmProbability.unspecified => HarmProbability.unspecified,
        google_ai.HarmProbability.negligible => HarmProbability.negligible,
        google_ai.HarmProbability.low => HarmProbability.low,
        google_ai.HarmProbability.medium => HarmProbability.medium,
        google_ai.HarmProbability.high => HarmProbability.high,
      };
}

/// Source attributions for a piece of content.
final class CitationMetadata {
  /// Constructor
  CitationMetadata(this.citationSources);

  /// Citations to sources for a specific response.
  final List<CitationSource> citationSources;
}

/// Conversion utilities for [google_ai.CitationMetadata].
extension GoogleAICitationMetadataConversion on google_ai.CitationMetadata {
  /// Returns this citation metadata as a [CitationMetadata].
  CitationMetadata toVertex() =>
      CitationMetadata(citationSources.map((s) => s.toVertex()).toList());
}

/// Citation to a source for a portion of a specific response.
final class CitationSource {
  /// Constructor
  CitationSource(this.startIndex, this.endIndex, this.uri, this.license);

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
}

/// Conversion utilities for [google_ai.CitationSource].
extension GoogleAICitationSourceConversion on google_ai.CitationSource {
  /// Returns this citation source as a [CitationSource].
  CitationSource toVertex() =>
      CitationSource(startIndex, endIndex, uri, license);
}

/// Reason why a model stopped generating tokens.
enum FinishReason {
  /// Default value to use when a finish reason isn't set.
  ///
  /// Never used as the reason for finishing.
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

  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;

  // ignore: unused_element
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

/// Conversion utilities for [google_ai.FinishReason].
extension GoogleAIFinishReasonConversion on google_ai.FinishReason {
  /// Returns this finish reason as a [FinishReason].
  FinishReason toVertex() => switch (this) {
        google_ai.FinishReason.unspecified => FinishReason.unspecified,
        google_ai.FinishReason.stop => FinishReason.stop,
        google_ai.FinishReason.maxTokens => FinishReason.maxTokens,
        google_ai.FinishReason.safety => FinishReason.safety,
        google_ai.FinishReason.recitation => FinishReason.recitation,
        google_ai.FinishReason.other => FinishReason.other,
      };
}

/// Safety setting, affecting the safety-blocking behavior.
///
/// Passing a safety setting for a category changes the allowed probability that
/// content is blocked.
final class SafetySetting {
  /// Constructor
  SafetySetting(this.category, this.threshold);
  // ignore: unused_element
  factory SafetySetting._fromGoogleAISafetySetting(
          google_ai.SafetySetting setting) =>
      SafetySetting(
          setting.category.toVertex(),
          HarmBlockThreshold._fromGoogleAIHarmBlockThreshold(
              setting.threshold));

  /// The category for this setting.
  final HarmCategory category;

  /// Controls the probability threshold at which harm is blocked.
  final HarmBlockThreshold threshold;

  /// Convert to json format.
  Object toJson() =>
      {'category': category.toJson(), 'threshold': threshold.toJson()};
}

/// Conversion utilities for [SafetySetting].
extension SafetySettingConversion on SafetySetting {
  /// Returns this safety setting as a [google_ai.SafetySetting].
  google_ai.SafetySetting toGoogleAI() =>
      google_ai.SafetySetting(category.toGoogleAI(), threshold.toGoogleAI());
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

  const HarmBlockThreshold(this._jsonString);
  factory HarmBlockThreshold._fromGoogleAIHarmBlockThreshold(
      google_ai.HarmBlockThreshold threshold) {
    return switch (threshold) {
      google_ai.HarmBlockThreshold.unspecified =>
        HarmBlockThreshold.unspecified,
      google_ai.HarmBlockThreshold.low => HarmBlockThreshold.low,
      google_ai.HarmBlockThreshold.medium => HarmBlockThreshold.medium,
      google_ai.HarmBlockThreshold.high => HarmBlockThreshold.high,
      google_ai.HarmBlockThreshold.none => HarmBlockThreshold.none,
    };
  }
  // ignore: unused_element
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

  @override
  String toString() => name;

  /// Convert to json format.
  Object toJson() => _jsonString;
}

/// Conversion utilities for [HarmBlockThreshold].
extension HarmBlockThresholdConversion on HarmBlockThreshold {
  /// Returns this block threshold as a [toGoogleAI()].
  google_ai.HarmBlockThreshold toGoogleAI() {
    return switch (this) {
      HarmBlockThreshold.unspecified =>
        google_ai.HarmBlockThreshold.unspecified,
      HarmBlockThreshold.low => google_ai.HarmBlockThreshold.low,
      HarmBlockThreshold.medium => google_ai.HarmBlockThreshold.medium,
      HarmBlockThreshold.high => google_ai.HarmBlockThreshold.high,
      HarmBlockThreshold.none => google_ai.HarmBlockThreshold.none,
    };
  }
}

/// Conversion utilities for [google_ai.HarmBlockThreshold].
extension GoogleAIHarmBlockThresholdConversion on google_ai.HarmBlockThreshold {
  /// Returns this harm block threshold as a [HarmBlockThreshold].
  HarmBlockThreshold toVertex() => switch (this) {
        google_ai.HarmBlockThreshold.unspecified =>
          HarmBlockThreshold.unspecified,
        google_ai.HarmBlockThreshold.low => HarmBlockThreshold.low,
        google_ai.HarmBlockThreshold.medium => HarmBlockThreshold.medium,
        google_ai.HarmBlockThreshold.high => HarmBlockThreshold.high,
        google_ai.HarmBlockThreshold.none => HarmBlockThreshold.none,
      };
}

/// Configuration options for model generation and outputs.
final class GenerationConfig {
  /// Constructor
  GenerationConfig(
      {this.candidateCount,
      this.stopSequences = const [],
      this.maxOutputTokens,
      this.temperature,
      this.topP,
      this.topK,
      this.responseMimeType});

  // ignore: unused_element
  factory GenerationConfig._fromGoogleAIGenerationConfig(
          google_ai.GenerationConfig config) =>
      GenerationConfig(
          candidateCount: config.candidateCount,
          stopSequences: config.stopSequences,
          maxOutputTokens: config.maxOutputTokens,
          temperature: config.temperature,
          topP: config.topP,
          topK: config.topK,
          responseMimeType: config.responseMimeType);

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

  /// Output response mimetype of the generated candidate text.
  ///
  /// Supported mimetype:
  /// - `text/plain`: (default) Text output.
  /// - `application/json`: JSON response in the candidates.
  final String? responseMimeType;

  /// Convert to json format
  Map<String, Object?> toJson() => {
        if (candidateCount case final candidateCount?)
          'candidateCount': candidateCount,
        if (stopSequences.isNotEmpty) 'stopSequences': stopSequences,
        if (maxOutputTokens case final maxOutputTokens?)
          'maxOutputTokens': maxOutputTokens,
        if (temperature case final temperature?) 'temperature': temperature,
        if (topP case final topP?) 'topP': topP,
        if (topK case final topK?) 'topK': topK,
        if (responseMimeType case final responseMimeType?)
          'responseMimeType': responseMimeType,
      };
}

/// Conversion utilities for [GenerationConfig].
extension GenerationConfigConversion on GenerationConfig {
  /// Returns this generation config as a [google_ai.GenerationConfig].
  google_ai.GenerationConfig toGoogleAI() => google_ai.GenerationConfig(
        candidateCount: candidateCount,
        stopSequences: stopSequences,
        maxOutputTokens: maxOutputTokens,
        temperature: temperature,
        topP: topP,
        topK: topK,
        responseMimeType: responseMimeType,
      );
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

  const TaskType(this._jsonString);
  // ignore: unused_element
  factory TaskType._fromGoogleAITaskType(google_ai.TaskType type) {
    return switch (type) {
      google_ai.TaskType.unspecified => TaskType.unspecified,
      google_ai.TaskType.retrievalQuery => TaskType.retrievalQuery,
      google_ai.TaskType.retrievalDocument => TaskType.retrievalDocument,
      google_ai.TaskType.semanticSimilarity => TaskType.semanticSimilarity,
      google_ai.TaskType.classification => TaskType.classification,
      google_ai.TaskType.clustering => TaskType.clustering,
    };
  }

  // ignore: unused_element
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

  final String _jsonString;

  /// Convert to json format
  Object toJson() => _jsonString;
}

/// Conversion utilities for [TaskType].
extension TaskTypeConversion on TaskType {
  /// Returns this task type as a [google_ai.TaskType].
  google_ai.TaskType toGoogleAI() => switch (this) {
        TaskType.unspecified => google_ai.TaskType.unspecified,
        TaskType.retrievalQuery => google_ai.TaskType.retrievalQuery,
        TaskType.retrievalDocument => google_ai.TaskType.retrievalDocument,
        TaskType.semanticSimilarity => google_ai.TaskType.semanticSimilarity,
        TaskType.classification => google_ai.TaskType.classification,
        TaskType.clustering => google_ai.TaskType.clustering,
      };
}

/// Parse to [GenerateContentResponse] from json object.
GenerateContentResponse parseGenerateContentResponse(Object jsonObject) {
  google_ai.GenerateContentResponse response =
      google_ai_hooks.parseGenerateContentResponse(jsonObject);
  return response.toVertex();
}

/// Parse to [CountTokensResponse] from json object.
CountTokensResponse parseCountTokensResponse(Object jsonObject) {
  google_ai.CountTokensResponse response =
      google_ai_hooks.parseCountTokensResponse(jsonObject);
  return response.toVertex();
}

/// Parse to [EmbedContentResponse] from json object.
EmbedContentResponse parseEmbedContentResponse(Object jsonObject) {
  google_ai.EmbedContentResponse response =
      google_ai_hooks.parseEmbedContentResponse(jsonObject);
  return response.toVertex();
}

/// Parse to [BatchEmbedContentsResponse] from json object.
BatchEmbedContentsResponse parseBatchEmbedContentsResponse(Object jsonObject) {
  google_ai.BatchEmbedContentsResponse response =
      google_ai_hooks.parseBatchEmbedContentsResponse(jsonObject);
  return response.toVertex();
}
