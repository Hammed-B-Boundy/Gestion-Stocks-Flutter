import 'package:flutter/material.dart';
import 'package:my_store/services/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  String formatNumber(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  String formatDate(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      final DateFormat formatter = DateFormat('EEEE d MMMM y', 'fr_FR');
      return formatter.format(dateTime);
    } catch (e) {
      return dateTimeString; // Fallback si le parsing échoue
    }
  }

  String formatTime(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    final DateFormat formatter = DateFormat('HH:mm', 'fr_FR');
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  Future<void> _initializePage() async {
    await initializeDateFormatting('fr_FR', null); // Initialisation ici
    await _loadPayments();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPayments() async {
    final db = await DatabaseHelper.instance.database;
    final payments = await db.query(
      'payment_history',
      where: 'deletion_date IS NULL', // Ne charger que les non supprimés
      orderBy: "payment_date DESC",
    );
    setState(() {
      _payments = payments;
    });
  }

  Future<void> _loadCompleteHistory() async {
    final db = await DatabaseHelper.instance.database;
    final payments = await db.query(
      'payment_history',
      orderBy: "payment_date DESC",
    );
    setState(() {
      _payments = payments;
    });
  }

  Future<void> _deletePayment(int paymentId, int index) async {
    final db = await DatabaseHelper.instance.database;
    final payment = _payments[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer ce paiement ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        // Marquer comme supprimé dans payment_history au lieu de supprimer
        await db.update(
          'payment_history',
          {'deletion_date': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [paymentId],
        );

        setState(() {
          _payments.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historique de paiement supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HISTORIQUE DES PAIEMENTS',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadCompleteHistory(); // Charger l'historique complet
              setState(() => _isLoading = false);
            },
            tooltip: 'Voir tout l\'historique',
          ),
        ],
      ),
      body:
          _payments.isEmpty
              ? const Center(
                child: Text(
                  'Aucun paiement effectué pour le moment.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  final formattedDate = formatDate(payment['payment_date']);
                  final formattedTime = formatTime(payment['payment_date']);
                  final isDeleted = payment['deletion_date'] != null;

                  return Dismissible(
                    key: Key('${payment['id']}_${payment['deletion_date']}'),
                    direction:
                        isDeleted
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed:
                        isDeleted
                            ? null
                            : (direction) {
                              _deletePayment(payment['id'], index);
                            },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: isDeleted ? Colors.grey[200] : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          Icons.payment,
                          color:
                              isDeleted
                                  ? Colors.grey
                                  : const Color.fromARGB(255, 35, 189, 255),
                          size: 40,
                        ),
                        title: Text(
                          payment['supplier_name'],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDeleted ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Montant payé : ${formatNumber(payment['amount_paid'])} FCFA',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: isDeleted ? Colors.grey : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date : $formattedDate à $formattedTime',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontSize: 14,
                                color: isDeleted ? Colors.grey : Colors.grey,
                              ),
                            ),
                            if (isDeleted) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Archivé le ${formatDate(payment['deletion_date'])}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
