class Tran {
    final String transactionNo; // 자리 수 4 (0001 - 9999) 어차피 String임
    final String transactionDate; 
    final String productCode;
    final String userId;
    final String storeCode;
    final int transactionState; // 0은 주문 확정, 1은 주문 취소, 2는 반품
    final int transactionPrice;
    final String originDate;
    final String originNo;
    final String returnReason;
    final String review;

  Tran({
    required this.transactionNo,
    required this.transactionDate,
    required this.productCode,
    required this.userId,
    required this.storeCode,
    required this.transactionState,
    required this.transactionPrice,
    required this.originDate,
    required this.originNo,
    required this.returnReason,
    required this.review,
  });

    Tran.fromMap(Map<String,dynamic> res)
    :transactionNo = res['transactionNo'],
    transactionDate = res['transactionDate'],
    productCode = res['productCode'],
    userId = res['userId'],
    storeCode = res['storeCode'],
    transactionState = res['transactionState'],
    transactionPrice = res['transactionPrice'],
    originDate = res['originDate'],
    originNo = res['originNo'],
    returnReason = res['returnReason'],
    review = res['review'];
}
