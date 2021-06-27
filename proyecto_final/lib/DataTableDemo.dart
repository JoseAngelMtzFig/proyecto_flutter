import 'package:flutter/material.dart';
import 'dart:async';
import 'DataBase.dart';
import 'Services.dart';

class DataTableDemo extends StatefulWidget {
  //
  DataTableDemo() : super();

  final String title = 'Lista de estudiantes';

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

// Ahora escribiremos una clase que ayudará en la búsqueda.
// Esto se llama clase Debouncer.
// He hecho otros videos explicando sobre las clases de debouncer
// El enlace se proporciona en la descripción o toca el botón 'i' en la esquina del video.
// La clase Debouncer ayuda a agregar un retraso a la búsqueda
// eso significa cuando la clase esperará a que el usuario se detenga por un tiempo definido
// y luego comienza a buscar
// Entonces, si el usuario escribe continuamente sin demora, no buscará
// Esto ayuda a mantener la aplicación más eficiente y si la búsqueda está llegando directamente al servidor
// también mantiene menos impacto en el servidor
// Vamos a escribir la clase Debouncer

class Debouncer{
  final int millisecounds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.millisecounds});
  run(VoidCallback action){
    if(null != _timer){
      _timer.cancel();//cuando el usuario escribe continuamente, esto cancela el temporizador
    }

// luego iniciaremos un nuevo temporizador buscando que el usuario se detenga
    _timer = Timer(Duration(microseconds: millisecounds), action);
  }
}

class DataTableDemoState extends State<DataTableDemo> {
  List<Employee> _employees;

// esta lista contendrá los empleados filtrados
  List<Employee> _filterEmployee;
  GlobalKey<ScaffoldState> _scaffoldKey;
  // controlador para el campo de texto de nombre que vamos a crear.
  TextEditingController _firstNameController;
  // controlador para el campo de texto de apellido que vamos a crear.
  TextEditingController _lastNameController;
  Employee _selectedEmployee;
  bool _isUpdating;
  String _titleProgress;
// esto esperará 500 milisegundos después de que el usuario haya dejado de escribir
  // esto ejerce menos presión sobre el dispositivo durante la búsqueda
  // si la búsqueda se realiza en el servidor mientras se escribe, mantiene el
  // servidor inactivo, mejorando así el rendimiento y conservando
  //duración de la batería
  final _debouncer = Debouncer(millisecounds: 200);
  //Lets increase the time to wait and search to 2 seconds


  @override
  void initState() {
    super.initState();
    _employees = [];
    _filterEmployee = [];
    _isUpdating = false;
    _titleProgress = widget.title;
    _scaffoldKey = GlobalKey(); //Clave para obtener el contexto para mostrar una SnackBar
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _getEmployees();
  }

  // Método para actualizar el título en el título de la barra de aplicaciones
  _showProgress(String message) {
    setState(() {
      _titleProgress = message;
    });
  }

  _showSnackBar(context, message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _createTable() {
    _showProgress('Creating Table...');
    Services.createTable().then((result) {
      if ('success' == result) {
        // Table is created successfully.
        _showSnackBar(context, result);
        _showProgress(widget.title);
      }
    });
  }

// Ahora vamos a agregar una empleada
  _addEmployee() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      print('Empty Fields');
      return;
    }
    _showProgress('Adding Employee...');
    Services.addEmployee(_firstNameController.text, _lastNameController.text)
        .then((result) {
      if ('success' == result) {
        _getEmployees();
// Actualizar la lista después de agregar ..
        _clearValues();
      }
    });
  }

  _getEmployees() {
    _showProgress('Loading Employees...');
    Services.getEmployees().then((employees) {
      setState(() {
        _employees = employees;
// Inicializa ti la lista del servidor al recargar ...
        _filterEmployee = employees;
      });
      _showProgress(widget.title); // Reset the title...
      print("Length ${employees.length}");
    });
  }

  _updateEmployee(Employee employee) {
    setState(() {
      _isUpdating = true;
    });
    _showProgress('Updating Employee...');
    Services.updateEmployee(
        employee.id, _firstNameController.text, _lastNameController.text)
        .then((result) {
      if ('success' == result) {
        _getEmployees(); // Refresh the list after update
        setState(() {
          _isUpdating = false;
        });
        _clearValues();
      }
    });
  }

  _deleteEmployee(Employee employee) {
    _showProgress('Deleting Employee...');
    Services.deleteEmployee(employee.id).then((result) {
      if ('success' == result) {
        _getEmployees(); // Refresh after delete...
      }
    });
  }

  //
  // Método para borrar los valores de TextField
  _clearValues() {
    _firstNameController.text = '';
    _lastNameController.text = '';
  }

  _showValues(Employee employee) {
    _firstNameController.text = employee.firstName;
    _lastNameController.text = employee.lastName;
  }


