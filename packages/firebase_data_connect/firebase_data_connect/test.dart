abstract class Base {
  void execute();
}
class Derived extends Base {
  @override
  void execute({int arg = 0}) {
    print(arg);
  }
}
void main() {
  Derived().execute(arg: 1);
}
