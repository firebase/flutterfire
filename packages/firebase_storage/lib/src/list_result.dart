part of firebase_storage;

class ListResult {
  ListResult({
    this.pageToken,
    this.items,
    this.prefixes,
  });

  ListResult._fromMap(Map<String, dynamic> map)
      : pageToken = map['pageToken'],
        items = map['items'].cast<String, ListResultItem>(),
        prefixes = map['prefixes'].cast<String, ListResultPrefix>();

  final String pageToken;
  final Map<String, ListResultItem> items;
  final Map<String, ListResultPrefix> prefixes;
}
