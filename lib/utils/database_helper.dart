
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite_test/models/contact.dart';



class DataBaseHelper{
  static const _databaseName = 'ContactData.db';
  static const _databaseVersion = 1;
  
  late Database _database;
  bool _isDatabaseInitialized = false;
  
  //singelton class
  DataBaseHelper._();
  static final DataBaseHelper instance = DataBaseHelper._();

 //Getter für die Datenbankverbindung
  Future<Database> get database async{

    //Ueberpruefen ob Danenbank bereits initialisiert
    if(!_isDatabaseInitialized){
      _database = await _initDatabase();
      _isDatabaseInitialized = true;
    } 

    //Ansonsten initialisierung und zurückgeben
    
    return _database;
  }

  //Methode zur Initialisierung der Datenbank
  Future<Database>_initDatabase()async{
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    print('db location: '+dataDirectory.path);
    String dbPath = join(dataDirectory.path,_databaseName);
    return await openDatabase(dbPath, version: _databaseVersion, onCreate: _onCreateDB);
  }

  //Methode zum Erstellen der Tabelle, wenn die Datenbank erstellt wird
  Future<void> _onCreateDB(Database db, int version) async{
    await db.execute('''
    CREATE TABLE ${Contact.tblContact}(
      ${Contact.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Contact.colName} TEXT NOT NULL,
      ${Contact.colMobile} TEXT NOT NULL
    )
    ''');
  }

  // Methode zum Einfügen eines Kontakts in die Datenbank
  Future <int> insertContact(Contact contact) async{
    Database db = await database;
    return await db.insert(Contact.tblContact, contact.toMap());
  }

  //Methode zum updaten eines Kontakts
  Future <int> updateContact(Contact contact) async{
    Database db = await database;
    return await db.update(Contact.tblContact, contact.toMap(),
    where: '${Contact.colId}=?',whereArgs: [contact.id]);
  }

  //Methode loeschen eines Kontakts
  Future <int> deletContact(id) async{
    Database db = await database;
    return await db.delete(Contact.tblContact,
    where: '${Contact.colId}=?',whereArgs: [id]);
  }

  // Methode zum Abrufen aller Kontakte aus der Datenbank
  Future<List<Contact>> fetchContacts() async{
    Database db = await database;
    List<Map<String, dynamic>> contacts = await db.query(Contact.tblContact);
    if (contacts.isEmpty){
      return [];
    }else{
      return contacts.map((contactMap) => Contact.fromMap(contactMap)).toList();
    }
  }
}