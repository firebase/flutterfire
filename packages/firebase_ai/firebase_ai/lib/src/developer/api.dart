// Copyright 2025 Google LLC
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

import '../api.dart'
    show
        BlockReason,
        Candidate,
        Citation,
        CitationMetadata,
        CountTokensResponse,
        FinishReason,
        GenerateContentResponse,
        GenerationConfig,
        GroundingChunk,
        GroundingMetadata,
        GroundingSupport,
        HarmBlockThreshold,
        HarmCategory,
        HarmProbability,
        PromptFeedback,
        SafetyRating,
        SafetySetting,
        SearchEntryPoint,
        Segment,
        SerializationStrategy,
        WebGroundingChunk,
        parseUsageMetadata;
import '../content.dart' show Content, parseContent;
import '../error.dart';
import '../tool.dart' show Tool, ToolConfig;

HarmProbability _parseHarmProbability(Object jsonObject) =>
    switch (jsonObject) {
      'UNSPECIFIED' => HarmProbability.unknown,
      'NEGLIGIBLE' => HarmProbability.negligible,
      'LOW' => HarmProbability.low,
      'MEDIUM' => HarmProbability.medium,
      'HIGH' => HarmProbability.high,
      _ => throw unhandledFormat('HarmProbability', jsonObject),
    };
HarmCategory _parseHarmCategory(Object jsonObject) => switch (jsonObject) {
      'HARM_CATEGORY_UNSPECIFIED' => HarmCategory.unknown,
      'HARM_CATEGORY_HARASSMENT' => HarmCategory.harassment,
      'HARM_CATEGORY_HATE_SPEECH' => HarmCategory.hateSpeech,
      'HARM_CATEGORY_SEXUALLY_EXPLICIT' => HarmCategory.sexuallyExplicit,
      'HARM_CATEGORY_DANGEROUS_CONTENT' => HarmCategory.dangerousContent,
      _ => throw unhandledFormat('HarmCategory', jsonObject),
    };

FinishReason _parseFinishReason(Object jsonObject) => switch (jsonObject) {
      'UNSPECIFIED' => FinishReason.unknown,
      'STOP' => FinishReason.stop,
      'MAX_TOKENS' => FinishReason.maxTokens,
      'SAFETY' => FinishReason.safety,
      'RECITATION' => FinishReason.recitation,
      'OTHER' => FinishReason.other,
      _ => throw unhandledFormat('FinishReason', jsonObject),
    };
BlockReason _parseBlockReason(String jsonObject) => switch (jsonObject) {
      'BLOCK_REASON_UNSPECIFIED' => BlockReason.unknown,
      'SAFETY' => BlockReason.safety,
      'OTHER' => BlockReason.other,
      _ => throw unhandledFormat('BlockReason', jsonObject),
    };
String _harmBlockThresholdtoJson(HarmBlockThreshold? threshold) =>
    switch (threshold) {
      null => 'HARM_BLOCK_THRESHOLD_UNSPECIFIED',
      HarmBlockThreshold.low => 'BLOCK_LOW_AND_ABOVE',
      HarmBlockThreshold.medium => 'BLOCK_MEDIUM_AND_ABOVE',
      HarmBlockThreshold.high => 'BLOCK_ONLY_HIGH',
      HarmBlockThreshold.none => 'BLOCK_NONE',
      HarmBlockThreshold.off => 'OFF',
    };
String _harmCategoryToJson(HarmCategory harmCategory) => switch (harmCategory) {
      HarmCategory.unknown => 'HARM_CATEGORY_UNSPECIFIED',
      HarmCategory.harassment => 'HARM_CATEGORY_HARASSMENT',
      HarmCategory.hateSpeech => 'HARM_CATEGORY_HATE_SPEECH',
      HarmCategory.sexuallyExplicit => 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
      HarmCategory.dangerousContent => 'HARM_CATEGORY_DANGEROUS_CONTENT'
    };

Object _safetySettingToJson(SafetySetting safetySetting) {
  if (safetySetting.method != null) {
    throw ArgumentError(
        'HarmBlockMethod is not supported by google AI and must be left null.');
  }
  return {
    'category': _harmCategoryToJson(safetySetting.category),
    'threshold': _harmBlockThresholdtoJson(safetySetting.threshold)
  };
}

