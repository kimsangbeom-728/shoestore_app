import 'package:shoe_team_project/model/contract.dart';
import 'package:shoe_team_project/model/employee.dart';
import 'package:shoe_team_project/model/employee_move.dart';
import 'package:shoe_team_project/model/product_image.dart';
import 'package:shoe_team_project/model/product.dart';
import 'package:shoe_team_project/model/register.dart';
import 'package:shoe_team_project/model/store.dart';
import 'package:shoe_team_project/model/transaction.dart';
import 'package:shoe_team_project/model/transaction_item.dart';
import 'package:shoe_team_project/model/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHandler {

Future<Database> initializeDB() async {
  String path = await getDatabasesPath();
  String dbFilePath = join(path,"shoestore.db");
  print("db 경로: $dbFilePath");
  return openDatabase(
    join(path, 'shoestore.db'),
    onCreate: (db, version) async {
      await db.execute(
        '''
        create table user(
          id text primary key,
          pw text,
          phone text,
          adminDate date,
          address text,
          name text
        )
        '''
      );
      await db.execute(
        '''
        create table store(
          storeCode text primary key,
          storeName text,
          longitude real,
          latitude real,
        )
        '''
      );
      await db.execute(
        '''
        create table employee(
          employeeNo text primary key,
          pw text,
          employeeDate date,
          position text,
          authority text,
          storeCode text
        )
        '''
      );
      await db.execute( // 수량과 카테고리는 숫자지만 text로 받는다
        '''
        create table product(
          productCode text primary key,
          detailCode text,
          productName text,
          quantity integer,
          color text,
          rating text,
          marginRate integer,
          price integer,
          size integer,
          image blob,
          description text,
          category text,
          productionYear text,
          companyName text,
          companyCode text,
        )
        '''
      );
      await db.execute(
        '''
        create table transaction(
          transactionNo text primary key,
          transactionDate date primary key,
          productCode text primary key,
          userId text primary key,
          storeCode text primary key,
          transactionState integer,
          transactionPrice integer,
          originDate date,
          originNo text,
          returnReason text,
          review text,
        )
        '''
      );
      await db.execute( // orderState 0은 발주, 1은 수주, 2는 본사에서 대리점 이동
        '''
        create table contract(
          documentNo text primary key,
          productCode text primary key,
          startEmployeeNo text primary key,
          middleEmployeeNo text,
          endEmployeeNo text,
          documentTitle text,
          documentDetail text,
          maxQuantity integer,
          approvalState integer,
          orderingPrice integer,
          stockDate date,
          moveDate date,
          quantity integer,
          orderState integer,
          storeCode text,
        )
        '''
      );
      await db.execute(
        '''
        create table imageregister(
          productCode text primary key,
          imageId text primary key,
        )
        '''
      );
      await db.execute(
        '''
        create table productimage(
          imageId text primary key,
          image blob,
        )
        '''
      );
      await db.execute(
        '''
        create table employeemove(
          employeeNo text primary key,
          storeCode text primary key,
          workDate date,
        )
        '''
      );
      await db.execute(
        '''
        create table transactionitem(
          itemNo text primary key,
          transactionDate date primary key,
          transactionNo text primary key,
          storeCode text,
          buyProductCode text,
          buyProductName text,
          buyProductPrice text,
          buyProductQuantity integer,
          salePrice integer,
          
        )
        '''
      );
      await db.execute(
        '''
        create table basket(
          basketSeq integer primary key autoincrement,
          storeCode text primary key,
          buyProductCode text,
          buyProductName text,
          buyProductPrice text,
          buyProductQuantity integer,
          salePrice integer,          
        )
        '''
      );
    },
    version: 1,
  );
}

// 기본 쿼리(양식 보시고 바꿔서 쓰셔유)
Future<List<User>> queryUser(String id)async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      'select * from user where id = ?'
    );
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

Future<List<Product>> queryProduct()async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      'select * from product'
    );
    return queryResult.map((e) => Product.fromMap(e)).toList();
  }

Future<List<Employee>> queryEmployee(String employeeNo)async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      'select * from product where employeeNo = ?'
    );
    return queryResult.map((e) => Employee.fromMap(e)).toList();
  }

Future<List<ProductImage>> queryProductImage(String imageId)async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      'select * from productimage where imageId = ?'
    );
    return queryResult.map((e) => ProductImage.fromMap(e)).toList();
  }
Future<List<Store>> queryStore(String storeCode)async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      'select * from store where storeCode = ?'
    );
    return queryResult.map((e) => Store.fromMap(e)).toList();
  }
Future<List<Tran>> queryTransactionAll(String userId)async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      ''' select * 
          from transaction, store, user, product
          where store.storeCode = transaction.transactionNo
          and user.userId = transaction.userId
          and product.productCode = transaction.productCode
          and transaction.userId = ?
      '''
    );
    return queryResult.map((e) => Tran.fromMap(e)).toList();
  }
Future<List<TransactionItem>> queryTransactionItemAll(String transactionDate, String transactionNo)async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      ''' 
          select * 
          from transactionitem, transaction, store
          where transaction.transactionDate = transactionitem.transactionDate
          and transaction.transactionNo = transactionitem.transactionNo
          and store.storeCode = transactionitem.storeCode
          and transactionitem.transactionDate = ?
          and transactionitem.transactionNo = ?
      '''
    );
    return queryResult.map((e) => TransactionItem.fromMap(e)).toList();
  }
Future<List<TransactionItem>> queryBasketAll()async{
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      ''' 
          select * 
          from basket, user, product
          where basket.productCode = product.productCode
          order by basket.basketSeq
      '''
    );
    return queryResult.map((e) => TransactionItem.fromMap(e)).toList();
  }
Future<List<Contract>> queryContractDocument(String documentNo)async{ // 결재 기준
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      ''' 
          select * 
          from contract,product,employee
          where product.productCode = contract.productCode
          and employee.employeeNo = contract.employeeNo
          and contract.documentNo = ?
      '''
    );
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }
Future<List<Contract>> queryContractOrder(String orderState)async{ // 수, 발주 기준
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      ''' 
          select * 
          from contract,product,employee
          where product.productCode = contract.productCode
          and employee.employeeNo = contract.employeeNo
          and contract.orderState = ?
      '''
    );
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }
Future<List<ImageRegister>> queryImageRegister(String imageId)async{ 
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      ''' 
          select * 
          from imageregister,product,productimage
          where product.productCode = imageregister.productCode
          and productimage.imageId = imageregister.imageId
          and imageregister.imageId = ?
      '''
    );
    return queryResult.map((e) => ImageRegister.fromMap(e)).toList();
  }
Future<List<EmployeeMove>> queryEmplyeeMove(String workDate)async{ 
    final Database db = await initializeDB();
    final List<Map<String,Object?>> queryResult = await db.rawQuery(
      ''' 
          select * 
          from employeemove, store, employee
          where employee.employeeNo = employeemove.employeeNo
          and store.storeCode = employee.storeCode
          and employmove.workDate = ?
      '''
    );
    return queryResult.map((e) => EmployeeMove.fromMap(e)).toList();
  }




}