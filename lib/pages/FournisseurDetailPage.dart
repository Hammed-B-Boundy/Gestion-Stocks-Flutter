import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'PaiementPage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';

class FournisseurDetailPage extends StatefulWidget {
  final Map<String, dynamic> fournisseur;

  const FournisseurDetailPage({super.key, required this.fournisseur});

  @override
  State<FournisseurDetailPage> createState() => _FournisseurDetailPageState();
}

class _FournisseurDetailPageState extends State<FournisseurDetailPage> {
  late Map<String, dynamic> _fournisseur;

  @override
  void initState() {
    super.initState();
    _fournisseur = Map<String, dynamic>.from(widget.fournisseur);
    initializeDateFormatting('fr_FR', null);
  }

  String formatNumber(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }

  String formatDate(String dateTimeString) {
    try {
      final DateTime parsed = DateTime.parse(dateTimeString);
      final formatted = DateFormat('d MMMM yyyy', 'fr_FR').format(parsed);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return dateTimeString.split(' ').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "DETAILS DU FOURNISSEUR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 20),
          ),
        ),
      ),
      body: ResponsiveWrapper(
        child: Padding(
          padding: ResponsiveHelper.getAdaptivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: ResponsiveHelper.getAdaptivePadding(context),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: ResponsiveHelper.getAdaptiveIconSize(context) * 1.2,
                    ),
                    title: Text(
                      _fournisseur['name'],
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          22,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    subtitle: Text(
                      'Fournisseur depuis le ${formatDate(_fournisseur['date_ajout'])}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getAdaptiveSpacing(context)),
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
                        Icons.attach_money,
                        'Montant Total',
                        '${formatNumber(_fournisseur['total_amount'])} FCFA',
                        Colors.green,
                      ),
                      _buildDetailRow(
                        Icons.check_circle,
                        'Montant Payé',
                        '${formatNumber(_fournisseur['paid_amount'])} FCFA',
                        Colors.blue,
                      ),
                      _buildDetailRow(
                        Icons.warning,
                        'Montant Restant',
                        '${formatNumber(_fournisseur['remaining_amount'])} FCFA',
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: ResponsiveHelper.getAdaptivePadding(context),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getAdaptiveSpacing(context) * 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaiementPage(fournisseur: _fournisseur),
                ),
              );

              if (result != null && mounted) {
                setState(() {
                  _fournisseur = Map<String, dynamic>.from(result);
                });
              }
              Navigator.pop(context, true);
            },
            child: Text(
              "Effectuer paiement",
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
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
            size: ResponsiveHelper.getAdaptiveIconSize(context),
          ),
          SizedBox(width: ResponsiveHelper.getAdaptiveSpacing(context)),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
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
