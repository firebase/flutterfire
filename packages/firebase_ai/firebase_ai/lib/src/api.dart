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

import 'content.dart';
import 'error.dart';
import 'function_calling.dart' show Tool, ToolConfig;
import 'schema.dart';

/// Response for Count Tokens
final class CountTokensResponse {
  // ignore: public_member_api_docs
  CountTokensResponse(this.totalTokens,
      {this.totalBillableCharacters, this.promptTokensDetails});

  /// The number of tokens that the `model` tokenizes the `prompt` into.
  ///
  /// Always non-negative.
  final int totalTokens;

  /// The number of characters that the `model` could bill at.
  ///
  /// Always non-negative.
  final int? totalBillableCharacters;

  /// List of modalities that were processed in the request input.
  final List<ModalityTokenCount>? promptTokensDetails;
}

/// Response from the model; supports multiple candidates.
final class GenerateContentResponse {
  // ignore: public_member_api_docs
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
  /// will throw a [FirebaseAIException].
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
            throw FirebaseAIException('Response was blocked'
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
        throw FirebaseAIException(
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

  /// The inline data parts of the first candidate in [candidates], if any.
  ///
  /// Returns an empty list if there are no candidates, or if the first
  /// candidate has no [InlineDataPart] parts. There is no error thrown if the
  /// prompt or response were blocked.
  Iterable<InlineDataPart> get inlineDataParts =>
      candidates.firstOrNull?.content.parts.whereType<InlineDataPart>() ??
      const [];
}

/// Feedback metadata of a prompt specified in a [GenerativeModel] request.
final class PromptFeedback {
  // ignore: public_member_api_docs
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

/// Metadata on the generation request's token usage.
final class UsageMetadata {
  // ignore: public_member_api_docs
  UsageMetadata._(
      {this.promptTokenCount,
      this.candidatesTokenCount,
      this.totalTokenCount,
      this.promptTokensDetails,
      this.candidatesTokensDetails});

  /// Number of tokens in the prompt.
  final int? promptTokenCount;

  /// Total number of tokens across the generated candidates.
  final int? candidatesTokenCount;

  /// Total token count for the generation request (prompt + candidates).
  final int? totalTokenCount;

  /// List of modalities that were processed in the request input.
  final List<ModalityTokenCount>? promptTokensDetails;

  /// List of modalities that were returned in the response.
  final List<ModalityTokenCount>? candidatesTokensDetails;
}

/// Constructe a UsageMetadata with all it's fields.
///
/// Expose access to the private constructor for use within the package..
UsageMetadata createUsageMetadata({
  required int? promptTokenCount,
  required int? candidatesTokenCount,
  required int? totalTokenCount,
  required List<ModalityTokenCount>? promptTokensDetails,
  required List<ModalityTokenCount>? candidatesTokensDetails,
}) =>
    UsageMetadata._(
        promptTokenCount: promptTokenCount,
        candidatesTokenCount: candidatesTokenCount,
        totalTokenCount: totalTokenCount,
        promptTokensDetails: promptTokensDetails,
        candidatesTokensDetails: candidatesTokensDetails);

/// Response candidate generated from a [GenerativeModel].
final class Candidate {
  // TODO: token count?
  // ignore: public_member_api_docs
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

  /// The concatenation of the text parts of [content], if any.
  ///
  /// If this candidate was finished for a reason of [FinishReason.recitation]
  /// or [FinishReason.safety], accessing this text will throw a
  /// [GenerativeAIException].
  ///
  /// If [content] contains any text parts, this value is the concatenation of
  /// the text.
  ///
  /// If [content] does not contain any text parts, this value is `null`.
  String? get text {
    if (finishReason case FinishReason.recitation || FinishReason.safety) {
      final String suffix;
      if (finishMessage case final message? when message.isNotEmpty) {
        suffix = ': $message';
      } else {
        suffix = '';
      }
      throw FirebaseAIException(
          'Candidate was blocked due to $finishReason$suffix');
    }
    return switch (content.parts) {
      // Special case for a single TextPart to avoid iterable chain.
      [TextPart(:final text)] => text,
      final parts when parts.any((p) => p is TextPart) =>
        parts.whereType<TextPart>().map((p) => p.text).join(),
      _ => null,
    };
  }
}

/// Safety rating for a piece of content.
///
/// The safety rating contains the category of harm and the harm probability
/// level in that category for a piece of content. Content is classified for
/// safety across a number of harm categories and the probability of the harm
/// classification is included here.
final class SafetyRating {
  // ignore: public_member_api_docs
  SafetyRating(this.category, this.probability,
      {this.probabilityScore,
      this.isBlocked,
      this.severity,
      this.severityScore});

  /// The category for this rating.
  final HarmCategory category;

  /// The probability of harm for this content.
  final HarmProbability probability;

  /// The score for harm probability
  final double? probabilityScore;

  /// Whether it's blocked
  final bool? isBlocked;

  /// The severity of harm for this content.
  final HarmSeverity? severity;

  /// The score for harm severity
  final double? severityScore;
}

/// The reason why a prompt was blocked.
enum BlockReason {
  /// Default value to use when a blocking reason isn't set.
  ///
  /// Never used as the reason for blocking a prompt.
  unknown('UNKNOWN'),

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
      'BLOCK_REASON_UNSPECIFIED' => BlockReason.unknown,
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

/// The category of a rating.
///
/// These categories cover various kinds of harms that developers may wish to
/// adjust.
enum HarmCategory {
  /// Harm category is not specified.
  unknown('UNKNOWN'),

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
      'HARM_CATEGORY_UNSPECIFIED' => HarmCategory.unknown,
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

/// The probability that a piece of content is harmful.
///
/// The classification system gives the probability of the content being unsafe.
/// This does not indicate the severity of harm for a piece of content.
enum HarmProbability {
  /// A new and not yet supported value.
  unknown('UNKNOWN'),

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
      'UNSPECIFIED' => HarmProbability.unknown,
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

/// The severity that a piece of content is harmful.
///
/// Represents the severity of a [HarmCategory] being applicable in a [SafetyRating].
enum HarmSeverity {
  /// A new and not yet supported value.
  unknown('UNKNOWN'),

  /// Severity for harm is negligible..
  negligible('NEGLIGIBLE'),

  /// Low level of harm severity..
  low('LOW'),

  /// Medium level of harm severity.
  medium('MEDIUM'),

  /// High level of harm severity.
  high('HIGH');

  const HarmSeverity(this._jsonString);

  // ignore: unused_element
  static HarmSeverity _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'HARM_SEVERITY_UNSPECIFIED' => HarmSeverity.unknown,
      'HARM_SEVERITY_NEGLIGIBLE' => HarmSeverity.negligible,
      'HARM_SEVERITY_LOW' => HarmSeverity.low,
      'HARM_SEVERITY_MEDIUM' => HarmSeverity.medium,
      'HARM_SEVERITY_HIGH' => HarmSeverity.high,
      _ => throw FormatException('Unhandled HarmSeverity format', jsonObject),
    };
  }

  final String _jsonString;

  /// Convert to json format.
  String toJson() => _jsonString;

  @override
  String toString() => name;
}

/// Source attributions for a piece of content.
final class CitationMetadata {
  // ignore: public_member_api_docs
  CitationMetadata(this.citations);

  /// Citations to sources for a specific response.
  final List<Citation> citations;
}

/// Citation to a source for a portion of a specific response.
final class Citation {
  // ignore: public_member_api_docs
  Citation(this.startIndex, this.endIndex, this.uri, this.license);

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

/// Reason why a model stopped generating tokens.
enum FinishReason {
  /// Default value to use when a finish reason isn't set.
  ///
  /// Never used as the reason for finishing.
  unknown('UNKNOWN'),

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
      'UNSPECIFIED' => FinishReason.unknown,
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

/// Represents token counting info for a single modality.
final class ModalityTokenCount {
  /// Constructor
  ModalityTokenCount(this.modality, this.tokenCount);

  /// The modality associated with this token count.
  final ContentModality modality;

  /// The number of tokens counted.
  final int tokenCount;
}

/// Content part modality.
enum ContentModality {
  /// Unspecified modality.
  unspecified('MODALITY_UNSPECIFIED'),

  /// Plain text.
  text('TEXT'),

  /// Image.
  image('IMAGE'),

  /// Video.
  video('VIDEO'),

  /// Audio.
  audio('AUDIO'),

  /// Document, e.g. PDF.
  document('DOCUMENT');

  const ContentModality(this._jsonString);

  static ContentModality _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'MODALITY_UNSPECIFIED' => ContentModality.unspecified,
      'TEXT' => ContentModality.text,
      'IMAGE' => ContentModality.image,
      'VIDEO' => ContentModality.video,
      'AUDIO' => ContentModality.audio,
      'DOCUMENT' => ContentModality.document,
      _ =>
        throw FormatException('Unhandled ContentModality format', jsonObject),
    };
  }

  final String _jsonString;

  @override
  String toString() => name;

  /// Convert to json format.
  Object toJson() => _jsonString;
}

/// Safety setting, affecting the safety-blocking behavior.
///
/// Passing a safety setting for a category changes the allowed probability that
/// content is blocked.
final class SafetySetting {
  // ignore: public_member_api_docs
  SafetySetting(this.category, this.threshold, this.method);

  /// The category for this setting.
  final HarmCategory category;

  /// Controls the probability threshold at which harm is blocked.
  final HarmBlockThreshold threshold;

  /// Specify if the threshold is used for probability or severity score, if
  /// not specified it will default to [HarmBlockMethod.probability].
  final HarmBlockMethod? method;

  /// Convert to json format.
  Object toJson() => {
        'category': category.toJson(),
        'threshold': threshold.toJson(),
        if (method case final method?) 'method': method.toJson(),
      };
}

/// Probability of harm which causes content to be blocked.
///
/// When provided in [SafetySetting.threshold], a predicted harm probability at
/// or above this level will block content from being returned.
enum HarmBlockThreshold {
  /// Block when medium or high probability of unsafe content.
  low('BLOCK_LOW_AND_ABOVE'),

  /// Block when medium or high probability of unsafe content.
  medium('BLOCK_MEDIUM_AND_ABOVE'),

  /// Block when high probability of unsafe content.
  high('BLOCK_ONLY_HIGH'),

  /// Always show regardless of probability of unsafe content.
  none('BLOCK_NONE'),

  /// All content is allowed regardless of harm.
  ///
  /// metadata will not be included in the response.
  off('OFF');

  const HarmBlockThreshold(this._jsonString);

  // ignore: unused_element
  static HarmBlockThreshold _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'BLOCK_LOW_AND_ABOVE' => HarmBlockThreshold.low,
      'BLOCK_MEDIUM_AND_ABOVE' => HarmBlockThreshold.medium,
      'BLOCK_ONLY_HIGH' => HarmBlockThreshold.high,
      'BLOCK_NONE' => HarmBlockThreshold.none,
      'OFF' => HarmBlockThreshold.off,
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

/// Specifies how the block method computes the score that will be compared
/// against the [HarmBlockThreshold] in [SafetySetting].
enum HarmBlockMethod {
  /// The harm block method uses both probability and severity scores.
  severity('SEVERITY'),

  /// The harm block method uses the probability score.
  probability('PROBABILITY'),

  /// The harm block method is unspecified.
  unspecified('HARM_BLOCK_METHOD_UNSPECIFIED');

  const HarmBlockMethod(this._jsonString);

  // ignore: unused_element
  static HarmBlockMethod _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'SEVERITY' => HarmBlockMethod.severity,
      'PROBABILITY' => HarmBlockMethod.probability,
      'HARM_BLOCK_METHOD_UNSPECIFIED' => HarmBlockMethod.unspecified,
      _ =>
        throw FormatException('Unhandled HarmBlockMethod format', jsonObject),
    };
  }

  final String _jsonString;

  @override
  String toString() => name;

  /// Convert to json format.
  Object toJson() => _jsonString;
}

/// The available response modalities.
enum ResponseModalities {
  /// Text response modality.
  text('TEXT'),

  /// Image response modality.
  image('IMAGE'),

  /// Audio response modality.
  audio('AUDIO');

  const ResponseModalities(this._jsonString);
  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;
}

/// Configuration options for model generation and outputs.
abstract class BaseGenerationConfig {
  // ignore: public_member_api_docs
  BaseGenerationConfig({
    this.candidateCount,
    this.maxOutputTokens,
    this.temperature,
    this.topP,
    this.topK,
    this.presencePenalty,
    this.frequencyPenalty,
    this.responseModalities,
  });

  /// Number of generated responses to return.
  ///
  /// This value must be between [1, 8], inclusive. If unset, this will default
  /// to 1.
  final int? candidateCount;

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

  /// The penalty for repeating the same words or phrases already generated in
  /// the text.
  ///
  /// Controls the likelihood of repetition. Higher penalty values result in
  /// more diverse output.
  ///
  /// **Note:** While both [presencePenalty] and [frequencyPenalty] discourage
  /// repetition, [presencePenalty] applies the same penalty regardless of how
  /// many times the word/phrase has already appeared, whereas
  /// [frequencyPenalty] increases the penalty for *each* repetition of a
  /// word/phrase.
  ///
  /// **Important:** The range of supported [presencePenalty] values depends on
  /// the model; see the
  /// [documentation](https://firebase.google.com/docs/vertex-ai/model-parameters?platform=flutter#configure-model-parameters-gemini)
  /// for more details.
  final double? presencePenalty;

  /// The penalty for repeating words or phrases, with the penalty increasing
  /// for each repetition.
  ///
  /// Controls the likelihood of repetition. Higher values increase the penalty
  /// of repetition, resulting in more diverse output.
  ///
  /// **Note:** While both [frequencyPenalty] and [presencePenalty] discourage
  /// repetition, [frequencyPenalty] increases the penalty for *each* repetition
  /// of a word/phrase, whereas [presencePenalty] applies the same penalty
  /// regardless of how many times the word/phrase has already appeared.
  ///
  /// **Important:** The range of supported [frequencyPenalty] values depends on
  /// the model; see the
  /// [documentation](https://firebase.google.com/docs/vertex-ai/model-parameters?platform=flutter#configure-model-parameters-gemini)
  /// for more details.
  final double? frequencyPenalty;

  /// The list of desired response modalities.
  final List<ResponseModalities>? responseModalities;

  // ignore: public_member_api_docs
  Map<String, Object?> toJson() => {
        if (candidateCount case final candidateCount?)
          'candidateCount': candidateCount,
        if (maxOutputTokens case final maxOutputTokens?)
          'maxOutputTokens': maxOutputTokens,
        if (temperature case final temperature?) 'temperature': temperature,
        if (topP case final topP?) 'topP': topP,
        if (topK case final topK?) 'topK': topK,
        if (presencePenalty case final presencePenalty?)
          'presencePenalty': presencePenalty,
        if (frequencyPenalty case final frequencyPenalty?)
          'frequencyPenalty': frequencyPenalty,
        if (responseModalities case final responseModalities?)
          'responseModalities':
              responseModalities.map((modality) => modality.toJson()).toList(),
      };
}

/// Configuration options for model generation and outputs.
final class GenerationConfig extends BaseGenerationConfig {
  // ignore: public_member_api_docs
  GenerationConfig({
    super.candidateCount,
    this.stopSequences,
    super.maxOutputTokens,
    super.temperature,
    super.topP,
    super.topK,
    super.presencePenalty,
    super.frequencyPenalty,
    super.responseModalities,
    this.responseMimeType,
    this.responseSchema,
  });

  /// The set of character sequences (up to 5) that will stop output generation.
  ///
  /// If specified, the API will stop at the first appearance of a stop
  /// sequence. The stop sequence will not be included as part of the response.
  final List<String>? stopSequences;

  /// Output response mimetype of the generated candidate text.
  ///
  /// Supported mimetype:
  /// - `text/plain`: (default) Text output.
  /// - `application/json`: JSON response in the candidates.
  final String? responseMimeType;

  /// Output response schema of the generated candidate text.
  ///
  /// - Note: This only applies when the [responseMimeType] supports
  ///   a schema; currently this is limited to `application/json`.
  final Schema? responseSchema;

  @override
  Map<String, Object?> toJson() => {
        ...super.toJson(),
        if (stopSequences case final stopSequences?
            when stopSequences.isNotEmpty)
          'stopSequences': stopSequences,
        if (responseMimeType case final responseMimeType?)
          'responseMimeType': responseMimeType,
        if (responseSchema case final responseSchema?)
          'responseSchema': responseSchema.toJson(),
      };
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

// ignore: public_member_api_docs
abstract interface class SerializationStrategy {
  // ignore: public_member_api_docs
  GenerateContentResponse parseGenerateContentResponse(Object jsonObject);
  // ignore: public_member_api_docs
  CountTokensResponse parseCountTokensResponse(Object jsonObject);
  // ignore: public_member_api_docs
  Map<String, Object?> generateContentRequest(
    Iterable<Content> contents,
    ({String prefix, String name}) model,
    List<SafetySetting> safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
  );

  // ignore: public_member_api_docs
  Map<String, Object?> countTokensRequest(
    Iterable<Content> contents,
    ({String prefix, String name}) model,
    List<SafetySetting> safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  );
}

// ignore: public_member_api_docs
final class VertexSerialization implements SerializationStrategy {
  /// Parse the json to [GenerateContentResponse]
  @override
  GenerateContentResponse parseGenerateContentResponse(Object jsonObject) {
    if (jsonObject case {'error': final Object error}) throw parseError(error);
    final candidates = switch (jsonObject) {
      {'candidates': final List<Object?> candidates} =>
        candidates.map(_parseCandidate).toList(),
      _ => <Candidate>[]
    };
    final promptFeedback = switch (jsonObject) {
      {'promptFeedback': final promptFeedback?} =>
        _parsePromptFeedback(promptFeedback),
      _ => null,
    };
    final usageMedata = switch (jsonObject) {
      {'usageMetadata': final usageMetadata?} =>
        _parseUsageMetadata(usageMetadata),
      {'totalTokens': final int totalTokens} =>
        UsageMetadata._(totalTokenCount: totalTokens),
      _ => null,
    };
    return GenerateContentResponse(candidates, promptFeedback,
        usageMetadata: usageMedata);
  }

  /// Parse the json to [CountTokensResponse]
  @override
  CountTokensResponse parseCountTokensResponse(Object jsonObject) {
    if (jsonObject case {'error': final Object error}) throw parseError(error);

    if (jsonObject is! Map) {
      throw unhandledFormat('CountTokensResponse', jsonObject);
    }

    final totalTokens = jsonObject['totalTokens'] as int;
    final totalBillableCharacters = switch (jsonObject) {
      {'totalBillableCharacters': final int totalBillableCharacters} =>
        totalBillableCharacters,
      _ => null,
    };
    final promptTokensDetails = switch (jsonObject) {
      {'promptTokensDetails': final List<Object?> promptTokensDetails} =>
        promptTokensDetails.map(_parseModalityTokenCount).toList(),
      _ => null,
    };

    return CountTokensResponse(
      totalTokens,
      totalBillableCharacters: totalBillableCharacters,
      promptTokensDetails: promptTokensDetails,
    );
  }

  @override
  Map<String, Object?> generateContentRequest(
    Iterable<Content> contents,
    ({String prefix, String name}) model,
    List<SafetySetting> safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
  ) {
    return {
      'model': '${model.prefix}/${model.name}',
      'contents': contents.map((c) => c.toJson()).toList(),
      if (safetySettings.isNotEmpty)
        'safetySettings': safetySettings.map((s) => s.toJson()).toList(),
      if (generationConfig != null)
        'generationConfig': generationConfig.toJson(),
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      if (toolConfig != null) 'toolConfig': toolConfig.toJson(),
      if (systemInstruction != null)
        'systemInstruction': systemInstruction.toJson(),
    };
  }

  @override
  Map<String, Object?> countTokensRequest(
    Iterable<Content> contents,
    ({String prefix, String name}) model,
    List<SafetySetting> safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  ) =>
      // Everything except contents is ignored.
      {'contents': contents.map((c) => c.toJson()).toList()};
}

Candidate _parseCandidate(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('Candidate', jsonObject);
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
    _ => throw unhandledFormat('PromptFeedback', jsonObject),
  };
}

UsageMetadata _parseUsageMetadata(Object jsonObject) {
  if (jsonObject is! Map<String, Object?>) {
    throw unhandledFormat('UsageMetadata', jsonObject);
  }
  final promptTokenCount = switch (jsonObject) {
    {'promptTokenCount': final int promptTokenCount} => promptTokenCount,
    _ => null,
  };
  final candidatesTokenCount = switch (jsonObject) {
    {'candidatesTokenCount': final int candidatesTokenCount} =>
      candidatesTokenCount,
    _ => null,
  };
  final totalTokenCount = switch (jsonObject) {
    {'totalTokenCount': final int totalTokenCount} => totalTokenCount,
    _ => null,
  };
  final promptTokensDetails = switch (jsonObject) {
    {'promptTokensDetails': final List<Object?> promptTokensDetails} =>
      promptTokensDetails.map(_parseModalityTokenCount).toList(),
    _ => null,
  };
  final candidatesTokensDetails = switch (jsonObject) {
    {'candidatesTokensDetails': final List<Object?> candidatesTokensDetails} =>
      candidatesTokensDetails.map(_parseModalityTokenCount).toList(),
    _ => null,
  };
  return UsageMetadata._(
      promptTokenCount: promptTokenCount,
      candidatesTokenCount: candidatesTokenCount,
      totalTokenCount: totalTokenCount,
      promptTokensDetails: promptTokensDetails,
      candidatesTokensDetails: candidatesTokensDetails);
}

ModalityTokenCount _parseModalityTokenCount(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('ModalityTokenCount', jsonObject);
  }
  var modality = ContentModality._parseValue(jsonObject['modality']);

  if (jsonObject.containsKey('tokenCount')) {
    return ModalityTokenCount(modality, jsonObject['tokenCount'] as int);
  } else {
    return ModalityTokenCount(modality, 0);
  }
}

SafetyRating _parseSafetyRating(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('SafetyRating', jsonObject);
  }
  if (jsonObject.isEmpty) {
    return SafetyRating(HarmCategory.unknown, HarmProbability.unknown);
  }
  return SafetyRating(HarmCategory._parseValue(jsonObject['category']),
      HarmProbability._parseValue(jsonObject['probability']),
      probabilityScore: jsonObject['probabilityScore'] as double?,
      isBlocked: jsonObject['blocked'] as bool?,
      severity: jsonObject['severity'] != null
          ? HarmSeverity._parseValue(jsonObject['severity'])
          : null,
      severityScore: jsonObject['severityScore'] as double?);
}

CitationMetadata _parseCitationMetadata(Object? jsonObject) {
  return switch (jsonObject) {
    {'citationSources': final List<Object?> citationSources} =>
      CitationMetadata(citationSources.map(_parseCitationSource).toList()),
    // Vertex SDK format uses `citations`
    {'citations': final List<Object?> citationSources} =>
      CitationMetadata(citationSources.map(_parseCitationSource).toList()),
    _ => throw unhandledFormat('CitationMetadata', jsonObject),
  };
}

Citation _parseCitationSource(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('CitationSource', jsonObject);
  }

  final uriString = jsonObject['uri'] as String?;

  return Citation(
    jsonObject['startIndex'] as int?,
    jsonObject['endIndex'] as int?,
    uriString != null ? Uri.parse(uriString) : null,
    jsonObject['license'] as String?,
  );
}
