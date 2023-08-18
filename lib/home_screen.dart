import 'package:crud_sqlite_noteapp/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  // generar todos los datos de la base de datos

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addData() async {
    await SQLHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

// actualizar datos
  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(id, _titleController.text, _descController.text);
    _refreshData();
  }

// borrar datos
  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Borrado Exitosamente")));
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 30,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // textfield de titulo
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Titulo",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  // textfield de descripción
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Notas",
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addData();
                        }

                        if (id != null) {
                          await _updateData(id);
                        }
                        _titleController.text = "";
                        _descController.text = "";

                        // esconder boton

                        Navigator.of(context).pop();
                        print("Agregar Datos");
                      },
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(id == null ? "Agregar datos" : "Actualizar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('CRUD Notas'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: ((context, index) => Card(
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _allData[index]['title'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      subtitle: Text(_allData[index]['desc']),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        // boton para editar datos
                        IconButton(
                            onPressed: () {
                              showBottomSheet(_allData[index]['id']);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            )),

                        // boton para eliminar datos
                        IconButton(
                            onPressed: () {
                              _deleteData(_allData[index]['id']);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            )),
                      ]),
                    ),
                  )),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
