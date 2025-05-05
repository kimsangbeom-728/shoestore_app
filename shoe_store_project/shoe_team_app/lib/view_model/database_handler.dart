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
  Database? _database;

  Future<Database> initializeDB() async {
    if (_database != null) return _database!;

    String path = await getDatabasesPath();
    String dbFilePath = join(path, "shoestore.db");
    print("db 경로: $dbFilePath");
    _database = await openDatabase(
      join(path, 'shoestore.db'),
      onCreate: (db, version) async {
        await db.execute('''
        create table user(
          id text primary key,
          pw text,
          phone text,
          adminDate date,
          address text,
          name text
        )
        ''');
        await db.execute('''
        create table store(
          storeCode text primary key,
          storeName text,
          longitude real,
          latitude real
        )
        ''');
        await db.execute('''
        create table employee(
          employeeNo text primary key,
          pw text,
          name text,
          employeeDate date,
          position int,
          authority int,
          storeCode text
        )
        ''');
        await db.execute(
          // 수량과 카테고리는 숫자지만 text로 받는다
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
          companyCode text
        )
        ''',
        );
        await db.execute('''
        create table tranInfo (
            transactionNo text,
            transactionDate date,
            productCode text,
            userId text,
            storeCode text,
            transactionState integer,
            transactionPrice integer,
            originDate date,
            originNo text,
            returnReason text,
            review text,
            primary key (transactionNo, transactionDate, productCode, userId, storeCode)
        )
        ''');
        await db.execute(
          // orderState 0은 발주, 1은 수주, 2는 본사에서 대리점 이동
          '''
        create table contract(
          documentNo text,
          writeDate date,
          productCode text,
          startEmployeeNo text,
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
          primary key (documentNo, writeDate, productCode, startEmployeeNo)
        )
        ''',
        );
        await db.execute('''
        create table imageregister(
          productCode text,
          imageId text,
          primary key (productCode, imageId)
        )
        ''');
        await db.execute('''
        create table productimage(
          imageId text primary key,
          image blob
        )
        ''');
        await db.execute('''
        create table employeemove(
          employeeNo text,
          storeCode text,
          workDate date,
          primary key (employeeNo, storeCode)
        )
        ''');
        await db.execute('''
        create table transactionitem(
          itemNo text,
          transactionDate date,
          transactionNo text,
          storeCode text,
          buyProductCode text,
          buyProductName text,
          buyProductPrice text,
          buyProductQuantity integer,
          salePrice integer,
          primary key (itemNo, transactionDate, transactionNo)
        )
        ''');
        await db.execute('''
        create table basket(
          basketSeq integer primary key autoincrement,
          storeCode text,
          buyProductCode text,
          buyProductName text,
          buyProductPrice text,
          buyProductQuantity integer,
          salePrice integer,
          unique (storeCode)
        )
        ''');
      },
      version: 1,
    );
    return _database!;
  }

  /////////////////////////////////////////////////////////////
  /// 데이터베이스 닫기
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null; // 데이터베이스 객체를 null로 설정하여 재사용할 수 없도록 합니다.
      print("Database closed.");
    }
  }

  // 기본 쿼리(양식 보시고 바꿔서 쓰셔유)
  Future<List<User>> queryUser(String id) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from user where id = ?',
    );
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<List<Product>> queryProduct() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from product',
    );
    return queryResult.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Employee>> queryEmployee(String employeeNo) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from product where employeeNo = ?',
    );
    return queryResult.map((e) => Employee.fromMap(e)).toList();
  }

  /////////////////////////////////////////////////////////////
  /// 직원 : 권한 조회
  Future<List<Employee>> queryEmployeeAuthority(int authority) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from employee where authority = ?',
      [authority],
    );
    return queryResult.map((e) => Employee.fromMap(e)).toList();
  }

  Future<List<ProductImage>> queryProductImage(String imageId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from productimage where imageId = ?',
    );
    return queryResult.map((e) => ProductImage.fromMap(e)).toList();
  }

  Future<List<Store>> queryStore(String storeCode) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from store where storeCode = ?',
    );
    return queryResult.map((e) => Store.fromMap(e)).toList();
  }

  Future<List<Tran>> queryTransactionAll(String userId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      ''' select * 
          from transaction, store, user, product
          where store.storeCode = transaction.transactionNo
          and user.userId = transaction.userId
          and product.productCode = transaction.productCode
          and transaction.userId = ?
      ''',
    );
    return queryResult.map((e) => Tran.fromMap(e)).toList();
  }

  Future<List<TransactionItem>> queryTransactionItemAll(
    String transactionDate,
    String transactionNo,
  ) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(''' 
          select * 
          from transactionitem, transaction, store
          where transaction.transactionDate = transactionitem.transactionDate
          and transaction.transactionNo = transactionitem.transactionNo
          and store.storeCode = transactionitem.storeCode
          and transactionitem.transactionDate = ?
          and transactionitem.transactionNo = ?
      ''');
    return queryResult.map((e) => TransactionItem.fromMap(e)).toList();
  }

  Future<List<TransactionItem>> queryBasketAll() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(''' 
          select * 
          from basket, user, product
          where basket.productCode = product.productCode
          order by basket.basketSeq
      ''');
    return queryResult.map((e) => TransactionItem.fromMap(e)).toList();
  }

  /////////////////////////////////////////////////////////////
  /// 전자결제 : 기안작성자 전체 조회
  Future<List<Contract>> queryContractDocumentAll(String employee) async {
    // 결재 기준
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * '
      '  from contract, employee '
      ' where employee.employeeNo = contract.startEmployeeNo '
      '   and contract.startEmployeeNo = ? '
      ' order by documentNo',
      [employee],
    );
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }

  /////////////////////////////////////////////////////////////
  /// 전자결제 : 전자결제 대상 전체 조회 (공사중)
  // Future<List<Contract>> queryContractConfirmAll(String employee, int level) async {
  //   // 결재 기준
  //   final Database db = await initializeDB();
  //   final List<Map<String, Object?>> queryResult = await db.rawQuery(
  //     'select * '
  //     '  from contract, employee '
  //     ' where employee.employeeNo = contract.startEmployeeNo '
  //     '   and contract.startEmployeeNo = ? '
  //     ' order by documentNo',
  //     [employee],
  //   );
  //   return queryResult.map((e) => Contract.fromMap(e)).toList();
  // }

  /////////////////////////////////////////////////////////////
  /// 전자결제 : 일자별 조회
  Future<List<Contract>> queryContractDocumentDate(
    String employee,
    String date,
  ) async {
    // 결재 기준
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * '
      '  from contract, employee '
      ' where employee.employeeNo = contract.startEmployeeNo '
      '   and contract.startEmployeeNo = ? '
      '   and contract.writeDate = ? ',
      [employee, date],
    );
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }

  /////////////////////////////////////////////////////////////
  /// 전자결제 : 문서번호 조회
  Future<List<Contract>> queryContractDocumentNo(
    String employee,
    String date,
    String docNo,
  ) async {
    // 결재 기준
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * '
      '  from contract, employee '
      ' where employee.employeeNo = contract.startEmployeeNo '
      '   and contract.startEmployeeNo = ? '
      '   and contract.writeDate = ? '
      '   and contract.documentNo = ? ',
      [employee, date, docNo],
    );
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }

  /////////////////////////////////////////////////////////////
  /// 전자결제 : 문서번호 1차 승인자 결제대상 조회
  Future<List<Contract>> queryContractMiddleDocument(
    String employee,
    String date,
    String docNo,
  ) async {
    // 결재 기준
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * '
      '  from contract, employee '
      ' where employee.employeeNo = contract.startEmployeeNo '
      '   and contract.startEmployeeNo = ? '
      '   and contract.writeDate = ? '
      '   and contract.documentNo = ? '
      '   and middleEmployeeNo = ? ',
      [employee, date, docNo],
    );
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }

  /////////////////////////////////////////////////////////////
  /// 전자결제 : 조회
  Future<List<Contract>> queryContractDocument(
    String employee,
    String documentNo,
  ) async {
    // 결재 기준
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * '
      '  from contract, product, employee '
      ' where product.productCode = contract.productCode '
      '   and employee.employeeNo = contract.employeeNo '
      '   and contract.employeeNo = ? '
      '   and contract.documentNo = ? ',
      [employee, documentNo],
    );
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }

  /////////////////////////////////////////////////////////////
  // 전자결제 : 추가
  Future<int> insertContract(Contract contract) async {
    int result = 0;

    final Database db = await initializeDB();
    result = await db.rawInsert(
      'insert into contract (documentNo, writeDate, productCode, startEmployeeNo, middleEmployeeNo, '
      'endEmployeeNo, documentTitle, documentDetail, maxQuantity, approvalState, '
      'orderingPrice, stockDate, moveDate, quantity, orderState, storeCode) '
      'values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [
        contract.documentNo,
        contract.writeDate,
        contract.productCode,
        contract.startEmployeeNo,
        contract.middleEmployeeNo,
        contract.endEmployeeNo,
        contract.documentTitle,
        contract.documentDetail,
        contract.maxQuantity,
        contract.approvalState,
        contract.orderingPrice,
        contract.stockDate,
        contract.moveDate,
        contract.quantity,
        contract.orderState,
        contract.storeCode,
      ],
    );
    return result;
  }

  /////////////////////////////////////////////////////////////
  // 전자결제 : Update
  Future<int> updateContract(Contract contract) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      'update contract set middleEmployeeNo = ?, endEmployeeNo = ?, documentTitle = ?, '
      '       documentDetail = ?, maxQuantity = ?, approvalState = ?, orderingPrice = ?, stockDate = ?, '
      '       moveDate = ?, quantity = ?, orderState = ?, storeCode = ? '
      ' where documentNo = ? '
      '   and writeDate = ? '
      '   and productCode = ? '
      '   and startEmployeeNo = ?',
      [
        contract.middleEmployeeNo,
        contract.endEmployeeNo,
        contract.documentTitle,
        contract.documentDetail,
        contract.maxQuantity,
        contract.approvalState,
        contract.orderingPrice,
        contract.stockDate,
        contract.moveDate,
        contract.quantity,
        contract.orderState,
        contract.storeCode,
        contract.documentNo,
        contract.writeDate,
        contract.productCode,
        contract.startEmployeeNo,
      ],
    );
    return result;
  }

  /////////////////////////////////////////////////////////////
  // 전자결제 : 삭제
  Future<void> deleteContractDocument(String docNo) async {
    final Database db = await initializeDB();
    await db.rawDelete('delete from contract where documentNo = ?', [docNo]);
  }

  Future<List<Contract>> queryContractOrder(String orderState) async {
    // 수, 발주 기준
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(''' 
          select * 
          from contract,product,employee
          where product.productCode = contract.productCode
          and employee.employeeNo = contract.employeeNo
          and contract.orderState = ?
      ''');
    return queryResult.map((e) => Contract.fromMap(e)).toList();
  }

  Future<List<ImageRegister>> queryImageRegister(String imageId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(''' 
          select * 
          from imageregister,product,productimage
          where product.productCode = imageregister.productCode
          and productimage.imageId = imageregister.imageId
          and imageregister.imageId = ?
      ''');
    return queryResult.map((e) => ImageRegister.fromMap(e)).toList();
  }

  Future<List<EmployeeMove>> queryEmplyeeMove(String workDate) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(''' 
          select * 
          from employeemove, store, employee
          where employee.employeeNo = employeemove.employeeNo
          and store.storeCode = employee.storeCode
          and employmove.workDate = ?
      ''');
    return queryResult.map((e) => EmployeeMove.fromMap(e)).toList();
  }
}
