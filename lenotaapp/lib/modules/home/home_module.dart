import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lenotaapp/app_module.dart';
import 'package:lenotaapp/db.dart';
import 'package:lenotaapp/modules/home/presentation/barcode_scanner_page.dart';
import 'package:lenotaapp/modules/home/presentation/bloc/bloc/home_bloc.dart';
import 'package:lenotaapp/modules/home/presentation/home_page.dart';
import 'package:lenotaapp/modules/home/service/home_service.dart';

class HomeModule extends Module {
  @override
  void binds(i) {
    i.addSingleton<HomeService>(HomeService.new);
    i.add<AudioPlayer>(AudioPlayer.new);
    i.add<HomeBloc>(HomeBloc.new);
  }

  @override
  List<Module> get imports => [AppModule()];

  @override
  void routes(r) {
    r.child('/', child: (context) => HomePage());
    r.child('/scanner', child: (context) => const BarcodeScannerPage());
  }
}
