class TransactionItem {
  final String itemNo;  // 자리 수 2 ex (01 - 99)
  final String transactionDate;
  final String transactionNo;
  final String storeCode;
  final String buyProductCode;
  final String buyProductName;
  final int buyProductPrice;
  final int buyProductQuantity;
  final int salePrice;

  TransactionItem({
    required this.itemNo,
    required this.transactionDate,
    required this.transactionNo,
    required this.storeCode,
    required this.buyProductCode,
    required this.buyProductName,
    required this.buyProductPrice,
    required this.buyProductQuantity,
    required this.salePrice
  });

  TransactionItem.fromMap(Map<String,dynamic> res)
  :itemNo = res['itemNo'],
  transactionDate = res['transactionDate'],
  transactionNo = res['transactionNo'],
  storeCode = res['storeCode'],
  buyProductCode = res['buyProductCode'],
  buyProductName = res['buyProductName'],
  buyProductPrice = res['buyProductPrice'],
  buyProductQuantity = res['buyProductQuantity'],
  salePrice = res['salePrice'];
}