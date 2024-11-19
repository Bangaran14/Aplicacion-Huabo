import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Búsqueda de Empresa',
      theme: ThemeData(
        primaryColor: Color(0xFFFBA733),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFBA733),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      home: EmpresaScreen(),
    );
  }
}

class EmpresaScreen extends StatefulWidget {
  @override
  _EmpresaScreenState createState() => _EmpresaScreenState();
}

class _EmpresaScreenState extends State<EmpresaScreen> {
  final TextEditingController _numEmpresaController = TextEditingController();
  String _resultado = "";

  void _buscarEmpresa() async {
    String numEmpresa = _numEmpresaController.text;
    if (numEmpresa.isNotEmpty && int.tryParse(numEmpresa) != null) {
      try {
        var snapshot = await FirebaseFirestore.instance
            .collection('empresas')
            .doc(numEmpresa)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data();
          String nombreEmpresa = data?['NombreEmpresa'] ?? "Nombre no disponible";
          String asistente = data?['Asistente'] ?? "Asistente no disponible";

          setState(() {
            _resultado = "Nombre de la Empresa:\n$nombreEmpresa\n\nAsistente:\n$asistente";
          });
        } else {
          setState(() {
            _resultado = "No se encontró la empresa con el número $numEmpresa.";
          });
        }
      } catch (e) {
        setState(() {
          _resultado = "Error al buscar la empresa: $e";
        });
      }
    } else {
      setState(() {
        _resultado = "Por favor ingrese un número de empresa válido.";
      });
    }
  }

  void _mostrarAsistentes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AsistentesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo-icon.png',
              height: 80,
            ),
            SizedBox(width: 8),
            Text("Búsqueda de Empresa", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              // Código para pantalla de ayuda
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFBA733),
              Color(0xFFFFD789),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 280, // Ajusta este valor al ancho deseado
                  ),
                  child: TextField(
                    controller: _numEmpresaController,
                    decoration: InputDecoration(
                      labelText: 'Número de Empresa',
                      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),

              SizedBox(height: 16),
              // Botón "Buscar" centrado y con ancho ajustado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150, // Ajusta el ancho aquí
                    child: ElevatedButton(
                      onPressed: _buscarEmpresa,
                      child: Text("Buscar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
             
             Center( // Alinea todo el texto en el centro
              child: Text(
                _resultado,
                textAlign: TextAlign.center, // Centra el texto horizontalmente
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),


              Spacer(),
              // Botón "Mostrar Asistentes" centrado y con ancho ajustado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300, // Ajusta el ancho aquí
                    child: ElevatedButton(
                      onPressed: _mostrarAsistentes,
                      child: Text("Mostrar Asistentes", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class AsistentesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asistentes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFBA733),
              Color(0xFFFFD789),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('empresas').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              Map<String, int> asistentesMap = {};

              for (var empresa in snapshot.data!.docs) {
                String asistente = empresa['Asistente']?.toString() ?? "Asistente desconocido";

                if (asistentesMap.containsKey(asistente)) {
                  asistentesMap[asistente] = asistentesMap[asistente]! + 1;
                } else {
                  asistentesMap[asistente] = 1;
                }
              }

              List<MapEntry<String, int>> asistentesList = asistentesMap.entries.toList();

              if (asistentesList.isEmpty) {
                return Center(child: Text("No hay asistentes disponibles.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
              }

              return ListView.builder(
  itemCount: asistentesList.length,
  itemBuilder: (context, index) {
    var asistenteEntry = asistentesList[index];
    String nombre = asistenteEntry.key;
    int cantidadEmpresas = asistenteEntry.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Center( // Centra cada elemento de la lista
        child: Text(
          "$nombre: $cantidadEmpresas",
          textAlign: TextAlign.center, // Centra el texto horizontalmente
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  },
);
            },
          ),
        ),
      ),
    );
  }
}
