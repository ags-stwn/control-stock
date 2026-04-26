import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils.dart';

class CekByCodePage extends StatefulWidget {
  const CekByCodePage({super.key});

  @override
  State<CekByCodePage> createState() => _CekByCodePageState();
}

class _CekByCodePageState extends State<CekByCodePage> {
  String searchCode = "";
  final TextEditingController _codeController = TextEditingController();
  
  List<Map<String, dynamic>> allDataGws = [];
  List<Map<String, dynamic>> allDataNonGws = [];
  bool isLoading = true;
  String? errorMessage;
  
  Set<String> checkedItems = {};
  Map<String, String> notes = {};
  String sortBy = "default";

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCheckedItems();
    _loadNotes();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCheckedItems() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_status').select();
      for (var item in response) { 
        checkedItems.add(item['id'].toString()); 
      }
      setState(() {});
    } catch (e) {
      print("Error load checked items: $e");
    }
  }

  Future<void> _loadNotes() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_notes').select();
      for (var item in response) { 
        notes[item['id'].toString()] = item['note'].toString(); 
      }
      setState(() {});
    } catch (e) {
      print("Error load notes: $e");
    }
  }

  Future<void> _saveCheckedStatus(String itemId, bool isChecked) async {
    try {
      if (isChecked) { 
        await Supabase.instance.client.from('cek_oke_status').upsert({'id': itemId, 'status': 'OKE'}); 
        checkedItems.add(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_status').delete().eq('id', itemId); 
        checkedItems.remove(itemId); 
      }
      setState(() {});
    } catch (e) { 
      print("Error save checked status: $e");
      Utils.showErrorSnackbar(context, "Gagal menyimpan status");
    }
  }

  Future<void> _saveNote(String itemId, String note) async {
    try {
      if (note.isEmpty) { 
        await Supabase.instance.client.from('cek_oke_notes').delete().eq('id', itemId); 
        notes.remove(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_notes').upsert({'id': itemId, 'note': note}); 
        notes[itemId] = note; 
      }
      setState(() {});
    } catch (e) { 
      print("Error save note: $e");
      Utils.showErrorSnackbar(context, "Gagal menyimpan catatan");
    }
  }

  Future<void> _refreshCheckedItems() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Status"),
        content: const Text("Apakah Anda yakin ingin mereset semua status CEK OKE dan catatan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Reset")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { isLoading = true; });

    try {
      await Supabase.instance.client.from('cek_oke_status').delete().neq('id', '0');
      await Supabase.instance.client.from('cek_oke_notes').delete().neq('id', '0');
      checkedItems.clear();
      notes.clear();
      if (mounted) {
        Utils.showSuccessSnackbar(context, "Semua status dan catatan berhasil direset");
        setState(() {});
      }
    } catch (e) {
      if (mounted) Utils.showErrorSnackbar(context, "Gagal mereset: $e");
    } finally {
      if (mounted) setState(() { isLoading = false; });
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() { isLoading = true; errorMessage = null; });
      
      List<Map<String, dynamic>> allGws = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      while (hasMore) {
        final response = await Supabase.instance.client.from('inventory_gws').select().range(start, start + batchSize - 1);
        allGws.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) hasMore = false; else start += batchSize;
      }
      
      List<Map<String, dynamic>> allNonGws = [];
      start = 0;
      hasMore = true;
      while (hasMore) {
        final response = await Supabase.instance.client.from('inventory_non_gws').select().range(start, start + batchSize - 1);
        allNonGws.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) hasMore = false; else start += batchSize;
      }
      
      setState(() { allDataGws = allGws; allDataNonGws = allNonGws; isLoading = false; });
    } catch (e) { 
      setState(() { errorMessage = e.toString(); isLoading = false; });
      Utils.showErrorSnackbar(context, "Gagal memuat data: $e");
    }
  }

  List<Map<String, dynamic>> get filteredData {
    if (searchCode.isEmpty) return [];
    List<Map<String, dynamic>> results = [];
    String query = searchCode.toUpperCase().trim();
    
    int gwsCounter = 0;
    int nonGwsCounter = 0;
    
    for (var item in allDataGws) {
      String code = (item['code'] ?? '').toString().toUpperCase();
      if (code.contains(query)) {
        results.add({ 
          ...item, 
          'ticket_bc': item['ticket_bc'] ?? '-', 
          'lokasi': item['lokasi'] ?? '-', 
          'weekly': item['weekly'] ?? '-', 
          'qty': item['qty'] ?? 0, 
          'id': 'gws_${item['id']}_${gwsCounter++}_${item['code']}',
          'isGws': true 
        });
      }
    }
    
    for (var item in allDataNonGws) {
      String code = (item['code'] ?? '').toString().toUpperCase();
      if (code.contains(query)) {
        results.add({ 
          ...item, 
          'ticket_bc': 'NON GWS', 
          'lokasi': item['lokasi'] ?? '-', 
          'weekly': item['weekly'] ?? '-', 
          'qty': item['qty'] ?? 0, 
          'id': 'ngws_${item['uniq_id']}_${nonGwsCounter++}',
          'isGws': false 
        });
      }
    }
    
    if (sortBy == 'weekly_asc') {
      results.sort((a, b) { String w1 = a['weekly']?.toString() ?? ''; String w2 = b['weekly']?.toString() ?? ''; return w1.compareTo(w2); });
    } else if (sortBy == 'weekly_desc') {
      results.sort((a, b) { String w1 = a['weekly']?.toString() ?? ''; String w2 = b['weekly']?.toString() ?? ''; return w2.compareTo(w1); });
    }
    return results;
  }

  Map<String, dynamic> getSummary() {
    int totalGws = 0, totalNonGws = 0;
    Map<String, int> weeklyGws = {}, weeklyNonGws = {};
    for (var item in filteredData) {
      int qty = item['qty'] ?? 0;
      String weekly = item['weekly']?.toString() ?? '-';
      bool isGws = item['isGws'] == true;
      if (isGws) { totalGws += qty; weeklyGws[weekly] = (weeklyGws[weekly] ?? 0) + qty; }
      else { totalNonGws += qty; weeklyNonGws[weekly] = (weeklyNonGws[weekly] ?? 0) + qty; }
    }
    return { 'totalGws': totalGws, 'totalNonGws': totalNonGws, 'totalAll': totalGws + totalNonGws, 'weeklyGws': weeklyGws, 'weeklyNonGws': weeklyNonGws };
  }

  Future<int> getStockFromMaster(String code) async {
    if (code.isEmpty) return 0;
    try {
      final response = await Supabase.instance.client.from('stock_master').select('stock').eq('code', code.toUpperCase()).maybeSingle();
      return response != null ? (response['stock'] ?? 0) : 0;
    } catch (e) { return 0; }
  }

  Future<Map<String, dynamic>> _getSummaryWithStock() async {
    var summary = getSummary();
    int stock = await getStockFromMaster(searchCode);
    summary['stock'] = stock;
    summary['balance'] = stock - (summary['totalAll'] as int);
    return summary;
  }

  void _exportToCSV() {
    if (filteredData.isEmpty) { Utils.showErrorSnackbar(context, "Tidak ada data untuk di export"); return; }
    String csvContent = "No,TICKET BC,Code,Lokasi,Weekly,QTY,Status,Note\n";
    for (int i = 0; i < filteredData.length; i++) {
      var item = filteredData[i];
      String status = checkedItems.contains(item['id']) ? "OKE CEK" : "";
      String note = notes[item['id']] ?? "";
      csvContent += "${i + 1},\"${item['ticket_bc'] ?? ''}\",\"${(item['code'] ?? '').toString().toUpperCase()}\",\"${item['lokasi'] ?? ''}\",\"${item['weekly'] ?? ''}\",${item['qty'] ?? 0},\"$status\",\"$note\"\n";
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
              Container(padding: const EdgeInsets.all(8), color: Colors.green.shade50, child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text("${filteredData.length} baris data siap di-copy")])),
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

  Widget _buildCompareCard(String label, int value, Color color) {
    String displayValue = value.toString();
    if (label == "BALANCE") {
      if (value > 0) displayValue = "-$value";
      else if (value < 0) displayValue = "+${value.abs()}";
      else displayValue = "0";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [Text(label, style: TextStyle(fontSize: 12, color: color)), Text(displayValue, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: label == "BALANCE" ? Colors.red : color))]),
    );
  }

  void _showNoteDialog(String itemId, String currentNote) {
    TextEditingController noteController = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan"),
        content: TextField(controller: noteController, decoration: const InputDecoration(hintText: "Ketik catatan untuk baris ini...", border: OutlineInputBorder()), maxLines: 3),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")), ElevatedButton(onPressed: () { _saveNote(itemId, noteController.text); Navigator.pop(context); }, child: const Text("Simpan"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CEK ACTUAL - BY CODE"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort), 
            onSelected: (value) { setState(() { sortBy = value; }); }, 
            itemBuilder: (context) => [
              const PopupMenuItem(value: "default", child: Text("Default")), 
              const PopupMenuItem(value: "weekly_asc", child: Text("Weekly A → Z")), 
              const PopupMenuItem(value: "weekly_desc", child: Text("Weekly Z → A"))
            ]
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshCheckedItems, tooltip: "Reset semua status CEK OKE"),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportToCSV, tooltip: "Export hasil pencarian ke CSV"),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _codeController, 
                  autofocus: true, 
                  decoration: InputDecoration(
                    hintText: "Cari berdasarkan Code... (contoh: 7033, C45830)", 
                    prefixIcon: const Icon(Icons.search), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
                    filled: true, 
                    fillColor: Colors.white, 
                    suffixIcon: _codeController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _codeController.clear(); setState(() => searchCode = ""); }) 
                        : null
                  ), 
                  onChanged: (value) => setState(() => searchCode = value)
                ),
                const SizedBox(height: 8),
                Text("🔍 Mencari di: GWS (NK01) + NON GWS", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));
    if (searchCode.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search, size: 64, color: Colors.grey), SizedBox(height: 16), Text("Masukkan kode barang untuk mencari"), SizedBox(height: 8), Text("Contoh: 7033, C45830, 12510", style: TextStyle(fontSize: 12, color: Colors.grey))]));
    }
    if (filteredData.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 64, color: Colors.grey), const SizedBox(height: 16), Text("Tidak ada data ditemukan untuk \"$searchCode\""), const SizedBox(height: 8), Text("Coba cari dengan kode yang lain", style: TextStyle(fontSize: 12, color: Colors.grey))]));
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _getSummaryWithStock(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var summary = snapshot.data!;
        int totalGws = summary['totalGws'], totalNonGws = summary['totalNonGws'], totalAll = summary['totalAll'], stock = summary['stock'], balance = summary['balance'];
        var weeklyGws = summary['weeklyGws'] as Map<String, int>;
        var weeklyNonGws = summary['weeklyNonGws'] as Map<String, int>;

        return Column(
          children: [
            Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("🔍 Hasil pencarian code: \"$searchCode\"", style: const TextStyle(fontWeight: FontWeight.bold)), Text("${filteredData.length} baris | Total: $totalAll Pcs", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.all(12),
                      title: const Row(children: [Icon(Icons.summarize, size: 20, color: Colors.blue), SizedBox(width: 8), Text("LIHAT RINGKASAN", style: TextStyle(fontWeight: FontWeight.bold))]),
                      initiallyExpanded: false,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("COMPARE STOCK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildCompareCard("STOCK", stock, Colors.blue), _buildCompareCard("GWS", totalGws, Colors.orange), _buildCompareCard("NON GWS", totalNonGws, Colors.purple), _buildCompareCard("BALANCE", balance, Colors.red)]),
                            const Divider(height: 24),
                            if (weeklyGws.isNotEmpty) ...[
                              const Text("RINCIAN PER WEEKLY (GWS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, runSpacing: 8, children: weeklyGws.entries.map((entry) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)), child: Text("${entry.key}: ${entry.value} Pcs", style: TextStyle(color: Colors.orange.shade700)))).toList()),
                              const SizedBox(height: 16),
                            ],
                            if (weeklyNonGws.isNotEmpty) ...[
                              const Text("RINCIAN PER WEEKLY (NON GWS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, runSpacing: 8, children: weeklyNonGws.entries.map((entry) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20)), child: Text("${entry.key}: ${entry.value} Pcs", style: TextStyle(color: Colors.purple.shade700)))).toList()),
                            ],
                          ],
                        ),
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
                  final bool isChecked = checkedItems.contains(item['id']);
                  final bool isGws = item['isGws'] == true;
                  final String currentNote = notes[item['id']] ?? "";
                  final Color textColor = isGws ? Colors.blue.shade700 : Colors.orange.shade700;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: isChecked ? Colors.green.shade50 : null,
                    child: ListTile(
                      leading: Icon(isGws ? Icons.inventory : Icons.warehouse, color: textColor, size: 28),
                      title: Row(children: [Expanded(child: Text((item['code'] ?? '-').toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)), child: Text("${item['qty'] ?? 0} Pcs", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(children: [Icon(Icons.qr_code, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4), Expanded(child: Text(item['ticket_bc'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)))]),
                          const SizedBox(height: 2),
                          Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4), Expanded(child: Text(item['lokasi'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)))]),
                          const SizedBox(height: 2),
                          Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4), Text("Weekly: ${item['weekly'] ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(isChecked ? Icons.check_circle : Icons.check_circle_outline, color: isChecked ? Colors.green : Colors.grey, size: 28), onPressed: () { _saveCheckedStatus(item['id'], !isChecked); }),
                          IconButton(icon: Icon(currentNote.isNotEmpty ? Icons.edit_note : Icons.note_add, color: currentNote.isNotEmpty ? Colors.blue : Colors.grey, size: 24), onPressed: () { _showNoteDialog(item['id'], currentNote); }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}