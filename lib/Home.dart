import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _ControlerEdit = TextEditingController();
  Map<String, dynamic> _UltimoDadoExcluido = {};
  List _vLista = [];

  Future<File> _GetFile() async {
    /// Busca o caminho do app/ tanto no IOS, como Android
    final vDiretorio = await getApplicationDocumentsDirectory();

    ///Me retorna um objeto do tipo File.
    return File("${vDiretorio.path}/Dados.json");
  }

  void _SalvarTarefa() {
    ///Atualizo minha Lista... de acordo com o que o usuário digitou no meu ShowDialog
    Map<String, dynamic> DadosNovos = {};
    DadosNovos["titulo"] = _ControlerEdit.text;
    DadosNovos["marcado"] = false;

    /// Agora tenho uma lista de MAP...
    setState(() {
      _vLista.add(DadosNovos);
    });

    _ControlerEdit.text = "";

    ///mando salvar a minha lista atualizada..
    _SalvarArquivo();
  }

  void _SalvarArquivo() async {
    final File vArquivo = await _GetFile();

    ///converto minha lista de MAP para json e escrevo meu arquivo.
    await vArquivo.writeAsString(json.encode(_vLista));
  }

  Future<dynamic> _lerArquivo() async {
    ///Igual o Try except do delphi...
    try {
      final File vArquivo = await _GetFile();
      return vArquivo.readAsString(); //Retorna um future<String>

    } catch (e) {
      return Null;
    }
  }

  ///esse método e criado uma uníca vez na criação do Widgets - dessa forma eu leio o meu arquivo na inicialização do app e crio a minha lista com base no arquivo.
  @override
  void initState() {
    super.initState();
    _lerArquivo().then((DadosRetornadosPelaFuncaoThen) {
      if (DadosRetornadosPelaFuncaoThen != Null) {
        setState(() {
          _vLista = json.decode(DadosRetornadosPelaFuncaoThen);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///botão suspensooo
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Adicionando tarefa"),
                    content: TextField(
                      decoration: InputDecoration(labelText: "Digite Algo"),
                      keyboardType: TextInputType.text,
                      controller: _ControlerEdit,
                    ),
                    actions: <Widget>[
                      ElevatedButton.icon(
                        label: Text("Salvar"),
                        icon: Icon(Icons.save),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.purple)),
                        onPressed: () {
                          _SalvarTarefa();
                          Navigator.pop(context);

                          ///Fecha meu ShowDialog
                        },
                      ),
                      ElevatedButton.icon(
                          label: Text("Cancelar"),
                          icon: Icon(Icons.cancel),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.purple)),
                          onPressed: () {
                            //_Cancelar
                            Navigator.pop(context);

                            ///Fecha meu ShowDialog
                          })
                    ],
                  );
                });
          }),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Lista de Tarefas"),
      ),

      body: Column(children: <Widget>[
        Expanded(
            child: ListView.builder(
                itemCount: _vLista.length,
                itemBuilder: (context, i) {
                  return Dismissible(
                      key: Key(UniqueKey().toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (Direcao) {
                        if (Direcao == DismissDirection.endToStart) {
                          _UltimoDadoExcluido = _vLista[i];

                          ///Remove item da lista e salva o arquivo novamente;
                          _vLista.removeAt(i);
                          _SalvarArquivo();

                          ///Inclui  novamente o ultimo item excluido se o usuário clicou no desfazer
                          ///SnackBar - Barra que aparece na parte inferior por exemplo...
                          final vMinhaSnackBar = SnackBar(
                            content: Text("Tarefa Removida!"),
                            action: SnackBarAction(
                                label: 'Desfazer',
                                onPressed: () {
                                  ///Chamar a inclusão do item novamente
                                  setState(() {
                                    _vLista.insert(i, _UltimoDadoExcluido);
                                  });

                                  _SalvarArquivo();
                                }),
                          );

                          ///Show da minha  SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(vMinhaSnackBar);
                        }
                      },
                      background: Container(
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[Icon(Icons.delete)],
                        ),
                      ),
                      child: CheckboxListTile(
                          activeColor: Colors.purple,
                          title: Text(_vLista[i]['titulo'].toString()),
                          value: _vLista[i]['marcado'],
                          onChanged: (bool? valorAlterado) {
                            setState(() {
                              _vLista[i]['marcado'] = valorAlterado;
                            });

                            _SalvarArquivo();
                          }));
                })),
      ]),

      ///bottomNavigationBar: ,
    );
  }
}
