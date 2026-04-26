import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils.dart';
import 'detail_varian_page.dart';

class StockAdminPage extends StatefulWidget {
  const StockAdminPage({super.key});

  @override
  State<StockAdminPage> createState() => _StockAdminPageState();
}

class _StockAdminPageState extends State<StockAdminPage> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> allData = [];
  bool isLoading = true;
  String? errorMessage;
  
  int totalStock = 0;
  int totalGws = 0;
  int totalNonGws = 0;
  String lastUpdate = "";
  int totalVarian = 0;
  int variantNotInData = 0;
  
  final String adminName = "Ujang Cahyono Nurpiqih";
  bool isSummaryExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() { isLoading = true; errorMessage = null; });
      
      List<Map<String, dynamic>> allDataList = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      
      while (hasMore) {
        final response = await Supabase.instance.client
            .from('stock_master')
            .select()
            .range(start, start + batchSize - 1);
        allDataList.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) { hasMore = false; } else { start += batchSize; }
      }
      
      totalStock = 0;
      totalGws = 0;
      totalNonGws = 0;
      totalVarian = allDataList.length;
      
      for (var item in allDataList) {
        totalStock += (item['stock'] ?? 0) as int;
        totalGws += (item['gws'] ?? 0) as int;
        totalNonGws += (item['non_gws'] ?? 0) as int;
      }
      
      variantNotInData = totalStock - (totalGws + totalNonGws);
      lastUpdate = Utils.getFormattedDateTime();
      
      setState(() { allData = allDataList; isLoading = false; });
    } catch (e) {
      setState(() { errorMessage = e.toString(); isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get filteredData {
    if (searchQuery.isEmpty) return allData;
    final query = searchQuery.toLowerCase().trim();
    return allData.where((item) => (item['code'] ?? '').toString().toLowerCase().contains(query)).toList();
  }

  List<Map<String, dynamic>> getProblematicVariants() {
    List<Map<String, dynamic>> problematic = [];
    for (var item in allData) {
      int stock = item['stock'] ?? 0;
      int gws = item['gws'] ?? 0;
      int nonGws = item['non_gws'] ?? 0;
      int selisih = stock - (gws + nonGws);
      if (selisih != 0) {
        problematic.add({ 'code': item['code'], 'stock': stock, 'gws': gws, 'non_gws': nonGws, 'selisih': selisih, 'status': selisih > 0 ? 'KELEBIHAN' : 'KEKURANGAN' });
      }
    }
    problematic.sort((a, b) => (b['selisih'] as int).abs().compareTo((a['selisih'] as int).abs()));
    return problematic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STOCK ADMIN"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Code...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => searchQuery = ""); })
                    : null,
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase().trim()),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(onRefresh: _loadInitialData, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));
    if (allData.isEmpty) return const Center(child: Text("Tidak ada data"));

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            leading: Icon(Icons.summarize, color: Colors.blue.shade700, size: 28),
            title: const Text("RINGKASAN STOCK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            initiallyExpanded: isSummaryExpanded,
            onExpansionChanged: (expanded) => setState(() => isSummaryExpanded = expanded),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                      child: Column(
                        children: [
                          Row(children: [Icon(Icons.person, size: 16, color: Colors.blue.shade700), const SizedBox(width: 8), Text("Update Stock by: $adminName", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700))]),
                          const SizedBox(height: 8),
                          Row(children: [Icon(Icons.update, size: 16, color: Colors.grey.shade600), const SizedBox(width: 8), Text("Update Terakhir: $lastUpdate", style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("ENDING STOCK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("${Utils.formatNumber(totalStock)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue))])),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)), child: Column(children: [const Text("GWS"), const SizedBox(height: 4), Text("${Utils.formatNumber(totalGws)} PCS", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange))]))),
                      const SizedBox(width: 12),
                      Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)), child: Column(children: [const Text("NON GWS"), const SizedBox(height: 4), Text("${Utils.formatNumber(totalNonGws)} PCS", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green))]))),
                    ]),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (variantNotInData != 0) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailVarianPage(
                              problematicVariants: getProblematicVariants(),
                              totalStock: totalStock,
                              totalGws: totalGws,
                              totalNonGws: totalNonGws,
                              variantNotInData: variantNotInData)));
                        }
                      },
                      child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: variantNotInData != 0 ? Colors.red.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [Icon(variantNotInData != 0 ? Icons.warning : Icons.check_circle, color: variantNotInData != 0 ? Colors.red : Colors.green, size: 20), const SizedBox(width: 8), Text("VARIAN TIDAK ADA DI DATA", style: TextStyle(fontWeight: FontWeight.bold, color: variantNotInData != 0 ? Colors.red : Colors.green)), if (variantNotInData != 0) const Icon(Icons.chevron_right, size: 20, color: Colors.red)]),
                          Text(variantNotInData != 0 ? "${Utils.formatNumber(variantNotInData)} PCS" : "0 PCS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: variantNotInData != 0 ? Colors.red : Colors.green)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Total Varian: ${Utils.formatNumber(totalVarian)} item", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final item = filteredData[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text("${item['code']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  subtitle: Text("Stock: ${item['stock']} | Balance: ${item['balance']}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _rowInfo("GWS", item['gws']),
                          _rowInfo("NON GWS", item['non_gws']),
                          _rowInfo("STOCK", item['stock']),
                          const Divider(),
                          _rowInfo("BALANCE", item['balance'], isBold: true, color: Colors.red),
                          const SizedBox(height: 8),
                          _rowInfo("Wait Loading", item['wait_loading']),
                          _rowInfo("End Loading", item['end_loading']),
                          _rowInfo("Transport End", item['transport_end']),
                          if (item['noted'] != null && item['noted'].toString().isNotEmpty)
                            Padding(padding: const EdgeInsets.only(top: 8.0), child: Text("📝 ${item['noted']}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _rowInfo(String label, dynamic value, {bool isBold = false, Color color = Colors.black87}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.black54)), Text("${value ?? 0}", style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color))]);
  }
}