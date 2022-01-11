abstract class Template<T> {
  String generate(T data);

  bool accepts(T data) => true;
}
