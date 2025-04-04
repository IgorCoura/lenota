import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lenotaapp/modules/home/domain/note.dart';
import 'package:lenotaapp/modules/home/presentation/barcode_scanner.dart';
import 'package:lenotaapp/modules/home/presentation/bloc/bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  final bloc = Modular.get<HomeBloc>();

  HomePage({super.key}) {
    bloc.add(InitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lenota'),
        actions: [
          PopupMenuButton(
            icon: const Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage("assets/img/avatar_default.png"),
                ),
                Icon(Icons.arrow_drop_down_sharp)
              ],
            ),
            itemBuilder: (BuildContext context) {
              return const <PopupMenuEntry>[
                PopupMenuItem(
                  value: "profile",
                  child: Text('Perfil'),
                ),
                PopupMenuItem(
                  value: "logout",
                  child: Text('Log out'),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == "logout") {
                //TODO: Implementar o logout
                return;
              }
              if (value == "profile") {
                //TODO: Implementar a tela de perfil
                return;
              }
            },
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<HomeBloc, HomeState>(
          bloc: bloc,
          builder: (context, state) {
            return PagedListView<int, Note>(
              state: state.pagingState ?? PagingState(),
              fetchNextPage: () => bloc.add(FeatchNextPage()),
              builderDelegate: PagedChildBuilderDelegate<Note>(
                  itemBuilder: (context, item, index) => ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.content),
                      )),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const BarcodeScanner()));
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
