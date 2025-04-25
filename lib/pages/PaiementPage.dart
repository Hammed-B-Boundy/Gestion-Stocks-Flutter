import 'package:flutter/material.dart';
import 'package:my_store/services/database_helper.dart';

class PaiementPage extends StatefulWidget {
  final Map<String, dynamic> fournisseur;

  const PaiementPage({super.key, required this.fournisseur});

  @override
  _PaiementPageState createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  double montantRestant = 0;
  late Map<String, dynamic> _modifiableFournisseur;
  double montantSaisi = 0;

  @override
  void initState() {
    super.initState();
    _modifiableFournisseur = Map<String, dynamic>.from(widget.fournisseur);
    montantRestant =
        _modifiableFournisseur['remaining_amount']?.toDouble() ?? 0.0;

    _montantController.addListener(_formatAmount);
  }

  void _formatAmount() {
    final text = _montantController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final number = double.tryParse(text) ?? 0.0;
      _montantController.value = _montantController.value.copyWith(
        text: formatNumber(number),
        selection: TextSelection.collapsed(offset: formatNumber(number).length),
      );
      montantSaisi = number;
    }
  }

  @override
  void dispose() {
    _montantController.removeListener(_formatAmount);
    _montantController.dispose();
    super.dispose();
  }

  String formatNumber(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  // Fonction pour convertir un montant formaté en nombre
  double parseFormattedAmount(String formattedValue) {
    return double.tryParse(formattedValue.replaceAll('.', '')) ?? 0.0;
  }

  void _effectuerPaiement() async {
    if (_formKey.currentState!.validate()) {
      // Utiliser parseFormattedAmount pour obtenir la valeur numérique
      montantSaisi = parseFormattedAmount(_montantController.text);

      if (montantSaisi > 0 && montantSaisi <= montantRestant) {
        setState(() {
          montantRestant -= montantSaisi;
          _modifiableFournisseur['paid_amount'] =
              (_modifiableFournisseur['paid_amount']?.toDouble() ?? 0.0) +
              montantSaisi;
          _modifiableFournisseur['remaining_amount'] = montantRestant;
        });

        final db = await DatabaseHelper.instance.database;

        await db.transaction((txn) async {
          // 1. Mettre à jour le fournisseur dans la table `suppliers`
          await txn.update(
            'suppliers',
            {
              'paid_amount': _modifiableFournisseur['paid_amount'],
              'remaining_amount': _modifiableFournisseur['remaining_amount'],
            },
            where: 'id = ?',
            whereArgs: [_modifiableFournisseur['id']],
          );

          // 2. Enregistrer dans payments dans la table `payments`
          await txn.insert('payments', {
            'supplier_id': _modifiableFournisseur['id'],
            'supplier_name': _modifiableFournisseur['name'],
            'amount_paid': montantSaisi,
            'payment_date': DateTime.now().toIso8601String(),
          });

          // 3. Enregistrer dans payment_history
          await txn.insert('payment_history', {
            'supplier_id': _modifiableFournisseur['id'],
            'supplier_name': _modifiableFournisseur['name'],
            'amount_paid': montantSaisi,
            'payment_date': DateTime.now().toIso8601String(),
            'deletion_date': null, // Pas encore supprimé
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Paiement effectué avec succès !",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context, _modifiableFournisseur);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              montantSaisi <= 0
                  ? "Le montant doit être supérieur à 0 !"
                  : "Le montant ne peut pas dépasser ${formatNumber(montantRestant)} FCFA !",
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PAIEMENT",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Montant restant à payer : ${formatNumber(montantRestant)} FCFA",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Montant à payer",
                  border: OutlineInputBorder(),
                  suffixText: "FCFA",
                ),
                validator: (value) {
                  final unformattedValue = value?.replaceAll('.', '') ?? '';
                  if (unformattedValue.isEmpty) {
                    return "Veuillez entrer un montant";
                  }
                  final montant = double.tryParse(unformattedValue);
                  if (montant == null) {
                    return "Veuillez entrer un montant valide";
                  }
                  if (montant <= 0) {
                    return "Le montant doit être supérieur à 0";
                  }
                  if (montant > montantRestant) {
                    return "Le montant ne peut dépasser ${formatNumber(montantRestant)} FCFA";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _effectuerPaiement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    // Ajoutez cette propriété
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Valider le paiement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
