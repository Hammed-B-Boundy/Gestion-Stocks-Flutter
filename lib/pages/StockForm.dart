import 'package:flutter/material.dart';
import 'package:my_store/models/stock.dart';
import 'package:my_store/pages/StockDetailPage.dart';
import 'package:my_store/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  bool _isNewSupplier = true; // Saisie ou sélection de fournisseur
  Database? _database;
  // Variables pour l'étape 3 "Paiement"
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

  // Ajoutez ces méthodes pour gérer le formatage
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
      _unitPrice = number; // Stocke la valeur numérique
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
        _remainingAmount = _amount - _paidAmount;
      });
    }
  }

  // Méthode pour convertir le format affiché en valeur numérique
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
      // Si un fournisseur a été saisi à l'étape 1 et n'est pas dans la liste, on l'ajoute
      if (_isNewSupplier &&
          _supplierController.text.isNotEmpty &&
          !_suppliers.contains(_supplierController.text)) {
        _suppliers.add(_supplierController.text);
      }
      // Par défaut, pour l'étape paiement, on sélectionne le fournisseur saisi ou sélectionné en étape 1
      _paymentSupplier =
          _isNewSupplier ? _supplierController.text : _selectedSupplier;
    });
  }

  void _calculateExactQuantity() {
    // Utilise parseFormattedValue pour obtenir la valeur numérique du prix unitaire
    final unitPriceValue = _unitPrice; // Déjà numérique grâce au validateur

    setState(() {
      _exactQuantity = (_quantityReceived - _sortedQuantity).toDouble();
      _amount = _exactQuantity * unitPriceValue;
      _updateRemainingAmount();
    });
  }

  void _updateRemainingAmount() {
    _remainingAmount = _amount - _paidAmount;
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

  // Dans la méthode _saveData, après l'ajout du stock, revenez à la page d'accueil
  void _saveData() async {
    if (_database == null) return;

    if (_formKey.currentState!.validate()) {
      String supplierName =
          _isNewSupplier ? _supplierController.text : _selectedSupplier!;

      // Vérification supplémentaire des quantités
      if (_sortedQuantity > _quantityReceived) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La quantité triée ne peut pas dépasser la quantité reçue",
            ),
          ),
        );
        return;
      }

      // Vérification du montant payé
      if (_paidAmount > _amount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Le montant payé ne peut pas dépasser le montant total",
            ),
          ),
        );
        return;
      }

      // Vérifier si le fournisseur existe déjà
      List<Map<String, dynamic>> supplierData = await _database!.query(
        'suppliers',
        where: 'name = ?',
        whereArgs: [supplierName],
      );

      if (supplierData.isEmpty) {
        // Si le fournisseur n'existe pas, on l'ajoute
        await _database!.insert('suppliers', {
          'name': supplierName,
          'total_amount': _amount,
          'paid_amount': _paidAmount,
          'remaining_amount': _remainingAmount,
        });
      } else {
        // Si le fournisseur existe, on met à jour ses montants
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

      // Enregistrer le stock
      int stockId = await _database!.insert('stocks', {
        'supplier': supplierName,
        'date': _currentDate,
        'quantity_received': _quantityReceived,
        'quantity_received_type': _quantityCategory,
        'sorted_quantity': _sortedQuantity,
        'exact_quantity': _exactQuantity,
        'unit_price': _unitPrice,
        'unit_price_type': _priceCategory,
        'amount': _amount,
        'paid_amount': _paidAmount,
        'remaining_amount': _remainingAmount,
      });

      // Réinitialiser les champs après l'ajout
      _supplierController.clear();
      _quantityReceived = 0;
      _quantityCategory = 'Grosse';
      _sortedQuantity = 0;
      _exactQuantity = 0;
      _unitPrice = 0;
      _priceCategory = 'Gros';
      _amount = 0;
      _paidAmount = 0;
      _remainingAmount = 0;
      _isNewSupplier = false;
      _selectedSupplier = null;

      setState(() {});

      // Récupérer et afficher les détails du stock
      List<Map<String, dynamic>> stockData = await _database!.query(
        'stocks',
        where: 'id = ?',
        whereArgs: [stockId],
      );

      if (stockData.isNotEmpty) {
        Stock newStock = Stock.fromMap(stockData.first);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailPage(stock: newStock),
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
          'AJOUTER UN STOCK',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && _formKey.currentState!.validate()) {
            setState(() {
              _currentStep = 1;
            });
          } else if (_currentStep == 1) {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _currentStep = 2;
                // Pour l'étape Paiement, pré-remplir le fournisseur avec celui de l'étape 1
                _paymentSupplier =
                    _isNewSupplier
                        ? _supplierController.text
                        : _selectedSupplier;
              });
            }
          } else if (_currentStep == 2) {
            _saveData();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                if (_currentStep != 0)
                  GestureDetector(
                    onTap: details.onStepCancel,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF0082B9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Précédent',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: details.onStepContinue,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFF0082B9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Enregistrer' : 'Suivant',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          // Étape 1 : Informations générales
          Step(
            title: const Text("Informations générales"),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Section Fournisseur
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Fournisseur",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Boutons radio pour choisir entre nouveau et sélection
                          Row(
                            children: [
                              Radio(
                                value: true,
                                groupValue: _isNewSupplier,
                                onChanged: (value) {
                                  setState(() {
                                    _isNewSupplier = value as bool;
                                    _selectedSupplier = null;
                                  });
                                },
                              ),
                              const Text(
                                "Nouveau",
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 20),
                              Radio(
                                value: false,
                                groupValue: _isNewSupplier,
                                onChanged: (value) {
                                  setState(() {
                                    _isNewSupplier = value as bool;
                                    _supplierController.clear();
                                  });
                                },
                              ),
                              const Text(
                                "Sélectionner",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_isNewSupplier)
                            TextFormField(
                              controller: _supplierController,
                              decoration: const InputDecoration(
                                labelText: "Nom du fournisseur",
                                border: OutlineInputBorder(),
                                hintText: "Saisissez le nom du fournisseur",
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Veuillez saisir un fournisseur";
                                }
                                if (value.trim().length < 2) {
                                  return "Le nom doit contenir au moins 2 caractères";
                                }
                                if (RegExp(r'[0-9]').hasMatch(value)) {
                                  return "Le nom ne doit pas contenir de chiffres";
                                }
                                return null;
                              },
                            )
                          else
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Sélectionner un fournisseur",
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedSupplier,
                              items:
                                  _suppliers.map((String supplier) {
                                    return DropdownMenuItem(
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
                                  return "Veuillez sélectionner un fournisseur";
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Section Quantité reçue
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Quantité reçue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: "Quantité reçue",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final unformattedValue =
                                  value?.replaceAll('.', '') ?? '';
                              if (unformattedValue.trim().isEmpty) {
                                return "Veuillez entrer une quantité";
                              }
                              final quantity = int.tryParse(unformattedValue);
                              if (quantity == null) {
                                return "Veuillez entrer un nombre valide";
                              }
                              if (quantity <= 0) {
                                return "La quantité doit être supérieure à 0";
                              }
                              _quantityReceived = quantity;
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Boutons radio pour la catégorie de quantité
                          Row(
                            children: [
                              Radio(
                                value: "Grosse",
                                groupValue: _quantityCategory,
                                onChanged: (value) {
                                  setState(() {
                                    _quantityCategory = value.toString();
                                  });
                                },
                              ),
                              const Text(
                                "Grosse",
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 20),
                              Radio(
                                value: "Moyenne",
                                groupValue: _quantityCategory,
                                onChanged: (value) {
                                  setState(() {
                                    _quantityCategory = value.toString();
                                  });
                                },
                              ),
                              const Text(
                                "Moyenne",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Section Quantité produits triés
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Quantité produits triés",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _sortedQuantityController,
                            decoration: const InputDecoration(
                              labelText: "Quantité produits triés",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Veuillez entrer une quantité";
                              }
                              final quantity = double.tryParse(
                                value.replaceAll('.', ''),
                              );
                              if (quantity == null) {
                                return "Veuillez entrer un nombre valide";
                              }
                              if (quantity < 0) {
                                return "La quantité ne peut pas être négative";
                              }
                              if (quantity > _quantityReceived) {
                                return "Ne peut pas dépasser la quantité reçue";
                              }
                              setState(() {
                                _sortedQuantity = quantity;
                                _calculateExactQuantity(); // Ajoutez cette ligne
                              });
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isActive: _currentStep == 0,
          ),
          // Étape 2 : Tarification
          Step(
            title: const Text("Tarification"),
            content: Column(
              children: [
                TextFormField(
                  controller: _unitPriceController,
                  decoration: const InputDecoration(
                    labelText: "Prix unitaire",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final unformattedValue = value?.replaceAll('.', '') ?? '';
                    if (unformattedValue.isEmpty) {
                      return "Veuillez entrer un prix";
                    }
                    final price = int.tryParse(unformattedValue);
                    if (price == null) {
                      return "Veuillez entrer un nombre valide";
                    }
                    if (price <= 0) {
                      return "Le prix doit être supérieur à 0";
                    }
                    setState(() {
                      _unitPrice = price; // Stocke la valeur numérique
                      _calculateExactQuantity(); // Force le recalcul
                    });
                    return null;
                  },
                  // onChanged: (value) {
                  //   setState(() {
                  //     _unitPrice = int.tryParse(value) ?? 0;
                  //     _calculateExactQuantity();
                  //   });
                  // },
                  onChanged: (value) {
                    final unformattedValue = value.replaceAll('.', '');
                    final number = int.tryParse(unformattedValue) ?? 0;
                    setState(() {
                      _unitPrice = number;
                      _calculateExactQuantity();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      value: "Gros",
                      groupValue: _priceCategory,
                      onChanged: (value) {
                        setState(() {
                          _priceCategory = value.toString();
                        });
                      },
                    ),
                    const Text("Gros", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 20),
                    Radio(
                      value: "Moyen",
                      groupValue: _priceCategory,
                      onChanged: (value) {
                        setState(() {
                          _priceCategory = value.toString();
                        });
                      },
                    ),
                    const Text("Moyen", style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Quantité exacte",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: formatNumber(_exactQuantity),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Montant",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: formatNumber(
                      _amount.toInt(),
                    ), // Convertir en int et formater
                  ),
                ),
              ],
            ),
            isActive: _currentStep == 1,
          ),
          // Étape 3 : Paiement
          Step(
            title: const Text("Paiement"),
            content: Column(
              children: [
                // Champ de saisie du fournisseur (lecture seule)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Fournisseur",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Champ non modifiable
                  controller: TextEditingController(
                    text:
                        _isNewSupplier
                            ? _supplierController.text
                            : _selectedSupplier ?? "",
                  ),
                ),
                const SizedBox(height: 10),
                // Champ de saisie du montant payé
                TextFormField(
                  controller: _paidAmountController,
                  decoration: const InputDecoration(
                    labelText: "Montant payé",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final unformattedValue = value?.replaceAll('.', '') ?? '';
                    if (unformattedValue.trim().isEmpty) {
                      return "Veuillez entrer un montant";
                    }
                    final amount = double.tryParse(unformattedValue);
                    if (amount == null) {
                      return "Veuillez entrer un nombre valide";
                    }
                    if (amount < 0) {
                      return "Le montant ne peut pas être négatif";
                    }
                    if (amount > _amount) {
                      return "Ne peut pas dépasser le montant total";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final unformattedValue = value.replaceAll('.', '');
                    final number = double.tryParse(unformattedValue) ?? 0.0;
                    setState(() {
                      _paidAmount = number;
                      _remainingAmount = _amount - _paidAmount;
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Affichage du montant restant (lecture seule)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Montant restant",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    //text: _remainingAmount.toStringAsFixed(2),
                    text: formatNumber(_remainingAmount),
                  ),
                ),
              ],
            ),
            isActive: _currentStep == 2,
          ),
        ],
      ),
    );
  }
}
