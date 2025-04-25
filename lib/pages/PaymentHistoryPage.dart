import 'package:flutter/material.dart';
import 'package:my_store/services/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';

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
      return dateTimeString;
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
    await initializeDateFormatting('fr_FR', null);
    await _loadPayments();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPayments() async {
    final db = await DatabaseHelper.instance.database;
    final payments = await db.query(
      'payment_history',
      where: 'deletion_date IS NULL',
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
            title: Text(
              'Confirmer la suppression',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Voulez-vous vraiment supprimer ce paiement ?',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Supprimer',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
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
          SnackBar(
            content: Text(
              'Historique de paiement supprimé avec succès',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la suppression: ${e.toString()}',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
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
        title: Text(
          'HISTORIQUE DES PAIEMENTS',
          style: TextStyle(
            fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              size: ResponsiveHelper.getAdaptiveIconSize(context),
            ),
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadCompleteHistory();
              setState(() => _isLoading = false);
            },
            tooltip: 'Voir tout l\'historique',
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child:
            _payments.isEmpty
                ? Center(
                  child: Text(
                    'Aucun paiement effectué pour le moment.',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(
                        context,
                        16,
                      ),
                      color: Colors.grey,
                    ),
                  ),
                )
                : ListView.builder(
                  padding: ResponsiveHelper.getAdaptivePadding(context),
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
                        padding: EdgeInsets.only(
                          right:
                              ResponsiveHelper.getAdaptiveSpacing(context) * 2,
                        ),
                        color: Colors.red,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: ResponsiveHelper.getAdaptiveIconSize(context),
                        ),
                      ),
                      onDismissed:
                          isDeleted
                              ? null
                              : (direction) {
                                _deletePayment(payment['id'], index);
                              },
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.only(
                          bottom: ResponsiveHelper.getAdaptiveSpacing(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: isDeleted ? Colors.grey[200] : null,
                        child: ListTile(
                          contentPadding: ResponsiveHelper.getAdaptivePadding(
                            context,
                          ),
                          leading: Icon(
                            Icons.payment,
                            color:
                                isDeleted
                                    ? Colors.grey
                                    : const Color.fromARGB(255, 35, 189, 255),
                            size:
                                ResponsiveHelper.getAdaptiveIconSize(context) *
                                1.5,
                          ),
                          title: Text(
                            payment['supplier_name'],
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                context,
                                18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: isDeleted ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: ResponsiveHelper.getAdaptiveSpacing(
                                  context,
                                ),
                              ),
                              Text(
                                'Montant payé : ${formatNumber(payment['amount_paid'])} FCFA',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getAdaptiveFontSize(
                                        context,
                                        16,
                                      ),
                                  color: isDeleted ? Colors.grey : null,
                                ),
                              ),
                              SizedBox(
                                height:
                                    ResponsiveHelper.getAdaptiveSpacing(
                                      context,
                                    ) /
                                    2,
                              ),
                              Text(
                                'Date : $formattedDate à $formattedTime',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getAdaptiveFontSize(
                                        context,
                                        14,
                                      ),
                                  color: isDeleted ? Colors.grey : Colors.grey,
                                ),
                              ),
                              if (isDeleted) ...[
                                SizedBox(
                                  height:
                                      ResponsiveHelper.getAdaptiveSpacing(
                                        context,
                                      ) /
                                      2,
                                ),
                                Text(
                                  'Archivé le ${formatDate(payment['deletion_date'])}',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          14,
                                        ),
                                    color: Colors.grey,
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
      ),
    );
  }
}
