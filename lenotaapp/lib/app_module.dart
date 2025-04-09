import 'package:flutter_modular/flutter_modular.dart';
import 'package:lenotaapp/db.dart';
import 'package:lenotaapp/modules/home/home_module.dart';

class AppModule extends Module {
  @override
  void binds(i) {}

  @override
  void exportedBinds(i) {}

  @override
  void routes(r) {
    r.module('/', module: HomeModule());
  }
}
