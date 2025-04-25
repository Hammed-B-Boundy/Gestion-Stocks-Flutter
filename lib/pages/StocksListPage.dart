import 'package:flutter/material.dart';
import 'package:my_store/models/stock.dart';
import 'package:my_store/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'StockDetailPage.dart';

class StocksListPage extends StatefulWidget {
  const StocksListPage({super.key});

  @override
  _StocksListPageState createState() => _StocksListPageState();
}

class _StocksListPageState extends State<StocksListPage> {
  late Database _database;
  List<Stock> _stocks = [];

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    _database = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> stockMaps = await _database.query(
      'stocks',
      orderBy:
          'date_ajout DESC', // Assurez-vous d'avoir un champ "date_ajout" dans votre table
    );

    setState(() {
      _stocks = stockMaps.map((map) => Stock.fromMap(map)).toList();
    });
  }

  Future<void> _deleteStock(int id) async {
    await _database.delete('stocks', where: 'id = ?', whereArgs: [id]);
    _loadStocks();
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text(
              'Voulez-vous vraiment supprimer ce stock ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  _deleteStock(id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

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
          'LISTE DES STOCKS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body:
          _stocks.isEmpty
              ? const Center(
                child: Text(
                  'Aucun stock disponible',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: _stocks.length,
                itemBuilder: (context, index) {
                  final stock = _stocks[index];
                  return Dismissible(
                    key: Key(stock.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      _confirmDelete(stock.id!);
                      return false;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      padding: EdgeInsets.all(5),
                      child: ListTile(
                        leading: Image.asset(
                          'images/google-docs.png',
                          width: 50,
                        ),
                        title: Text(
                          stock.supplier,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Quantité: ${stock.quantityReceived} ${stock.quantityReceivedType}',
                        ),
                        trailing: Text(
                          '${formatNumber(stock.amount)} FCFA',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 69, 150, 221),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StockDetailPage(stock: stock),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
