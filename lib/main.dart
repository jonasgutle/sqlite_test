import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sqlite_test/models/contact.dart';
import 'package:sqlite_test/utils/database_helper.dart';

const darkBlueColor = Color(0xff486579);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite CRUD',
      theme: ThemeData(
        primaryColor: darkBlueColor,
        //useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'SQLite CRUD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  late DataBaseHelper _dbHelper;
  List<Contact> _contacts = [];
  Contact _contact = Contact();
  final _ctrlName = TextEditingController();
  final _ctrlMobil = TextEditingController();
 
  @override
  void initState(){
    super.initState();
    // Initialisierung von _dbHelper im initState
    setState(() {
      _dbHelper  = DataBaseHelper.instance;
    });
    _refreshContactList(); // Aufruf der Methode zum Aktualisieren der Kontaktliste
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Center(
          child: Text(widget.title,
          style: TextStyle(color: darkBlueColor)
          ),          
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _form(),
            _list(),
          ],
        ),
      ),
    );
  }

  //Funktionen
  _form() =>Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
    child: Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _ctrlName,
            decoration: InputDecoration(labelText: 'Full Name'),
            onSaved: (newValue) => setState(() => _contact.name = newValue),
            validator:(value) => (value?.isEmpty ?? true ? 'This field is required':null),
          ),
          TextFormField(
            controller: _ctrlMobil,
            decoration: InputDecoration(labelText: 'Mobile'),
            //"newValue" wird uebergeben und entspricht dem Inhalt des Textfeldes
            //dieser wird nun in Contact.mobild geschrieben
            onSaved: (newValue) => setState(() => _contact.mobile = newValue),
            // "val==null" wurde initialisiert? "value.istEmpty" ist der Wert 0?
            validator:(value) {
              if (value == null || value.isEmpty || value.length < 10){
                return 'At least 10 characters';
              }
              return null;
            },
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: ()=> _onSubmit(),
              child: Text('Submit'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
                foregroundColor: MaterialStateProperty.all(Colors.white)
              )


            ),
          )

        ],
      ),
    ),
  );

  _refreshContactList() async{
    List<Contact> x = await _dbHelper.fetchContacts();
    setState(() {
      _contacts = x;
    });
  }

  _onSubmit()async{
    //schreibt den aktuellen Zustand des Formulars zurueck
    var form = _formKey.currentState;
    if (form != null && form.validate() )
    {
     //.save ruft "onSave" auf
     form.save();
     if(_contact.id == null){
      await _dbHelper.insertContact(_contact);
     }
     else{
      await _dbHelper.updateContact(_contact);
     }


     _refreshContactList();
     _resetForm();
    }
  }

  _resetForm(){
    setState(() {
      _formKey.currentState?.reset();
      _ctrlName.clear();
      _ctrlMobil.clear();
      _contact.id = null;
    });
  }

  _list() => Expanded(
    child: Card(
      margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.account_circle,
                color: darkBlueColor, size: 40.0),
                title: Text(_contacts[index].name!.toUpperCase(),
                  style: const TextStyle(
                    color: darkBlueColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_contacts[index].mobile!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_sweep, color: darkBlueColor),
                    onPressed: ()async{
                      await _dbHelper.deletContact(_contacts[index].id);
                      _resetForm();
                      _refreshContactList();
                    },
                  ),
                  onTap: (){
                    setState(() {
                      //aktueler Kontakt
                      _contact = _contacts[index];
                      _ctrlName.text = _contacts[index].name.toString();
                      _ctrlMobil.text = _contacts[index].mobile.toString();
                    });
                  },
              ),
              const Divider(
                height: 5.0,
              )
            ],
          );
        },
      ),
    ),
  );
}