// ignore: public_member_api_docs
final class DeveloperSerialization implements SerializationStrategy {
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
    final usageMetadata = switch (jsonObject) {
      {'usageMetadata': final usageMetadata?} =>
        parseUsageMetadata(usageMetadata),
      _ => null,
    };
    return GenerateContentResponse(candidates, promptFeedback,
        usageMetadata: usageMetadata);
  }

  @override
  CountTokensResponse parseCountTokensResponse(Object jsonObject) {
    if (jsonObject case {'error': final Object error}) throw parseError(error);
    if (jsonObject case {'totalTokens': final int totalTokens}) {
      return CountTokensResponse(totalTokens);
    }
    throw unhandledFormat('CountTokensResponse', jsonObject);
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
        'safetySettings': safetySettings.map(_safetySettingToJson).toList(),
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
      {
        'generateContentRequest': generateContentRequest(
          contents,
          model,
          safetySettings,
          generationConfig,
          tools,
          toolConfig,
          null,
        )
      };
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
        _parseFinishReason(finishReason),
      _ => null
    },
    switch (jsonObject) {
      {'finishMessage': final String finishMessage} => finishMessage,
      _ => null
    },
    groundingMetadata: switch (jsonObject) {
      {'groundingMetadata': final Object groundingMetadata} =>
        _parseGroundingMetadata(groundingMetadata),
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
              _parseBlockReason(blockReason),
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

SafetyRating _parseSafetyRating(Object? jsonObject) {
  return switch (jsonObject) {
    {
      'category': final Object category,
      'probability': final Object probability
    } =>
      SafetyRating(
          _parseHarmCategory(category), _parseHarmProbability(probability)),
    _ => throw unhandledFormat('SafetyRating', jsonObject),
  };
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

GroundingMetadata _parseGroundingMetadata(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('GroundingMetadata', jsonObject);
  }

  final searchEntryPoint = switch (jsonObject) {
    {'searchEntryPoint': final Object? searchEntryPoint} =>
      _parseSearchEntryPoint(searchEntryPoint),
    _ => null,
  };
  final groundingChunks = switch (jsonObject) {
        {'groundingChunks': final List<Object?> groundingChunks} =>
          groundingChunks.map(_parseGroundingChunk).toList(),
        _ => null,
      } ??
      [];
  // Filters out null elements, which are returned from _parseGroundingSupport when
  // segment is null.
  final groundingSupport = switch (jsonObject) {
        {'groundingSupport': final List<Object?> groundingSupport} =>
          groundingSupport
              .map(_parseGroundingSupport)
              .whereType<GroundingSupport>()
              .toList(),
        _ => null,
      } ??
      [];
  final webSearchQueries = switch (jsonObject) {
        {'webSearchQueries': final List<String>? webSearchQueries} =>
          webSearchQueries,
        _ => null,
      } ??
      [];

  return GroundingMetadata(
      searchEntryPoint: searchEntryPoint,
      groundingChunks: groundingChunks,
      groundingSupport: groundingSupport,
      webSearchQueries: webSearchQueries);
}

Segment _parseSegment(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('Segment', jsonObject);
  }

  return Segment(
      partIndex: (jsonObject['partIndex'] as int?) ?? 0,
      startIndex: (jsonObject['startIndex'] as int?) ?? 0,
      endIndex: (jsonObject['endIndex'] as int?) ?? 0,
      text: (jsonObject['text'] as String?) ?? '');
}

WebGroundingChunk _parseWebGroundingChunk(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('WebGroundingChunk', jsonObject);
  }

  return WebGroundingChunk(
    uri: jsonObject['uri'] as String?,
    title: jsonObject['title'] as String?,
    domain: jsonObject['domain'] as String?,
  );
}

GroundingChunk _parseGroundingChunk(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('GroundingChunk', jsonObject);
  }

  return GroundingChunk(
    web: jsonObject['web'] != null
        ? _parseWebGroundingChunk(jsonObject['web'])
        : null,
  );
}

GroundingSupport? _parseGroundingSupport(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('GroundingSupport', jsonObject);
  }

  final segment = switch (jsonObject) {
    {'segment': final Object? segment} => _parseSegment(segment),
    _ => null,
  };
  if (segment == null) {
    return null;
  }

  return GroundingSupport(
      segment: segment,
      groundingChunkIndices:
          (jsonObject['groundingChunkIndices'] as List<int>?) ?? []);
}

SearchEntryPoint _parseSearchEntryPoint(Object? jsonObject) {
  if (jsonObject is! Map) {
    throw unhandledFormat('SearchEntryPoint', jsonObject);
  }

  final renderedContent = jsonObject['renderedContent'] as String?;
  if (renderedContent == null) {
    throw unhandledFormat('SearchEntryPoint', jsonObject);
  }

  return SearchEntryPoint(
    renderedContent: renderedContent,
  );
}
