import 'package:flutter/material.dart';
import 'package:my_store/models/stock.dart';
import 'package:my_store/pages/HomePage.dart';

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
        title: const Text(
          'DETAILS DU STOCK',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, size: 30, color: Colors.orangeAccent),
            onPressed: () {
              // Redirection vers la page principale
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carte principale avec le fournisseur
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.store, color: Colors.orange),
                      title: Text(
                        stock.supplier,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      subtitle: Text(
                        'Fournisseur',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informations détaillées
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.calendar_today, 'Date', stock.date),
                    _buildDetailRow(
                      Icons.inventory,
                      'Quantité reçue',
                      '${formatNumber(stock.quantityReceived)} ${stock.quantityReceivedType}',
                    ),
                    _buildDetailRow(
                      Icons.check_circle,
                      'Quantité triée',
                      formatNumber(stock.sortedQuantity),
                    ),
                    _buildDetailRow(
                      Icons.assignment_turned_in,
                      'Quantité exacte',
                      formatNumber(stock.exactQuantity),
                    ),
                    _buildDetailRow(
                      Icons.attach_money,
                      'Prix unitaire',
                      '${formatNumber(stock.unitPrice)} ${stock.unitPriceType}',
                    ),
                    const Divider(),
                    _buildTotalAmountRow(
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
    );
  }

  // Widget pour une ligne d'information avec icône
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Widget pour afficher les montants avec un design plus visible
  Widget _buildTotalAmountRow(
    String amount,
    String paidAmount,
    String remainingAmount,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildAmountRow('Montant Total', amount, Colors.green),
          _buildAmountRow('Montant Payé', paidAmount, Colors.blue),
          _buildAmountRow('Montant Restant', remainingAmount, Colors.red),
        ],
      ),
    );
  }

  // Widget pour afficher une ligne de montant stylisée
  Widget _buildAmountRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$value FCFA', // Plus besoin de toStringAsFixed(0), la valeur est déjà formatée
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
