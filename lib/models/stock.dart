class Stock {
  int? id;
  String supplier;
  String date;
  int quantityReceived;
  String quantityReceivedType;
  double sortedQuantity;
  double exactQuantity;
  int unitPrice;
  String unitPriceType;
  double amount;
  double paidAmount;
  double remainingAmount;

  Stock({
    this.id,
    required this.supplier,
    required this.date,
    required this.quantityReceived,
    required this.quantityReceivedType,
    required this.sortedQuantity,
    required this.exactQuantity,
    required this.unitPrice,
    required this.unitPriceType,
    required this.amount,
    required this.paidAmount,
    required this.remainingAmount,
  });

  // Convertir un objet Stock en une Map pour l'insertion dans la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier': supplier,
      'date': date,
      'quantity_received': quantityReceived,
      'quantity_received_type': quantityReceivedType,
      'sorted_quantity': sortedQuantity,
      'exact_quantity': exactQuantity,
      'unit_price': unitPrice,
      'unit_price_type': unitPriceType,
      'amount': amount,
    };
  }

  // Convertir une Map en un objet Stock
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      supplier: map['supplier'],
      date: map['date'],
      quantityReceived: map['quantity_received'],
      quantityReceivedType: map['quantity_received_type'],
      sortedQuantity: map['sorted_quantity'],
      exactQuantity: map['exact_quantity'],
      unitPrice: map['unit_price'],
      unitPriceType: map['unit_price_type'],
      amount: map['amount'],
      paidAmount: map['paid_amount'],
      remainingAmount: map['remaining_amount'],
    );
  }
}
