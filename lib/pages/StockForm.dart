import 'package:flutter/material.dart';
import 'package:my_store/models/stock.dart';
import 'package:my_store/pages/StockDetailPage.dart';
import 'package:my_store/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';

class StockForm extends StatefulWidget {
  const StockForm({super.key});

  @override
  _StockFormState createState() => _StockFormState();
}

class _StockFormState extends State<StockForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs et variables pour l'étape 1
  final _supplierController = TextEditingController();
  final _quantityController = TextEditingController();
  final _sortedQuantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  List<String> _suppliers = [];
  String? _selectedSupplier;
  int _quantityReceived = 0;
  double _sortedQuantity = 0.0;
  double _exactQuantity = 0.0;
  int _unitPrice = 0;
  double _amount = 0.0;
  String _quantityCategory = 'Grosse';
  String _priceCategory = 'Gros';
  String _currentDate = "";
  bool _isNewSupplier = true;
  Database? _database;
  String? _paymentSupplier;
  final _paidAmountController = TextEditingController();
  double _paidAmount = 0.0;
  double _remainingAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _initializeDatabase();

    _quantityController.addListener(_formatQuantity);
    _sortedQuantityController.addListener(_formatSortedQuantity);
    _unitPriceController.addListener(_formatUnitPrice);
    _paidAmountController.addListener(_formatPaidAmount);
  }

  void _formatQuantity() {
    final text = _quantityController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final number = int.tryParse(text) ?? 0;
      _quantityController.value = _quantityController.value.copyWith(
        text: formatNumber(number),
        selection: TextSelection.collapsed(offset: formatNumber(number).length),
      );
      _quantityReceived = number;
    }
  }

  void _formatSortedQuantity() {
    final text = _sortedQuantityController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final number = double.tryParse(text) ?? 0.0;
      _sortedQuantityController
          .value = _sortedQuantityController.value.copyWith(
        text: formatNumber(number),
        selection: TextSelection.collapsed(offset: formatNumber(number).length),
      );
      _sortedQuantity = number;
      _calculateExactQuantity();
    }
  }

  void _formatUnitPrice() {
    final text = _unitPriceController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final number = int.tryParse(text) ?? 0;
      _unitPriceController.value = _unitPriceController.value.copyWith(
        text: formatNumber(number),
        selection: TextSelection.collapsed(offset: formatNumber(number).length),
      );
      _unitPrice = number;
      _calculateExactQuantity();
    }
  }

  void _formatPaidAmount() {
    final text = _paidAmountController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final number = double.tryParse(text) ?? 0.0;
      _paidAmountController.value = _paidAmountController.value.copyWith(
        text: formatNumber(number),
        selection: TextSelection.collapsed(offset: formatNumber(number).length),
      );

      setState(() {
        _paidAmount = number;
        // Appeler la mise à jour avec contrôle
        if (_paidAmount > _amount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Le montant payé ne peut pas dépasser le montant total",
                style: TextStyle(
                  fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                ),
              ),
            ),
          );
          _paidAmount = _amount;
          _paidAmountController.text = formatNumber(_amount);
        }
        _remainingAmount = _amount - _paidAmount;
      });
    }
  }

  double parseFormattedValue(String formattedValue) {
    return double.tryParse(formattedValue.replaceAll('.', '')) ?? 0.0;
  }

  void _initializeDateFormatting() async {
    await initializeDateFormatting('fr_FR', null);
    setState(() {
      _currentDate = DateFormat('d MMMM y', 'fr_FR').format(DateTime.now());
    });
  }

  void _initializeDatabase() async {
    _database = await DatabaseHelper.instance.database;
    _loadSuppliers();
  }

  void _loadSuppliers() async {
    if (_database == null) return;
    final List<Map<String, dynamic>> maps = await _database!.query('suppliers');
    setState(() {
      _suppliers = maps.map((e) => e['name'].toString()).toList();
      if (_isNewSupplier &&
          _supplierController.text.isNotEmpty &&
          !_suppliers.contains(_supplierController.text)) {
        _suppliers.add(_supplierController.text);
      }
      _paymentSupplier =
          _isNewSupplier ? _supplierController.text : _selectedSupplier;
    });
  }

  void _calculateExactQuantity() {
    final unitPriceValue = _unitPrice;

    setState(() {
      // Correction du calcul de la quantité exacte
      _exactQuantity = (_quantityReceived - _sortedQuantity).abs();

      // Calcul du montant total (toujours positif)
      _amount = (_exactQuantity * unitPriceValue).abs();

      _updateRemainingAmount();
    });
  }

  void _updateRemainingAmount() {
    setState(() {
      // Garantir que le montant restant est toujours positif
      _remainingAmount = (_amount - _paidAmount).abs();

      // Si le montant payé dépasse le total, ajuster l'affichage
      if (_paidAmount > _amount) {
        _remainingAmount = 0;
      }
    });
  }

  String formatNumber(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  @override
  void dispose() {
    _quantityController.removeListener(_formatQuantity);
    _sortedQuantityController.removeListener(_formatSortedQuantity);
    _unitPriceController.removeListener(_formatUnitPrice);
    _paidAmountController.removeListener(_formatPaidAmount);
    _quantityController.dispose();
    _sortedQuantityController.dispose();
    _unitPriceController.dispose();
    _paidAmountController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_database == null) return;

    if (_formKey.currentState!.validate()) {
      String supplierName =
          _isNewSupplier ? _supplierController.text : _selectedSupplier!;

      if (_sortedQuantity > _quantityReceived) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "La quantité triée ne peut pas dépasser la quantité reçue",
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
          ),
        );
        return;
      }

      if (_paidAmount < 0 || _amount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Les montants ne peuvent pas être négatifs",
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
          ),
        );
        return;
      }

      if (_paidAmount > _amount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Le montant payé ne peut pas dépasser le montant total",
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
          ),
        );
        return;
      }

      List<Map<String, dynamic>> supplierData = await _database!.query(
        'suppliers',
        where: 'name = ?',
        whereArgs: [supplierName],
      );

      if (supplierData.isEmpty) {
        await _database!.insert('suppliers', {
          'name': supplierName,
          'total_amount': _amount,
          'paid_amount': _paidAmount,
          'remaining_amount': _remainingAmount,
        });
      } else {
        double existingTotal = supplierData.first['total_amount'] ?? 0.0;
        double existingPaid = supplierData.first['paid_amount'] ?? 0.0;
        double existingRemaining =
            supplierData.first['remaining_amount'] ?? 0.0;

        double newTotal = existingTotal + _amount;
        double newPaid = existingPaid + _paidAmount;
        double newRemaining = existingRemaining + _remainingAmount;

        await _database!.update(
          'suppliers',
          {
            'total_amount': newTotal,
            'paid_amount': newPaid,
            'remaining_amount': newRemaining,
          },
          where: 'name = ?',
          whereArgs: [supplierName],
        );
      }

      // Ajouter le stock
      final stock = Stock(
        id: null,
        supplier: supplierName,
        date: _currentDate,
        quantityReceived: _quantityReceived,
        quantityReceivedType: _quantityCategory,
        sortedQuantity: _sortedQuantity,
        exactQuantity: _exactQuantity,
        unitPrice: _unitPrice,
        unitPriceType: _priceCategory,
        amount: _amount,
        paidAmount: _paidAmount,
        remainingAmount: _remainingAmount,
      );

      final stockId = await _database!.insert('stocks', stock.toMap());

      // Ajouter le paiement si un montant a été payé
      if (_paidAmount > 0) {
        await _database!.insert('payments', {
          'supplier_id':
              supplierData.isNotEmpty ? supplierData.first['id'] : null,
          'supplier_name': supplierName,
          'amount_paid': _paidAmount,
          'payment_date': DateTime.now().toIso8601String(),
        });

        // Ajouter dans l'historique des paiements
        await _database!.insert('payment_history', {
          'supplier_id':
              supplierData.isNotEmpty ? supplierData.first['id'] : null,
          'supplier_name': supplierName,
          'amount_paid': _paidAmount,
          'payment_date': DateTime.now().toIso8601String(),
          'deletion_date': null,
        });
      }

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Stock ajouté avec succès !",
            style: TextStyle(
              fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Rediriger vers la page de détails du stock
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => StockDetailPage(
                  stock: Stock(
                    id: stockId,
                    supplier: supplierName,
                    date: _currentDate,
                    quantityReceived: _quantityReceived,
                    quantityReceivedType: _quantityCategory,
                    sortedQuantity: _sortedQuantity,
                    exactQuantity: _exactQuantity,
                    unitPrice: _unitPrice,
                    unitPriceType: _priceCategory,
                    amount: _amount,
                    paidAmount: _paidAmount,
                    remainingAmount: _remainingAmount,
                  ),
                ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AJOUTER UN STOCK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 20),
          ),
        ),
      ),
      body: ResponsiveWrapper(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() {
                  _currentStep += 1;
                });
              } else {
                _saveData();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            steps: [
              Step(
                title: Text(
                  'Informations de base',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: Image.asset(
                              "images/add-user.png",
                              width: 30,
                              height: 30,
                            ),
                            value: true,
                            groupValue: _isNewSupplier,
                            onChanged: (value) {
                              setState(() {
                                _isNewSupplier = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: Image.asset(
                              "images/drop-down-arrow.png",
                              width: 30,
                              height: 30,
                            ),
                            value: false,
                            groupValue: _isNewSupplier,
                            onChanged: (value) {
                              setState(() {
                                _isNewSupplier = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_isNewSupplier)
                      TextFormField(
                        controller: _supplierController,
                        decoration: InputDecoration(
                          labelText: 'Nom du fournisseur',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveHelper.getAdaptiveFontSize(
                              context,
                              16,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom du fournisseur';
                          }
                          return null;
                        },
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedSupplier,
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un fournisseur',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveHelper.getAdaptiveFontSize(
                              context,
                              16,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                        items:
                            _suppliers.map((String supplier) {
                              return DropdownMenuItem<String>(
                                value: supplier,
                                child: Text(supplier),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSupplier = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un fournisseur';
                          }
                          return null;
                        },
                      ),
                    SizedBox(
                      height: ResponsiveHelper.getAdaptiveSpacing(context),
                    ),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantité reçue',
                        labelStyle: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                        suffixText: _quantityCategory,
                        suffixStyle: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la quantité reçue';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAdaptiveSpacing(context),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Gros',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                  context,
                                  16,
                                ),
                              ),
                            ),
                            value: 'Gros',
                            groupValue: _quantityCategory,
                            onChanged: (value) {
                              setState(() {
                                _quantityCategory = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Moyen',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                  context,
                                  16,
                                ),
                              ),
                            ),
                            value: 'Moyen',
                            groupValue: _quantityCategory,
                            onChanged: (value) {
                              setState(() {
                                _quantityCategory = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: Text(
                  'Détails du stock',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _sortedQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantité triée',
                        labelStyle: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la quantité triée';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAdaptiveSpacing(context),
                    ),
                    TextFormField(
                      controller: _unitPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Prix unitaire',
                        labelStyle: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                        suffixText: _priceCategory,
                        suffixStyle: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prix unitaire';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAdaptiveSpacing(context),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Gros',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                  context,
                                  16,
                                ),
                              ),
                            ),
                            value: 'Gros',
                            groupValue: _priceCategory,
                            onChanged: (value) {
                              setState(() {
                                _priceCategory = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Moyen',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                  context,
                                  16,
                                ),
                              ),
                            ),
                            value: 'Moyen',
                            groupValue: _priceCategory,
                            onChanged: (value) {
                              setState(() {
                                _priceCategory = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAdaptiveSpacing(context),
                    ),
                    Card(
                      child: Padding(
                        padding: ResponsiveHelper.getAdaptivePadding(context),
                        child: Column(
                          children: [
                            Text(
                              'Résumé',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                  context,
                                  18,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getAdaptiveSpacing(
                                context,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantité exacte:',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                  ),
                                ),
                                Text(
                                  formatNumber(_exactQuantity),
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getAdaptiveSpacing(
                                context,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Montant total:',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                  ),
                                ),
                                Text(
                                  '${formatNumber(_amount)} FCFA',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: Text(
                  'Paiement',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _paidAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Montant payé',
                        labelStyle: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                        suffixText: 'FCFA',
                        suffixStyle: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            16,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le montant payé';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAdaptiveSpacing(context),
                    ),
                    Card(
                      child: Padding(
                        padding: ResponsiveHelper.getAdaptivePadding(context),
                        child: Column(
                          children: [
                            Text(
                              'Résumé du paiement',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                  context,
                                  18,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getAdaptiveSpacing(
                                context,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Montant total:',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                  ),
                                ),
                                Text(
                                  '${formatNumber(_amount)} FCFA',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getAdaptiveSpacing(
                                context,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Montant payé:',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                  ),
                                ),
                                Text(
                                  '${formatNumber(_paidAmount)} FCFA',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getAdaptiveSpacing(
                                context,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Montant restant:',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                  ),
                                ),
                                Text(
                                  '${formatNumber(_remainingAmount)} FCFA',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