// Creemos una DataTable y mostremos la lista de empleados en ella.
  SingleChildScrollView _dataBody() {

// Vista de desplazamiento vertical y horizontal para la tabla de datos
    // desplaza tanto Vertical como Horizontal ...
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('ID'),
            ),
            DataColumn(
              label: Text('NOMBRE'),
            ),
            DataColumn(
              label: Text('NUM CONTROL'),
            ),

// Vamos a agregar una columna más para mostrar un botón de eliminar
            DataColumn(
              label: Text('DELETE'),
            )
          ],
          // La lista debería mostrar la lista filtrada ahora
          rows: _filterEmployee
              .map(
                (employee) => DataRow(cells: [
              DataCell(
                Text(employee.id),
                // Agregue tap en la fila y complete el
                // campos de texto con los valores correspondientes para actualizar
                onTap: () {
                  _showValues(employee);
                  // Establecer la empleada seleccionada para actualizar
                  _selectedEmployee = employee;
                  setState(() {
                    _isUpdating = true;
                  });
                },
              ),
              DataCell(
                Text(
                  employee.firstName.toUpperCase(),
                ),
                onTap: () {
                  _showValues(employee);
                  // Establecer la empleada seleccionada para actualizar
                  _selectedEmployee = employee;
                  // Establecer la actualización de la bandera en verdadero para indicar en el modo de actualización
                  setState(() {
                    _isUpdating = true;
                  });
                },
              ),
              DataCell(
                Text(
                  employee.lastName.toUpperCase(),
                ),
                onTap: () {
                  _showValues(employee);
                  // Establecer la empleada seleccionada para actualizar
                  _selectedEmployee = employee;
                  setState(() {
                    _isUpdating = true;
                  });
                },
              ),
              DataCell(IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteEmployee(employee);
                },
              ))
            ]),
          )
              .toList(),
        ),
      ),
    );
  }

  searchField(){
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(5.0),
          hintText: 'Filtrado',
        ),
        onChanged: (string){
          // comenzaremos a filtrar cuando el usuario escriba en el campo de texto
          // Ejecutar el antirrebote y la búsqueda de estrellas
          _debouncer.run(() {
            setState(() {
              _filterEmployee = _employees.where((u) => (u.firstName.toLowerCase().contains(string.toLowerCase()) ||
                  u.lastName.toLowerCase().contains(string.toLowerCase()))).toList();
            });
          });
        },
      ),
    );
  }




  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_titleProgress),
// mostramos el progreso en el título ...
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _createTable();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _getEmployees();
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration.collapsed(
                  hintText: 'NOMBRE',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _lastNameController,
                decoration: InputDecoration.collapsed(
                  hintText: 'NUM DE CONTROL',
                ),
              ),
            ),
            // Agregar un botón de actualización y un botón Cancelar
            // mostrar estos botones solo al actualizar un empleado
            _isUpdating
                ? Row(
              children: <Widget>[
                OutlineButton(
                  child: Text('UPDATE'),
                  onPressed: () {
                    _updateEmployee(_selectedEmployee);
                  },
                ),
                OutlineButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    setState(() {
                      _isUpdating = false;
                    });
                    _clearValues();
                  },
                ),
              ],
            )
                : Container(),
            searchField(),
            Expanded(
              child: _dataBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addEmployee();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}