class Contract {
    final String documentNo; // ED,년월일(6),SEQNO(2)
    final String productCode;
    final String startEmployeeNo;
    final String middleEmployeeNo;
    final String endEmployeeNo;
    final String documentTitle;
    final String documentDetail;
    final int maxQuantity;
    final int approvalState;
    final int orderingPrice;
    final String stockDate;
    final String moveDate;
    final int quantity;
    final int orderState;
    final String storeCode;

  Contract({
    required this.documentNo,
    required this.productCode,
    required this.startEmployeeNo,
    required this.middleEmployeeNo,
    required this.endEmployeeNo,
    required this.documentTitle,
    required this.documentDetail,
    required this.maxQuantity,
    required this.approvalState,
    required this.orderingPrice,
    required this.stockDate,
    required this.moveDate,
    required this.quantity,
    required this.orderState,
    required this.storeCode
  });

  Contract.fromMap(Map<String,dynamic> res)
  :documentNo = res['documentNo'],
  productCode = res['productCode'],
  startEmployeeNo = res['startEmployeeNo'],
  middleEmployeeNo = res['middleEmployeeNo'],
  endEmployeeNo = res['endEmployeeNo'],
  documentTitle = res['documentTitle'],
  documentDetail = res['documentDetail'],
  maxQuantity = res['maxQuantity'],
  approvalState = res['approvalState'],
  orderingPrice = res['orderingPrice'],
  stockDate = res['stockDate'],
  moveDate = res['moveDate'],
  quantity = res['quantity'],
  orderState = res['orderState'],
  storeCode = res['storeCode'];
} 