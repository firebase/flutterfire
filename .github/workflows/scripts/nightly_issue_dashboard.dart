// Copyright 2026 Google LLC
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

import 'dart:convert';
import 'dart:io';

void main() async {
  final env = Platform.environment;
  final token = env['GITHUB_TOKEN'];
  final repo = env['REPO'];
  final androidStatus = env['ANDROID_STATUS'] ?? 'skipped';
  final webStatus = env['WEB_STATUS'] ?? 'skipped';
  final iosStatus = env['IOS_STATUS'] ?? 'skipped';
  final macosStatus = env['MACOS_STATUS'] ?? 'skipped';
  final windowsStatus = env['WINDOWS_STATUS'] ?? 'skipped';
  final fdcStatus = env['FDC_STATUS'] ?? 'skipped';
  final pipelineStatus = env['PIPELINE_STATUS'] ?? 'skipped';
  final runId = env['GITHUB_RUN_ID'];
  final serverUrl = env['GITHUB_SERVER_URL'] ?? 'https://github.com';

  if (token == null || repo == null) {
    print('Error: GITHUB_TOKEN or REPO environment variables not set.');
    exit(1);
  }

  final date = DateTime.now().toUtc().toString().substring(0, 10);
  final runUrl = '$serverUrl/$repo/actions/runs/$runId';
  final notes = '[View Run]($runUrl)';

  final androidIcon = _getIcon(androidStatus);
  final webIcon = _getIcon(webStatus);
  final iosIcon = _getIcon(iosStatus);
  final macosIcon = _getIcon(macosStatus);
  final windowsIcon = _getIcon(windowsStatus);
  final fdcIcon = _getIcon(fdcStatus);
  final pipelineIcon = _getIcon(pipelineStatus);

  final newRow =
      '| $date | $androidIcon | $iosIcon | $webIcon | $macosIcon | $windowsIcon | $fdcIcon | $pipelineIcon | $notes |';

  print('New Row: $newRow');

  final client = HttpClient();
  try {
    final issueNumber = await _findIssue(client, token, repo);

    if (issueNumber == null) {
      print('Issue not found. Creating a new one.');
      await _createIssue(client, token, repo, newRow);
    } else {
      print('Found issue #$issueNumber. Updating.');
      await _updateIssue(client, token, repo, issueNumber, newRow);
    }
  } finally {
    client.close();
  }
}

String _getIcon(String status) {
  switch (status) {
    case 'success':
      return '✅ Pass';
    case 'failure':
      return '❌ Failure';
    case 'cancelled':
      return '⚪ Cancelled';
    case 'skipped':
      return '➖ Skipped';
    default:
      return '❓ Unknown';
  }
}

Future<int?> _findIssue(HttpClient client, String token, String repo) async {
  final url = Uri.parse(
    'https://api.github.com/repos/$repo/issues?labels=nightly-testing&state=open',
  );
  final request = await client.getUrl(url);
  _addHeaders(request, token);

  final response = await request.close();
  if (response.statusCode != 200) {
    print('Failed to search issues: ${response.statusCode}');
    return null;
  }

  final body = await response.transform(utf8.decoder).join();
  final json = jsonDecode(body) as List;

  for (final issue in json) {
    if (issue['title'] == '[FlutterFire] Nightly Integration Testing Report') {
      return issue['number'] as int;
    }
  }
  return null;
}

Future<void> _createIssue(
  HttpClient client,
  String token,
  String repo,
  String newRow,
) async {
  final url = Uri.parse('https://api.github.com/repos/$repo/issues');
  final request = await client.postUrl(url);
  _addHeaders(request, token);

  final body = {
    'title': '[FlutterFire] Nightly Integration Testing Report',
    'labels': ['nightly-testing'],
    'body':
        '''
## Testing History (last 30 days)

| Date | Android | iOS | Web | MacOS | Windows | FDC | Pipeline | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
$newRow
''',
  };

  request.add(utf8.encode(jsonEncode(body)));
  final response = await request.close();
  if (response.statusCode != 201) {
    print('Failed to create issue: ${response.statusCode}');
    final respBody = await response.transform(utf8.decoder).join();
    print('Response: $respBody');
  } else {
    print('Issue created successfully.');
  }
}

Future<void> _updateIssue(
  HttpClient client,
  String token,
  String repo,
  int issueNumber,
  String newRow,
) async {
  final getUrl = Uri.parse(
    'https://api.github.com/repos/$repo/issues/$issueNumber',
  );
  final getRequest = await client.getUrl(getUrl);
  _addHeaders(getRequest, token);

  final getResponse = await getRequest.close();
  if (getResponse.statusCode != 200) {
    print('Failed to fetch issue #$issueNumber: ${getResponse.statusCode}');
    return;
  }

  final getBody = await getResponse.transform(utf8.decoder).join();
  final issueJson = jsonDecode(getBody);
  String currentBody = issueJson['body'] ?? '';

  final updatedBody = _appendRow(currentBody, newRow);

  final patchUrl = Uri.parse(
    'https://api.github.com/repos/$repo/issues/$issueNumber',
  );
  final patchRequest = await client.patchUrl(patchUrl);
  _addHeaders(patchRequest, token);

  final patchBody = {'body': updatedBody};
  patchRequest.add(utf8.encode(jsonEncode(patchBody)));

  final patchResponse = await patchRequest.close();
  if (patchResponse.statusCode != 200) {
    print('Failed to update issue #$issueNumber: ${patchResponse.statusCode}');
    final respBody = await patchResponse.transform(utf8.decoder).join();
    print('Response: $respBody');
  } else {
    print('Issue #$issueNumber updated successfully.');
  }
}

String _appendRow(String currentBody, String newRow) {
  final lines = currentBody.split('\n');
  final tableRows = <String>[];
  var inTable = false;

  for (final line in lines) {
    if (line.startsWith('| Date |')) {
      inTable = true;
      continue;
    }
    if (inTable && line.startsWith('|')) {
      if (line.startsWith('| ---') || line.startsWith('| :---')) {
        continue;
      }
      tableRows.add(line);
    }
  }

  tableRows.add(newRow);

  if (tableRows.length > 30) {
    tableRows.removeRange(0, tableRows.length - 30);
  }

  final newBodyLines = <String>[];
  var processedTable = false;

  for (final line in lines) {
    if (line.startsWith('| Date |')) {
      if (!processedTable) {
        newBodyLines.add(
          '| Date | Android | iOS | Web | MacOS | Windows | FDC | Pipeline | Notes |',
        );
        newBodyLines.add(
          '| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |',
        );
        newBodyLines.addAll(tableRows);
        processedTable = true;
      }
      inTable = true;
      continue;
    }
    if (inTable && line.startsWith('|')) {
      continue;
    }
    inTable = false;
    newBodyLines.add(line);
  }

  if (!processedTable) {
    newBodyLines.add('## Testing History (last 30 days)');
    newBodyLines.add('');
    newBodyLines.add(
      '| Date | Android | iOS | Web | MacOS | Windows | FDC | Pipeline | Notes |',
    );
    newBodyLines.add(
      '| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |',
    );
    newBodyLines.add(newRow);
  }

  return newBodyLines.join('\n');
}

void _addHeaders(HttpClientRequest request, String token) {
  request.headers.add('Authorization', 'token $token');
  request.headers.add('Accept', 'application/vnd.github.v3+json');
  request.headers.add('User-Agent', 'dart-script');
  request.headers.contentType = ContentType.json;
}
