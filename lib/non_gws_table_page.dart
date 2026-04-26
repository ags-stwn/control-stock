import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils.dart';
import 'detail_by_year_page.dart';

class NonGwsTablePage extends StatefulWidget {
  const NonGwsTablePage({super.key});

  @override
  State<NonGwsTablePage> createState() => _NonGwsTablePageState();
}

class _NonGwsTablePageState extends State<NonGwsTablePage> {
  String searchQuery = "";
  bool hasSearched = false;
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> allHistory = [];
  bool isLoading = true;
  bool isLoadingHistory = false;
  String? errorMessage;
  bool showHistory = false;
  List<String> codeList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      List<Map<String, dynamic>> allDataList = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      
      while (hasMore) {
        final response = await Supabase.instance.client
            .from('inventory_non_gws')
            .select()
            .order('weekly', ascending: false)
            .range(start, start + batchSize - 1);
        allDataList.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) {
          hasMore = false;
        } else {
          start += batchSize;
        }
      }
      
      final normalizedData = allDataList.map((item) {
        return {
          ...item,
          'code': (item['code'] ?? '').toString().toLowerCase(),
          'lokasi': (item['lokasi'] ?? '').toString().toLowerCase(),
        };
      }).toList();
      
      codeList = normalizedData.map((e) => (e['code'] ?? '').toString().toUpperCase()).toSet().toList();
      codeList.sort();
      
      setState(() {
        allData = normalizedData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        isLoadingHistory = true;
      });
      
      List<Map<String, dynamic>> allHistoryList = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      
      while (hasMore) {
        final response = await Supabase.instance.client
            .from('take_history')
            .select()
            .order('taken_at', ascending: false)
            .range(start, start + batchSize - 1);
        allHistoryList.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) {
          hasMore = false;
        } else {
          start += batchSize;
        }
      }
      
      setState(() {
        allHistory = allHistoryList;
        isLoadingHistory = false;
      });
    } catch (e) {
      print("Error loading history: $e");
      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredData {
    if (!hasSearched || searchQuery.isEmpty) return [];
    final query = searchQuery.toLowerCase().trim();
    return allData.where((item) {
      final code = (item['code'] ?? '').toString();
      final lokasi = (item['lokasi'] ?? '').toString();
      return code.contains(query) || lokasi.contains(query);
    }).toList();
  }

  int get totalQty => filteredData.fold(0, (sum, item) => sum + ((item['qty'] ?? 0) as int));

  Map<int, int> getSummaryByYear() {
    Map<int, int> summary = {};
    for (var item in allData) {
      String weekly = (item['weekly'] ?? '').toString();
      int year = _extractYearFromWeekly(weekly);
      int qty = (item['qty'] ?? 0) as int;
      summary[year] = (summary[year] ?? 0) + qty;
    }
    return summary;
  }
  
  int _extractYearFromWeekly(String weekly) {
    if (weekly.isEmpty || weekly == 'null' || weekly == 'N/A') return 0;
    try {
      String clean = weekly.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length >= 4) {
        if (clean.length == 4) {
          String yearStr = clean.substring(2, 4);
          return 2000 + int.parse(yearStr);
        } else {
          String yearStr = clean.substring(clean.length - 4);
          return int.parse(yearStr);
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  String getFormattedDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}";
  }

  bool _hasZeroQtyData() {
    return filteredData.any((item) => (item['qty'] ?? 0) == 0);
  }

  void _exportToCSV() {
    if (allData.isEmpty) {
      Utils.showErrorSnackbar(context, "Tidak ada data untuk di export");
      return;
    }
    
    String csvContent = "No,Code,Lokasi,Weekly,Qty,Noted,Date Time\n";
    for (int i = 0; i < allData.length; i++) {
      var item = allData[i];
      csvContent += "${i + 1},\"${item['code'] ?? ''}\",\"${item['lokasi'] ?? ''}\",\"${item['weekly'] ?? ''}\",${item['qty'] ?? 0},\"${item['noted'] ?? ''}\",\"${item['date_time'] ?? ''}\"\n";
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.download, color: Colors.green), SizedBox(width: 8), Text("Export CSV")]),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(8), color: Colors.green.shade50, child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text("${allData.length} baris data siap di-copy")])),
              const SizedBox(height: 12),
              const Text("Copy teks CSV di bawah ini, lalu paste ke Excel:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(height: 300, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(8.0), child: SelectableText(csvContent, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')))))),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(8), color: Colors.blue.shade50, child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text("Tips: Select All (Ctrl+A) lalu Copy (Ctrl+C), paste ke Excel", style: TextStyle(fontSize: 11)))])),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  void _exportHistoryToCSV() {
    if (allHistory.isEmpty) {
      Utils.showErrorSnackbar(context, "Tidak ada riwayat untuk di export");
      return;
    }
    
    String csvContent = "No,Code,Qty,From Location,To Location,Note,Taken At,Restored At,Status\n";
    for (int i = 0; i < allHistory.length; i++) {
      var item = allHistory[i];
      csvContent += "${i + 1},\"${item['code'] ?? ''}\",${item['qty'] ?? 0},\"${item['from_location'] ?? ''}\",\"${item['to_location'] ?? ''}\",\"${item['note'] ?? ''}\",\"${item['taken_at'] ?? ''}\",\"${item['restored_at'] ?? ''}\",\"${item['status'] ?? ''}\"\n";
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.download, color: Colors.green), SizedBox(width: 8), Text("Export Riwayat CSV")]),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(8), color: Colors.green.shade50, child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text("${allHistory.length} baris riwayat siap di-copy")])),
              const SizedBox(height: 12),
              const Text("Copy teks CSV di bawah ini, lalu paste ke Excel:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(height: 300, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(8.0), child: SelectableText(csvContent, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')))))),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(8), color: Colors.blue.shade50, child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text("Tips: Select All (Ctrl+A) lalu Copy (Ctrl+C), paste ke Excel", style: TextStyle(fontSize: 11)))])),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showHistory ? "RIWAYAT TRANSAKSI" : "DATA NON GWS"),
        backgroundColor: showHistory ? Colors.purple : Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (!showHistory) ...[
            if (_hasZeroQtyData())
              IconButton(
                icon: const Icon(Icons.cleaning_services), 
                onPressed: _cleanAllZeroQty, 
                tooltip: "Bersihkan semua data QTY 0 di halaman ini",
              ),
            IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog, tooltip: "Tambah Data"),
            IconButton(icon: const Icon(Icons.download), onPressed: _exportToCSV, tooltip: "Export CSV"),
            IconButton(icon: const Icon(Icons.history), onPressed: () {
              setState(() { showHistory = true; _loadHistory(); });
            }, tooltip: "Lihat Riwayat"),
          ],
          if (showHistory) ...[
            IconButton(icon: const Icon(Icons.download), onPressed: _exportHistoryToCSV, tooltip: "Export Riwayat CSV"),
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
              setState(() { showHistory = false; });
            }, tooltip: "Kembali ke Data"),
          ],
        ],
        bottom: !showHistory ? PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Code atau Lokasi...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchController.clear();
                        setState(() { searchQuery = ""; hasSearched = false; });
                      })
                    : null,
              ),
              onChanged: (value) { setState(() { searchQuery = value.toLowerCase().trim(); hasSearched = value.isNotEmpty; }); },
            ),
          ),
        ) : null,
      ),
      body: showHistory ? _buildHistoryBody() : _buildBody(),
    );
  }

  Widget _buildHistoryBody() {
    if (isLoadingHistory) return const Center(child: CircularProgressIndicator());
    if (allHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Belum ada riwayat transaksi"),
            SizedBox(height: 8),
            Text("Ambil barang untuk memulai riwayat", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          color: Colors.purple.shade50,
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("RIWAYAT PENGAMBILAN BARANG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${allHistory.length} transaksi", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
            ],
          ),
        ),
        Container(
          color: Colors.purple.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              _buildHeaderCell("No", flex: 1),
              _buildHeaderCell("CODE", flex: 2),
              _buildHeaderCell("QTY", flex: 1),
              _buildHeaderCell("DARI", flex: 2),
              _buildHeaderCell("TUJUAN", flex: 2),
              _buildHeaderCell("STATUS", flex: 1),
              _buildHeaderCell("AKSI", flex: 2),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: allHistory.length,
            itemBuilder: (context, index) {
              final item = allHistory[index];
              final bool isRestored = (item['status'] ?? '') == 'RESTORED';
              final bool isEven = index % 2 == 0;
              
              return Container(
                color: isEven ? Colors.grey.shade50 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: [
                    _buildCell("${index + 1}", flex: 1),
                    _buildCell((item['code'] ?? '-').toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                    _buildCell("${item['qty'] ?? 0}", flex: 1, fontWeight: FontWeight.bold, color: Colors.red),
                    _buildCell((item['from_location'] ?? '-').toString().toUpperCase(), flex: 2, fontSize: 11),
                    _buildCell((item['to_location'] ?? '-').toString().toUpperCase(), flex: 2, fontSize: 11),
                    _buildCell(isRestored ? "RESTORED" : "ACTIVE", flex: 1, fontWeight: FontWeight.bold, color: isRestored ? Colors.green : Colors.orange),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isRestored)
                          IconButton(icon: const Icon(Icons.restore, color: Colors.green, size: 20), onPressed: () => _showRestoreDialog(item), tooltip: "Restore"),
                        IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20), onPressed: () => _showPermanentDeleteDialog(item), tooltip: "Hapus Permanen"),
                      ],
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

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));
    if (allData.isEmpty) return const Center(child: Text("Tidak ada data"));

    var summary = getSummaryByYear();
    int totalAll = summary.values.fold(0, (sum, qty) => sum + qty);
    String lastUpdate = getFormattedDate();

    if (!hasSearched) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Icon(Icons.summarize, color: Colors.orange, size: 28), SizedBox(width: 10), Text("RINGKASAN DATA NON GWS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                      const Divider(height: 24),
                      Text("📅 Update Terakhir: $lastUpdate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: summary.entries.map((entry) {
                          int year = entry.key;
                          int qty = entry.value;
                          if (year == 0) return const SizedBox.shrink();
                          List<Map<String, dynamic>> yearData = allData.where((item) {
                            return _extractYearFromWeekly(item['weekly'] ?? '') == year;
                          }).toList();
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailByYearPage(year: year, data: yearData, totalQty: qty)));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: year == 2025 ? Colors.blue.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: year == 2025 ? Colors.blue.shade200 : Colors.green.shade200),
                              ),
                              child: Column(
                                children: [
                                  Text("TAHUN $year", style: TextStyle(fontWeight: FontWeight.bold, color: year == 2025 ? Colors.blue.shade700 : Colors.green.shade700)),
                                  const SizedBox(height: 4),
                                  Text("$qty PCS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: year == 2025 ? Colors.blue.shade900 : Colors.green.shade900)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [const Text("TOTAL SEMUA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("$totalAll PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red))],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => hasSearched = true),
                          icon: const Icon(Icons.search),
                          label: const Text("MULAI PENCARIAN"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(children: [Icon(Icons.lightbulb, color: Colors.orange), SizedBox(width: 8), Text("Tips Pencarian", style: TextStyle(fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 8),
                      const Text("• Ketik kode barang (contoh: C45830)"),
                      const Text("• Ketik lokasi (contoh: NK01-2U-10)"),
                      const Divider(),
                      const Text("📋 Fitur:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text("• Ambil barang - pindahkan ke lokasi lain"),
                      const Text("• Input cepat - dengan konsep PALLET, FULL, ODD"),
                      const Text("• Riwayat transaksi - lihat semua pengambilan"),
                      const Text("• Restore - kembalikan barang"),
                      const Text("• Hapus Permanen - hapus data riwayat"),
                      const Text("• Hapus QTY 0 - hapus data stok habis di halaman ini"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Tidak ditemukan"),
            const SizedBox(height: 16),
            TextButton.icon(onPressed: () { _searchController.clear(); setState(() { searchQuery = ""; hasSearched = false; }); }, icon: const Icon(Icons.arrow_back), label: const Text("Kembali ke Ringkasan")),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: Colors.orange.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("🔍 Hasil: \"${_searchController.text}\""),
              Text("${filteredData.length} baris"),
            ],
          ),
        ),
        Container(
          color: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              _buildHeaderCell("No", flex: 1),
              _buildHeaderCell("CODE", flex: 2),
              _buildHeaderCell("LOKASI", flex: 2),
              _buildHeaderCell("WEEKLY", flex: 2),
              _buildHeaderCell("QTY", flex: 1),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final item = filteredData[index];
              final int qty = item['qty'] ?? 0;
              final bool isZeroQty = qty == 0;
              
              return GestureDetector(
                onTap: () {
                  if (isZeroQty) {
                    _showDeleteZeroQtyDialog(context, item, item['uniq_id']);
                  } else {
                    _showAmbilDialog(context, item, item['uniq_id']);
                  }
                },
                child: Container(
                  color: isZeroQty 
                      ? Colors.red.shade50 
                      : (index % 2 == 0 ? Colors.grey.shade50 : Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    children: [
                      _buildCell("${index + 1}", flex: 1),
                      _buildCell((item['code'] ?? "-").toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                      _buildCell((item['lokasi'] ?? "-").toString().toUpperCase(), flex: 2),
                      _buildCell(item['weekly'] ?? "-", flex: 2),
                      _buildCell("$qty", flex: 1, fontWeight: FontWeight.bold, color: isZeroQty ? Colors.red : Colors.black87),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("TOTAL QTY: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("$totalQty Pcs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black87, double fontSize = 13}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showAddDialog() {
    TextEditingController codeController = TextEditingController();
    TextEditingController palletController = TextEditingController();
    TextEditingController fullQtyController = TextEditingController();
    TextEditingController oddQtyController = TextEditingController();
    TextEditingController lokasiController = TextEditingController();
    TextEditingController weeklyController = TextEditingController();

    int pallet = 0, fullQty = 0, oddQty = 0, totalQtyPreview = 0, totalBarisPreview = 0;
    List<String> suggestionCodes = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            void updatePreview() {
              pallet = int.tryParse(palletController.text) ?? 0;
              fullQty = int.tryParse(fullQtyController.text) ?? 0;
              oddQty = int.tryParse(oddQtyController.text) ?? 0;
              totalBarisPreview = pallet;
              if (oddQty > 0) totalBarisPreview++;
              totalQtyPreview = (pallet * fullQty) + oddQty;
              setStateDialog(() {});
            }

            void updateSuggestions(String input) {
              if (input.isEmpty) {
                suggestionCodes = [];
              } else {
                suggestionCodes = codeList
                    .where((code) => code.toLowerCase().contains(input.toLowerCase()))
                    .take(10)
                    .toList();
              }
              setStateDialog(() {});
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [Icon(Icons.inventory, color: Colors.orange, size: 28), const SizedBox(width: 10), const Text("Tambah Data Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                      const Divider(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CODE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  hintText: "Ketik Code... (bisa baru atau pilih dari saran)",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  prefixIcon: const Icon(Icons.qr_code, size: 20, color: Colors.grey),
                                  suffixIcon: codeController.text.isNotEmpty
                                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { codeController.clear(); updateSuggestions(''); })
                                      : null,
                                ),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                textCapitalization: TextCapitalization.characters,
                                onChanged: (value) => updateSuggestions(value),
                              ),
                              if (suggestionCodes.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                                  child: Column(
                                    children: suggestionCodes.map((suggestion) {
                                      return InkWell(
                                        onTap: () { codeController.text = suggestion; updateSuggestions(''); },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                                          child: Row(children: [const Icon(Icons.history, size: 16, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(suggestion, style: const TextStyle(fontSize: 13)))]),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("💡 Tips: Ketik untuk mencari code yang sudah ada, atau ketik code baru", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                        child: Column(
                          children: [
                            const Text("INPUT MULTI BARIS", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text("(Membuat banyak baris sekaligus)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("PALLET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: palletController,
                                        decoration: InputDecoration(hintText: "Jumlah", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => updatePreview(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("QTY FULL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: fullQtyController,
                                        decoration: InputDecoration(hintText: "Per Pallet", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => updatePreview(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("ODD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: oddQtyController,
                                        decoration: InputDecoration(hintText: "Sisa", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => updatePreview(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                        child: Column(
                          children: [
                            const Row(children: [Icon(Icons.preview, size: 16, color: Colors.green), SizedBox(width: 8), Text("PREVIEW", style: TextStyle(fontWeight: FontWeight.bold))]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(children: [Text("$totalBarisPreview", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)), const Text("Baris", style: TextStyle(fontSize: 10))]),
                                Container(width: 1, height: 30, color: Colors.grey.shade300),
                                Column(children: [Text("$totalQtyPreview", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)), const Text("Total Qty", style: TextStyle(fontSize: 10))]),
                                Container(width: 1, height: 30, color: Colors.grey.shade300),
                                Column(children: [Text("$pallet", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)), const Text("Pallet", style: TextStyle(fontSize: 10))]),
                                if (oddQty > 0) ...[
                                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                                  Column(children: [Text("$oddQty", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)), const Text("Odd", style: TextStyle(fontSize: 10))]),
                                ],
                              ],
                            ),
                            if (totalBarisPreview > 0 && totalBarisPreview <= 50)
                              const SizedBox(height: 6),
                            if (totalBarisPreview > 0 && totalBarisPreview <= 50)
                              Text("📋 $totalBarisPreview baris: ${fullQty > 0 ? '$fullQty Pcs' : ''}${fullQty > 0 && pallet > 0 ? ' x $pallet pallet' : ''}${fullQty > 0 && oddQty > 0 ? ' + ' : ''}${oddQty > 0 ? '$oddQty Pcs' : ''}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            if (totalBarisPreview > 50)
                              const Text("⚠️ Maksimal 50 baris!", style: TextStyle(fontSize: 11, color: Colors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("LOKASI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: lokasiController,
                            decoration: InputDecoration(hintText: "Contoh: DO PREPARE, 1A-31", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("WEEKLY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: weeklyController,
                            decoration: InputDecoration(hintText: "Contoh: 1526", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.grey.shade100),
                              child: const Text("BATAL", style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                String code = codeController.text.trim().toUpperCase();
                                pallet = int.tryParse(palletController.text) ?? 0;
                                fullQty = int.tryParse(fullQtyController.text) ?? 0;
                                oddQty = int.tryParse(oddQtyController.text) ?? 0;
                                String lokasi = lokasiController.text.trim().toUpperCase();
                                String weekly = weeklyController.text.trim();
                                
                                if (code.isEmpty) { Utils.showErrorSnackbar(context, "⚠️ CODE harus diisi"); return; }
                                if (pallet <= 0 && oddQty <= 0) { Utils.showErrorSnackbar(context, "⚠️ PALLET atau ODD harus diisi (minimal 1)"); return; }
                                if (fullQty <= 0 && pallet > 0) { Utils.showErrorSnackbar(context, "⚠️ QTY FULL harus diisi jika PALLET lebih dari 0"); return; }
                                if (lokasi.isEmpty) { Utils.showErrorSnackbar(context, "⚠️ LOKASI harus diisi"); return; }
                                
                                int totalBaris = pallet;
                                if (oddQty > 0) totalBaris++;
                                if (totalBaris > 50) { Utils.showErrorSnackbar(context, "⚠️ Maksimal 50 baris dalam satu kali input"); return; }
                                
                                showDialog(context: context, barrierDismissible: false, builder: (context) => const AlertDialog(content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Menyimpan data...")])));
                                
                                try {
                                  List<Map<String, dynamic>> itemsToInsert = [];
                                  String baseUniqId = 'UID-${DateTime.now().millisecondsSinceEpoch}';
                                  String currentDateTime = DateTime.now().toIso8601String();
                                  
                                  for (int i = 0; i < pallet; i++) {
                                    itemsToInsert.add({"code": code, "qty": fullQty, "lokasi": lokasi, "weekly": weekly, "noted": "Pallet ${i + 1} dari $pallet", "date_time": currentDateTime, "uniq_id": '${baseUniqId}_P${i + 1}'});
                                  }
                                  if (oddQty > 0) {
                                    itemsToInsert.add({"code": code, "qty": oddQty, "lokasi": lokasi, "weekly": weekly, "noted": "ODD (sisa)", "date_time": currentDateTime, "uniq_id": '${baseUniqId}_ODD'});
                                  }
                                  
                                  await Supabase.instance.client.from('inventory_non_gws').insert(itemsToInsert);
                                  Navigator.pop(context); Navigator.pop(context);
                                  Utils.showSuccessSnackbar(context, "✅ Berhasil menyimpan ${itemsToInsert.length} baris data\nTotal Qty: ${(pallet * fullQty) + oddQty} Pcs\nCode: $code");
                                  _loadInitialData();
                                } catch (e) { Navigator.pop(context); Utils.showErrorSnackbar(context, "❌ Gagal menyimpan: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}"); }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text("SIMPAN", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteZeroQtyDialog(BuildContext context, Map<String, dynamic> item, String uniqId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text("Hapus Data?", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Data ini memiliki QTY = 0", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📦 Code: ${(item['code'] ?? '').toString().toUpperCase()}"),
                  Text("📍 Lokasi: ${item['lokasi'] ?? ''}"),
                  Text("📅 Weekly: ${item['weekly'] ?? ''}"),
                  Text("🔢 Qty: 0 Pcs"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text("Apakah Anda yakin ingin menghapus data ini?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
              try {
                await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', uniqId);
                if (mounted) {
                  Navigator.pop(context);
                  Utils.showSuccessSnackbar(context, "✅ Data dengan QTY 0 berhasil dihapus");
                  _loadInitialData();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  Utils.showErrorSnackbar(context, "❌ Gagal menghapus: $e");
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanAllZeroQty() async {
    List<Map<String, dynamic>> zeroQtyData = filteredData.where((item) => (item['qty'] ?? 0) == 0).toList();
    
    if (zeroQtyData.isEmpty) {
      Utils.showErrorSnackbar(context, "Tidak ada data dengan QTY 0 pada hasil pencarian ini");
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text("Bersihkan Data QTY 0", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ditemukan ${zeroQtyData.length} data dengan QTY = 0 pada halaman ini", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: zeroQtyData.take(10).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• ${item['code']} - ${item['lokasi']} (${item['weekly']})"),
                  );
                }).toList(),
              ),
            ),
            if (zeroQtyData.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("... dan ${zeroQtyData.length - 10} data lainnya", 
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "⚠️ PERINGATAN: Data akan dihapus dari database!",
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 12),
            Text("Apakah Anda yakin ingin menghapus ${zeroQtyData.length} data ini?", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Hapus ${zeroQtyData.length} data"),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      int deletedCount = 0;
      for (var item in zeroQtyData) {
        await Supabase.instance.client
            .from('inventory_non_gws')
            .delete()
            .eq('uniq_id', item['uniq_id']);
        deletedCount++;
      }
      
      if (mounted) {
        Navigator.pop(context);
        Utils.showSuccessSnackbar(context, 
            "✅ Berhasil menghapus $deletedCount data dengan QTY 0\n"
            "Dari halaman: ${searchQuery.isEmpty ? 'Semua data' : searchQuery}");
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        Utils.showErrorSnackbar(context, "❌ Gagal menghapus: $e");
      }
    }
  }

  void _showAmbilDialog(BuildContext context, Map<String, dynamic> item, String uniqId) {
    int maxQty = (item['qty'] ?? 0) as int;
    String currentLokasi = (item['lokasi'] ?? '').toString().toUpperCase();
    TextEditingController qtyController = TextEditingController(text: maxQty.toString());
    String destination = 'OUT LINE TO PREPARE';
    bool isAll = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Icon(Icons.inventory_2, color: Colors.orange.shade700, size: 28), const SizedBox(width: 10), Expanded(child: Text("AMBIL BARANG: ${(item['code'] ?? '').toString().toUpperCase()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Stok Saat Ini:", style: TextStyle(fontWeight: FontWeight.bold)), Text("$maxQty Pcs", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Lokasi:", style: TextStyle(fontWeight: FontWeight.bold)), Text(currentLokasi, style: const TextStyle(fontWeight: FontWeight.w500))]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  const Text("JUMLAH YANG DIAMBIL:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextFormField(controller: qtyController, decoration: InputDecoration(hintText: "Jumlah", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, suffixText: "Pcs"), keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), enabled: !isAll, onChanged: (value) { int val = int.tryParse(value) ?? 0; if (val > maxQty) qtyController.text = maxQty.toString(); setStateDialog(() {}); })),
                    const SizedBox(width: 12),
                    FilterChip(label: const Text("ALL"), selected: isAll, onSelected: (selected) { setStateDialog(() { isAll = selected; if (isAll) qtyController.text = maxQty.toString(); }); }, backgroundColor: Colors.grey.shade200, selectedColor: Colors.red.shade100, checkmarkColor: Colors.red),
                  ]),
                  const SizedBox(height: 20),
                  const Text("PILIHAN TUJUAN:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      RadioListTile<String>(title: const Text("OUT LINE TO PREPARE", style: TextStyle(fontWeight: FontWeight.w500)), value: "OUT LINE TO PREPARE", groupValue: destination, onChanged: (value) { setStateDialog(() { destination = value!; }); }, activeColor: Colors.orange),
                      RadioListTile<String>(title: const Text("OUT LINE TO REQUEST", style: TextStyle(fontWeight: FontWeight.w500)), value: "OUT LINE TO REQUEST", groupValue: destination, onChanged: (value) { setStateDialog(() { destination = value!; }); }, activeColor: Colors.green),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.grey.shade100), child: const Text("BATAL", style: TextStyle(fontSize: 16, color: Colors.grey)))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: () async {
                      int takeQty = int.tryParse(qtyController.text) ?? 0;
                      if (takeQty <= 0) { Utils.showErrorSnackbar(context, "Jumlah yang diambil harus lebih dari 0"); return; }
                      if (takeQty > maxQty) { Utils.showErrorSnackbar(context, "Jumlah yang diambil melebihi stok"); return; }
                      int newQty = maxQty - takeQty;
                      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
                      try {
                        await Supabase.instance.client.from('inventory_non_gws').update({'qty': newQty}).eq('uniq_id', uniqId);
                        String newUniqId = 'UID-${DateTime.now().millisecondsSinceEpoch}';
                        await Supabase.instance.client.from('inventory_non_gws').insert({"code": item['code'], "qty": takeQty, "lokasi": destination, "weekly": item['weekly'] ?? '', "noted": "Diambil dari $currentLokasi pada ${DateTime.now().toString().split('.')[0]}", "date_time": DateTime.now().toString(), "uniq_id": newUniqId});
                        await Supabase.instance.client.from('take_history').insert({"code": item['code'], "qty": takeQty, "from_location": currentLokasi, "to_location": destination, "note": "Pengambilan barang", "taken_at": DateTime.now().toIso8601String(), "status": "ACTIVE", "original_uniq_id": uniqId, "new_uniq_id": newUniqId});
                        if (mounted) {
                          Navigator.pop(context); Navigator.pop(context);
                          Utils.showSuccessSnackbar(context, "✅ Berhasil mengambil $takeQty Pcs\nSisa: $newQty Pcs di $currentLokasi\nBerpindah ke: $destination");
                          _loadInitialData(); _loadHistory();
                        }
                      } catch (e) { if (mounted) { Navigator.pop(context); Utils.showErrorSnackbar(context, "Gagal mengambil barang: $e"); } }
                    }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("AMBIL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRestoreDialog(Map<String, dynamic> historyItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kembalikan Barang?"),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Kode: ${(historyItem['code'] ?? '').toString().toUpperCase()}"),
          Text("Jumlah: ${historyItem['qty']} Pcs"),
          Text("Dari: ${historyItem['to_location']}"),
          Text("Kembalikan ke: ${historyItem['from_location']}"),
          const SizedBox(height: 16),
          const Text("Apakah Anda yakin ingin mengembalikan barang ini?", style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.green), child: const Text("Kembalikan")),
        ],
      ),
    );
    if (confirm != true) return;
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      String originalUniqId = historyItem['original_uniq_id'];
      String newUniqId = historyItem['new_uniq_id'];
      int qty = historyItem['qty'] as int;
      String fromLocation = historyItem['from_location'];
      final originalResponse = await Supabase.instance.client.from('inventory_non_gws').select().eq('uniq_id', originalUniqId).maybeSingle();
      if (originalResponse != null) {
        int currentQty = originalResponse['qty'] ?? 0;
        await Supabase.instance.client.from('inventory_non_gws').update({'qty': currentQty + qty}).eq('uniq_id', originalUniqId);
      } else {
        await Supabase.instance.client.from('inventory_non_gws').insert({"code": historyItem['code'], "qty": qty, "lokasi": fromLocation, "weekly": "", "noted": "Dikembalikan dari ${historyItem['to_location']} pada ${DateTime.now().toString().split('.')[0]}", "date_time": DateTime.now().toString(), "uniq_id": 'RESTORE-${DateTime.now().millisecondsSinceEpoch}'});
      }
      await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', newUniqId);
      await Supabase.instance.client.from('take_history').update({'status': 'RESTORED', 'restored_at': DateTime.now().toIso8601String()}).eq('id', historyItem['id']);
      if (mounted) {
        Navigator.pop(context);
        Utils.showSuccessSnackbar(context, "✅ Berhasil mengembalikan $qty Pcs ke $fromLocation");
        _loadInitialData(); _loadHistory();
      }
    } catch (e) { if (mounted) { Navigator.pop(context); Utils.showErrorSnackbar(context, "Gagal mengembalikan barang: $e"); } }
  }

  void _showPermanentDeleteDialog(Map<String, dynamic> historyItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning, color: Colors.red, size: 28), SizedBox(width: 8), Text("Hapus Permanen", style: TextStyle(color: Colors.red))]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Anda akan menghapus transaksi ini secara permanen:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("📦 Kode: ${(historyItem['code'] ?? '').toString().toUpperCase()}"), 
              Text("🔢 Jumlah: ${historyItem['qty']} Pcs"),
              Text("📍 Dari: ${historyItem['from_location']}"), 
              Text("🎯 Tujuan: ${historyItem['to_location']}"),
              const Divider(),
              const Text("⚠️ PERINGATAN:", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const Text("• Data stock di lokasi tujuan akan DIHAPUS"), 
              const Text("• Data stock di lokasi asal TIDAK berubah"),
              const Text("• Riwayat ini akan DIHAPUS"), 
              const Text("• TINDAKAN INI TIDAK DAPAT DIURKAN!"),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Hapus Permanen")),
        ],
      ),
    );
    if (confirm != true) return;
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      String newUniqId = historyItem['new_uniq_id'];
      int historyId = historyItem['id'];
      if (newUniqId != null && newUniqId.isNotEmpty) { await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', newUniqId); }
      await Supabase.instance.client.from('take_history').delete().eq('id', historyId);
      if (mounted) {
        Navigator.pop(context);
        Utils.showSuccessSnackbar(context, "✅ Berhasil menghapus permanen transaksi\n${historyItem['code']} - ${historyItem['qty']} Pcs");
        _loadInitialData(); _loadHistory();
      }
    } catch (e) { if (mounted) { Navigator.pop(context); Utils.showErrorSnackbar(context, "Gagal menghapus: $e"); } }
  }
}