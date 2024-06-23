class Contact{
  static const tblContact = 'contacts';
  static const colId = 'id';
  static const colName = 'name';
  static const colMobile = 'mobile';

  //Konstruktor {Parameter optional}
  // Aufruf des Konstruktors waere:
  //var X = Contact(id: 0, name: "Mayer", mobile: "12345");
  Contact({this.id,this.name,this.mobile});

  //mit "this." werden die Parameter des Konstruktors mit den Variablen initialisiert
  int? id;
  String? name;
  String? mobile;

  //wandelt eine Map in den Typ Contact um
  Contact.fromMap(Map<String, dynamic> map){
    id = map[colId];
    name = map[colName];
    mobile = map[colMobile];
  }

  //gibt eine Map zurueck, die in die DB gespeichert werden kann
  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{colName: name, colMobile: mobile};
    if (id != null) map[colId] = id;
    return map;
  }
}

