import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_final/DataTableDemo.dart';
import 'DataBase.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;


void main(){
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: Text('Bienvenido'),
          ),
          body: SafeArea(
            child: MyApp(),
          ),
        ),
      )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool signin = true;

  TextEditingController namectrl,emailctrl,passctrl;

  bool processing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    namectrl = new TextEditingController();
    emailctrl = new TextEditingController();
    passctrl = new TextEditingController();

  }
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Icon(Icons.account_circle_outlined,size: 200,color: Colors.blue,),

            boxUi(),
          ],
        )
    );
  }

  void changeState(){
    if(signin){
      setState(() {
        signin = false;

      });
    }else
      setState(() {
        signin = true;

      });
  }
  void registerUser() async{

    setState(() {
      processing = true;
    });
    var url = "https://proyecto00002.000webhostapp.com/login_flutter/signup.php";
    var data = {
      "email":emailctrl.text,
      "name":namectrl.text,
      "pass":passctrl.text,
    };

    var res = await http.post(url,body:data);

    if(jsonDecode(res.body) == "cuenta existente"){
      Fluttertoast.showToast(msg: "cuenta existente, por favor inicie sesión",toastLength: Toast.LENGTH_LONG);


    }else{

      if(jsonDecode(res.body) == "true"){
        Fluttertoast.showToast(msg: "cuenta creada",toastLength: Toast.LENGTH_SHORT);
      }else{
        Fluttertoast.showToast(msg: "error",toastLength: Toast.LENGTH_SHORT);
      }
    }
    setState(() {
      processing = false;
    });
  }

  void userSignIn() async{
    var ruta = DataTableDemo();
    setState(() {
      processing = true;
    });
    var url = "https://proyecto00002.000webhostapp.com/login_flutter/signin.php";
    var data = {
      "email":emailctrl.text,
      "pass":passctrl.text,
    };

    var res = await http.post(url,body:data);

    if(jsonDecode(res.body) == "No tiene una cuenta"){
      Fluttertoast.showToast(msg: "no tienes una cuenta, crea una cuenta",toastLength: Toast.LENGTH_SHORT);
    }
    else{
      if(jsonDecode(res.body) == "false"){
        Fluttertoast.showToast(msg: "contraseña incorrecta",toastLength: Toast.LENGTH_SHORT);
      }
      else{
        print(jsonDecode(res.body));
        Navigator.push(context, MaterialPageRoute(builder: (context) => ruta));

        //aqui
      }
    }

    setState(() {
      processing = false;
    });
  }

  Widget boxUi(){
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                FlatButton(
                  onPressed:() => changeState(),
                  child: Text('Iniciar Sesion',
                    style: GoogleFonts.varelaRound(
                      color: signin == true ? Colors.blue : Colors.grey,
                      fontSize: 20.0,fontWeight: FontWeight.bold,
                    ),),
                ),

                FlatButton(
                  onPressed:() => changeState(),
                  child: Text('Registro',
                    style: GoogleFonts.varelaRound(
                      color: signin != true ? Colors.blue : Colors.grey,
                      fontSize: 20,fontWeight: FontWeight.bold,
                    ),),
                ),
              ],
            ),

            signin == true ? signInUi() : signUpUi(),

          ],
        ),
      ),
    );
  }

  Widget signInUi(){
    return Column(
      children: <Widget>[

        TextField(
          controller: emailctrl,
          decoration: InputDecoration(prefixIcon: Icon(Icons.account_box,),
              hintText: 'correo electronico'),
        ),


        TextField(
          controller: passctrl,
          decoration: InputDecoration(prefixIcon: Icon(Icons.lock,),
              hintText: 'contraseña'),
        ),

        SizedBox(height: 10.0,),

        MaterialButton(
            onPressed:() => userSignIn(),
            child: processing == false ? Text('Iniciar Sesion',
              style: GoogleFonts.varelaRound(fontSize: 20.0,
                  color: Colors.blue),) : CircularProgressIndicator(backgroundColor: Colors.red,)
        ),

      ],
    );
  }

  Widget signUpUi(){
    return Column(
      children: <Widget>[

        TextField(
          controller: namectrl,
          decoration: InputDecoration(prefixIcon: Icon(Icons.account_box,),
              hintText: 'name'),
        ),

        TextField(
          controller: emailctrl,
          decoration: InputDecoration(prefixIcon: Icon(Icons.account_box,),
              hintText: 'correo electronico'),
        ),


        TextField(
          controller: passctrl,
          decoration: InputDecoration(prefixIcon: Icon(Icons.lock,),
              hintText: 'contraseña'),
        ),

        SizedBox(height: 20.0,),

        MaterialButton(
            onPressed:() => registerUser(),
            child: processing == false ? Text('Registrarse',
              style: GoogleFonts.varelaRound(fontSize: 20.0,
                  color: Colors.blue),) : CircularProgressIndicator(backgroundColor: Colors.red)
        ),

      ],
    );
  }

}