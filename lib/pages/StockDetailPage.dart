import 'package:flutter/material.dart';
import 'package:my_store/models/stock.dart';
import 'package:my_store/pages/HomePage.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';

class StockDetailPage extends StatelessWidget {
  final Stock stock;

  const StockDetailPage({super.key, required this.stock});

  String formatNumber(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DETAILS DU STOCK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home,
              size: ResponsiveHelper.getAdaptiveIconSize(context) * 1.5,
              color: Colors.orangeAccent,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getAdaptivePadding(context),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: ResponsiveHelper.getAdaptivePadding(context),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.store,
                          color: Colors.orange,
                          size:
                              ResponsiveHelper.getAdaptiveIconSize(context) *
                              1.5,
                        ),
                        title: Text(
                          stock.supplier,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getAdaptiveFontSize(
                              context,
                              22,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        subtitle: Text(
                          'Fournisseur',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: ResponsiveHelper.getAdaptiveFontSize(
                              context,
                              14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getAdaptiveSpacing(context) * 2,
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: ResponsiveHelper.getAdaptivePadding(context),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        Icons.calendar_today,
                        'Date',
                        stock.date,
                      ),
                      _buildDetailRow(
                        context,
                        Icons.inventory,
                        'Quantité reçue',
                        '${formatNumber(stock.quantityReceived)} ${stock.quantityReceivedType}',
                      ),
                      _buildDetailRow(
                        context,
                        Icons.check_circle,
                        'Quantité triée',
                        formatNumber(stock.sortedQuantity),
                      ),
                      _buildDetailRow(
                        context,
                        Icons.assignment_turned_in,
                        'Quantité exacte',
                        formatNumber(stock.exactQuantity),
                      ),
                      _buildDetailRow(
                        context,
                        Icons.attach_money,
                        'Prix unitaire',
                        '${formatNumber(stock.unitPrice)} ${stock.unitPriceType}',
                      ),
                      Divider(
                        height:
                            ResponsiveHelper.getAdaptiveSpacing(context) * 2,
                      ),
                      _buildTotalAmountRow(
                        context,
                        formatNumber(stock.amount),
                        formatNumber(stock.paidAmount),
                        formatNumber(stock.remainingAmount),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getAdaptiveSpacing(context),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blueGrey,
            size: ResponsiveHelper.getAdaptiveIconSize(context) * 1.2,
          ),
          SizedBox(width: ResponsiveHelper.getAdaptiveSpacing(context) * 1.5),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountRow(
    BuildContext context,
    String amount,
    String paidAmount,
    String remainingAmount,
  ) {
    return Container(
      padding: ResponsiveHelper.getAdaptivePadding(context),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildAmountRow(context, 'Montant Total', amount, Colors.green),
          _buildAmountRow(context, 'Montant Payé', paidAmount, Colors.blue),
          _buildAmountRow(
            context,
            'Montant Restant',
            remainingAmount,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getAdaptiveSpacing(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$value FCFA',
            style: TextStyle(
              fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
