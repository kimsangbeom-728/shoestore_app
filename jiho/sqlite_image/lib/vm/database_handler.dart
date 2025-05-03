import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_image/model/address.dart';

class DatabaseHandler {
  Future<Database> initializeDB()async{
    String path = await getDatabasesPath();
    return openDatabase(
      join(path,"address.db"),
      onCreate: (db, version)async{
        await db.execute(
        "create table address(id integer primary key autoincrement, name text,phone text,address text,relation text,image blob)"
        );
      },
      version: 1
    );
  }
  Future<List<Address>>queryAddress()async{
    final Database db = await initializeDB();
    final List<Map<String, Object?>>qeuryResult = await db.rawQuery("select * from address order by name");
    return qeuryResult.map((e)=> Address.fromMap(e)).toList();
  }

  Future<int> insertAddress(Address address)async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawInsert(
      'insert into address(name, phone, address, relation, image)values(?,?,?,?,?)',
      [address.name,address.phone,address.address,address.relation,address.image]
    );
    return result;
  }

  Future<int> updateAddress(Address address)async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      'update address set name = ?,phone = ?,address = ?,relation= ? where id = ?',
      [address.name,address.phone,address.address,address.relation,address.id]
    );
    return result;
  }

  Future<int> updateAddressAll(Address address)async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      'update address set name = ?,phone = ?,address = ?,relation= ?,image=? where id = ?',
      [address.name,address.phone,address.address,address.relation,address.image, address.id]
    );
    return result;
  }

  Future<void> deleteAddress(int id)async{
    final Database db = await initializeDB();
    await db.rawDelete("delete from address where id =?",
    [id]
    );
  }




}//clasee