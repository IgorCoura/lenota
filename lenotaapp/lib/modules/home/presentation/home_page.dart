import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:lenotaapp/modules/home/domain/note.dart';
import 'package:lenotaapp/modules/home/presentation/bloc/bloc/home_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class HomePage extends StatelessWidget {
  final bloc = Modular.get<HomeBloc>();

  HomePage({super.key}) {
    bloc.add(InitialEvent());
  }

  Future<void> _showDialogConfirmRemove(String id, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remover Item"),
        content: const Text("Deseja remover o item?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () {
              bloc.add(RemoveItensEvent(id));
              Navigator.of(context).pop();
            },
            child: const Text("Sim"),
          ),
        ],
      ),
    );
  }

  Future<void> _showSharedData(BuildContext context) async {
    String dataInit = "";
    String dataFinal = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Compartilhar Dados"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Data Inicial',
                hintText: 'dd/MM/aaaa',
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                MaskTextInputFormatter(
                  mask: '##/##/####',
                  filter: {"#": RegExp(r'[0-9]')},
                  type: MaskAutoCompletionType.lazy,
                ),
              ],
              onChanged: (value) {
                dataInit = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Data Final',
                hintText: 'dd/MM/aaaa',
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                MaskTextInputFormatter(
                  mask: '##/##/####',
                  filter: {"#": RegExp(r'[0-9]')},
                  type: MaskAutoCompletionType.lazy,
                ),
              ],
              onChanged: (value) {
                dataFinal = value;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BlocBuilder<HomeBloc, HomeState>(
                  bloc: bloc,
                  builder: (context, state) {
                    return Checkbox(
                      value: state.isAllData,
                      onChanged: (bool? value) {
                        bloc.add(ChangeSharedParamsEvent(value));
                      },
                    );
                  },
                ),
                const Text("Selecionar todos os dados"),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              bloc.add(ShareEvent(dataInit, dataFinal));
              Navigator.of(context).pop();
            },
            child: const Text("Compartilhar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              "assets/img/logo.png",
              height: 50,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "LeNota",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // actions: [
        //   PopupMenuButton(
        //     icon: const Row(
        //       children: [
        //         CircleAvatar(
        //           backgroundImage: AssetImage("assets/img/avatar_default.png"),
        //         ),
        //         Icon(Icons.arrow_drop_down_sharp)
        //       ],
        //     ),
        //     itemBuilder: (BuildContext context) {
        //       return const <PopupMenuEntry>[
        //         PopupMenuItem(
        //           value: "profile",
        //           child: Text('Perfil'),
        //         ),
        //         PopupMenuItem(
        //           value: "logout",
        //           child: Text('Log out'),
        //         ),
        //       ];
        //     },
        //     onSelected: (value) async {
        //       if (value == "logout") {
        //         //TODO: Implementar o logout
        //         return;
        //       }
        //       if (value == "profile") {
        //         //TODO: Implementar a tela de perfil
        //         return;
        //       }
        //     },
        //   ),
        // ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        bloc: bloc,
        builder: (context, state) {
          return Stack(
            children: [
              Center(
                child: PagedListView<int, Note>(
                  state: state.pagingState ?? PagingState(),
                  fetchNextPage: () => bloc.add(FeatchNextPage()),
                  builderDelegate: PagedChildBuilderDelegate<Note>(
                    itemBuilder: (context, item, index) => ListTile(
                      title: Text(
                        item.data,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Text(item.scannerFormat),
                          const Text(" - "),
                          Text(
                            DateFormat('dd/MM/yyyy, HH:mm')
                                .format(item.createdAt),
                          ),
                        ],
                      ),
                      trailing: state.isEditing
                          ? IconButton(
                              color: Colors.red,
                              onPressed: () =>
                                  _showDialogConfirmRemove(item.id, context),
                              icon: const Icon(Icons.delete))
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: state.isEditing
                        ? [
                            FloatingActionButton(
                              heroTag: 'uniqueTag1',
                              onPressed: () => bloc.add(EditItensEvent()),
                              child: const Icon(Icons.close),
                            ),
                          ]
                        : [
                            FloatingActionButton(
                              heroTag: 'uniqueTag2',
                              onPressed: () {
                                Modular.to.navigate("/scanner");
                              },
                              child: const Icon(Icons.qr_code_scanner),
                            ),
                            const SizedBox(width: 20),
                            FloatingActionButton(
                              heroTag: 'uniqueTag4',
                              onPressed: () => bloc.add(EditItensEvent()),
                              child: const Icon(Icons.edit),
                            ),
                            const SizedBox(width: 20),
                            FloatingActionButton(
                              onPressed: () {
                                _showSharedData(context);
                              },
                              child: const Icon(Icons.ios_share),
                            ),
                          ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
