part of firebase_storage;

class ListResult {
  static final String ITEMS_KEY = "items";
  static final String NAME_KEY = "name";
  static final String PAGE_TOKEN_KEY = "nextPageToken";
  static final String PREFIXES_KEY = "prefixes";
  List<StorageReference> prefixes;
  List<StorageReference> items;
  String pageToken;

  ListResult(List<StorageReference> prefixes, List<StorageReference> items, String pageToken) {
    this.prefixes = prefixes;
    this.items = items;
    this.pageToken = pageToken;
  }

  /*
  static ListResult fromJSON(FirebaseStorage storage, JSONObject resultBody) {
    List<StorageReference> prefixes = new ArrayList();
    List<StorageReference> items = new ArrayList();
    JSONArray itemEntries;
    int i;
    if (resultBody.has("prefixes")) {
      itemEntries = resultBody.getJSONArray("prefixes");
      for ((i = 0); i < itemEntries.length; (++i)) {
        String pathWithoutTrailingSlash = itemEntries.getString(i);
        if (pathWithoutTrailingSlash.endsWith("/")) {
          pathWithoutTrailingSlash = pathWithoutTrailingSlash.substring(0, pathWithoutTrailingSlash.length - 1);
        }
        prefixes.add(storage.getReference(pathWithoutTrailingSlash));
      }
    }
    if (resultBody.has("items")) {
      itemEntries = resultBody.getJSONArray("items");
      for ((i = 0); i < itemEntries.length; (++i)) {
        JSONObject metadata = itemEntries.getJSONObject(i);
        items.add(storage.getReference(metadata.getString("name")));
      }
    }
    String pageToken = resultBody.optString("nextPageToken", null);
    return new ListResult(prefixes, items, pageToken);
  }
*/
  List<StorageReference> getPrefixes() {
    return this.prefixes;
  }

  List<StorageReference> getItems() {
    return this.items;
  }

  String getPageToken() {
    return this.pageToken;
  }
}
