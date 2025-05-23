import 'package:flutter/material.dart';
import 'package:my_store/models/stock.dart';
import 'package:my_store/services/database_helper.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';
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
  List<Stock> _filteredStocks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    _database = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> stockMaps = await _database.query(
      'stocks',
      orderBy: 'date_ajout DESC',
    );

    setState(() {
      _stocks = stockMaps.map((map) => Stock.fromMap(map)).toList();
      _filteredStocks = _stocks;
    });
  }

  void _filterStocks(String query) {
    setState(() {
      _filteredStocks =
          _stocks.where((stock) {
            final supplier = stock.supplier.toLowerCase();
            final quantity = stock.quantityReceived.toString();
            final amount = stock.amount.toString();
            return supplier.contains(query.toLowerCase()) ||
                quantity.contains(query) ||
                amount.contains(query);
          }).toList();
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
            title: Text(
              'Confirmation',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Voulez-vous vraiment supprimer ce stock ? Cette action est irréversible.',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _deleteStock(id);
                  Navigator.pop(context);
                },
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
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un stock...',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(
                        context,
                        16,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                    color: Colors.black,
                  ),
                  onChanged: _filterStocks,
                )
                : Text(
                  'LISTE DES STOCKS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 20),
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredStocks = _stocks;
                }
              });
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child:
            _filteredStocks.isEmpty
                ? Center(
                  child: Text(
                    _isSearching && _stocks.isNotEmpty
                        ? 'Aucun résultat trouvé'
                        : 'Aucun stock disponible',
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
                  itemCount: _filteredStocks.length,
                  itemBuilder: (context, index) {
                    final stock = _filteredStocks[index];
                    return Dismissible(
                      key: Key(stock.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(
                          right:
                              ResponsiveHelper.getAdaptiveSpacing(context) * 2,
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size:
                              ResponsiveHelper.getAdaptiveIconSize(context) *
                              1.5,
                        ),
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
                        padding: EdgeInsets.all(
                          ResponsiveHelper.getAdaptiveSpacing(context),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'images/google-docs.png',
                            width:
                                ResponsiveHelper.getAdaptiveIconSize(context) *
                                2,
                          ),
                          title: Text(
                            stock.supplier,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                context,
                                16,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            'Quantité: ${stock.quantityReceived} ${stock.quantityReceivedType}',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                context,
                                14,
                              ),
                            ),
                          ),
                          trailing: Text(
                            '${formatNumber(stock.amount)} FCFA',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 69, 150, 221),
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getAdaptiveFontSize(
                                context,
                                14,
                              ),
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
