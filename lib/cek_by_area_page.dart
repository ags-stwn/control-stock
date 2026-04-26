import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils.dart';

class CekByAreaPage extends StatefulWidget {
  const CekByAreaPage({super.key});

  @override
  State<CekByAreaPage> createState() => _CekByAreaPageState();
}

class _CekByAreaPageState extends State<CekByAreaPage> {
  List<Map<String, dynamic>> allDataGws = [];
  List<Map<String, dynamic>> allDataNonGws = [];
  bool isLoading = true;
  String? errorMessage;
  bool groupByLocation = true;
  
  Set<String> checkedItems = {};
  Map<String, String> notes = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadCheckedItems();
    _loadNotes();
  }

  Future<void> _loadCheckedItems() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_status_area').select();
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
      final response = await Supabase.instance.client.from('cek_oke_notes_area').select();
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
        await Supabase.instance.client.from('cek_oke_status_area').upsert({'id': itemId, 'status': 'OKE'}); 
        checkedItems.add(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_status_area').delete().eq('id', itemId); 
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
        await Supabase.instance.client.from('cek_oke_notes_area').delete().eq('id', itemId); 
        notes.remove(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_notes_area').upsert({'id': itemId, 'note': note}); 
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
        content: const Text("Apakah Anda yakin ingin mereset semua status CEK OKE dan catatan untuk Area?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Reset")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { isLoading = true; });

    try {
      await Supabase.instance.client.from('cek_oke_status_area').delete().neq('id', '0');
      await Supabase.instance.client.from('cek_oke_notes_area').delete().neq('id', '0');
      checkedItems.clear();
      notes.clear();
      if (mounted) {
        Utils.showSuccessSnackbar(context, "Semua status dan catatan area berhasil direset");
        setState(() {});
      }
    } catch (e) {
      if (mounted) Utils.showErrorSnackbar(context, "Gagal mereset: $e");
    } finally {
      if (mounted) setState(() { isLoading = false; });
    }
  }

  Future<void> _loadAllData() async {
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

  String getBlock(String lokasi) {
    if (lokasi.isEmpty) return "Unknown";
    RegExp regExp = RegExp(r'-(\d+[A-Z])-');
    Match? match = regExp.firstMatch(lokasi);
    return match != null ? match.group(1)! : "Unknown";
  }

  Map<String, List<String>> getBlocksWithLines() {
    Map<String, Set<String>> blockLines = {};
    for (var item in allDataGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi.isNotEmpty) { String block = getBlock(lokasi); if (block != "Unknown") blockLines.putIfAbsent(block, () => {}).add(lokasi); }
    }
    for (var item in allDataNonGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi.isNotEmpty) { String block = getBlock(lokasi); if (block != "Unknown") blockLines.putIfAbsent(block, () => {}).add(lokasi); }
    }
    Map<String, List<String>> result = {};
    blockLines.forEach((block, lines) { result[block] = lines.toList()..sort(); });
    List<String> sortedBlocks = result.keys.toList();
    sortedBlocks.sort((a, b) {
      int floorA = int.tryParse(a.substring(0, a.length-1)) ?? 0;
      int floorB = int.tryParse(b.substring(0, b.length-1)) ?? 0;
      if (floorA != floorB) return floorA.compareTo(floorB);
      return a.compareTo(b);
    });
    Map<String, List<String>> sortedResult = {};
    for (var block in sortedBlocks) { sortedResult[block] = result[block]!; }
    return sortedResult;
  }

  List<Map<String, dynamic>> getItemsByLine(String line) {
    List<Map<String, dynamic>> items = [];
    
    int gwsCounter = 0;
    for (var item in allDataGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi == line) {
        items.add({ 
          ...item, 
          'source': 'GWS', 
          'ticket_bc': item['ticket_bc'] ?? '-',
          'unique_id': 'gws_${item['id']}_${gwsCounter++}_${item['code']}'
        });
      }
    }
    
    for (var item in allDataNonGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi == line) {
        items.add({ 
          ...item, 
          'source': 'NON GWS', 
          'ticket_bc': 'NON GWS',
          'unique_id': 'ngws_${item['uniq_id']}'
        });
      }
    }
    
    items.sort((a, b) {
      String code1 = (a['code'] ?? '').toString().toUpperCase();
      String code2 = (b['code'] ?? '').toString().toUpperCase();
      return code1.compareTo(code2);
    });
    return items;
  }

  List<Map<String, dynamic>> getAllItems() {
    List<Map<String, dynamic>> allItems = [];
    
    int gwsCounter = 0;
    for (var item in allDataGws) { 
      allItems.add({ 
        ...item, 
        'source': 'GWS',
        'unique_id': 'gws_${item['id']}_${gwsCounter++}_${item['code']}'
      }); 
    }
    
    for (var item in allDataNonGws) { 
      allItems.add({ 
        ...item, 
        'source': 'NON GWS',
        'unique_id': 'ngws_${item['uniq_id']}'
      }); 
    }
    
    allItems.sort((a, b) {
      String lokasiA = (a['lokasi'] ?? '').toString();
      String lokasiB = (b['lokasi'] ?? '').toString();
      return lokasiA.compareTo(lokasiB);
    });
    return allItems;
  }

  Set<String> getNonGwsLocations() {
    Set<String> locations = {};
    for (var item in allDataNonGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi.isNotEmpty) locations.add(lokasi);
    }
    return locations;
  }

  List<String> getPrioritizedLocations() {
    Set<String> nonGwsLocations = getNonGwsLocations();
    List<String> prioritizedLocations = [];
    
    prioritizedLocations.add("OUT LINE TO PREPARE");
    
    List<String> sortedNonGws = nonGwsLocations.toList()..sort();
    prioritizedLocations.addAll(sortedNonGws);
    
    return prioritizedLocations;
  }

  // WEEKLY SEMUA WARNA HITAM
  Color _getWeeklyColor(String weekly) {
    return Colors.black;
  }

  // EDIT ONLY FOR NON GWS
  Future<void> _editItemNonGwsOnly(Map<String, dynamic> item, String source) async {
    if (source == 'GWS') {
      Utils.showErrorSnackbar(context, "Item GWS tidak bisa diedit");
      return;
    }
    
    String tableName = 'inventory_non_gws';
    String idField = 'uniq_id';
    dynamic itemId = item[idField];
    TextEditingController qtyController = TextEditingController(text: item['qty'].toString());
    String currentLokasi = (item['lokasi'] ?? '').toString().toUpperCase();
    String selectedLokasi = currentLokasi;
    
    List<String> locationOptions = getPrioritizedLocations();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Row(children: [
              Icon(Icons.edit, color: Colors.orange.shade700), 
              const SizedBox(width: 8), 
              Expanded(child: Text(
                "EDIT NON GWS: ${(item['code'] ?? '-').toString().toUpperCase()}", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                overflow: TextOverflow.ellipsis
              ))
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: qtyController, 
                  decoration: const InputDecoration(
                    labelText: "QTY", 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.numbers)
                  ), 
                  keyboardType: TextInputType.number
                ),
                const SizedBox(height: 12),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("LOKASI", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          List<String> options = List.from(locationOptions);
                          if (textEditingValue.text.isNotEmpty && 
                              !options.any((opt) => opt.toUpperCase() == textEditingValue.text.toUpperCase())) {
                            options.add(textEditingValue.text.toUpperCase());
                          }
                          if (textEditingValue.text.isEmpty) {
                            return options;
                          }
                          return options.where((location) => 
                            location.toLowerCase().contains(textEditingValue.text.toLowerCase())
                          );
                        },
                        initialValue: TextEditingValue(text: selectedLokasi),
                        onSelected: (selection) {
                          selectedLokasi = selection;
                          setStateDialog(() {});
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: "Pilih atau ketik lokasi...",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.location_on, color: Colors.orange),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SimpleDialog(
                                      title: const Text("Pilih Lokasi"),
                                      children: locationOptions.map((location) {
                                        bool isPrepare = location == "OUT LINE TO PREPARE";
                                        return SimpleDialogOption(
                                          onPressed: () {
                                            selectedLokasi = location;
                                            controller.text = location;
                                            setStateDialog(() {});
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Row(
                                              children: [
                                                if (isPrepare) 
                                                  const Icon(Icons.pending_actions, color: Colors.red)
                                                else 
                                                  const Icon(Icons.location_on, color: Colors.blue),
                                                const SizedBox(width: 12),
                                                Text(
                                                  location,
                                                  style: TextStyle(
                                                    fontWeight: isPrepare ? FontWeight.bold : FontWeight.normal,
                                                    color: isPrepare ? Colors.red : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            style: TextStyle(
                              color: selectedLokasi == "OUT LINE TO PREPARE" ? Colors.red : Colors.black,
                              fontWeight: selectedLokasi == "OUT LINE TO PREPARE" ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                    if (selectedLokasi == "OUT LINE TO PREPARE")
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.red.shade700, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Item ini akan dipindahkan ke OUT LINE TO PREPARE",
                                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("Batal", style: TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                onPressed: () async {
                  int newQty = int.tryParse(qtyController.text) ?? 0;
                  String newLokasi = selectedLokasi.trim().toUpperCase();
                  
                  if (newLokasi.isEmpty) { 
                    Utils.showErrorSnackbar(context, "Lokasi tidak boleh kosong"); 
                    return; 
                  }
                  
                  try {
                    await Supabase.instance.client.from(tableName).update({
                      'qty': newQty, 
                      'lokasi': newLokasi
                    }).eq(idField, itemId);
                    
                    if (mounted) { 
                      Navigator.pop(context); 
                      Utils.showSuccessSnackbar(context, 
                        newLokasi == "OUT LINE TO PREPARE" 
                          ? "Item dipindahkan ke OUT LINE TO PREPARE" 
                          : "Data NON GWS berhasil diupdate"
                      ); 
                      _loadAllData(); 
                    }
                  } catch (e) { 
                    if (mounted) Utils.showErrorSnackbar(context, "Error: $e"); 
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
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

  void _showAddItemDialog(String currentLokasi) {
    TextEditingController codeController = TextEditingController();
    TextEditingController qtyController = TextEditingController();
    TextEditingController weeklyController = TextEditingController();
    TextEditingController lokasiController = TextEditingController(text: currentLokasi);
    
    int qtyValue = 0;
    
    Set<String> existingCodes = {};
    for (var item in allDataGws) { 
      existingCodes.add((item['code'] ?? '').toString().toUpperCase()); 
    }
    for (var item in allDataNonGws) { 
      existingCodes.add((item['code'] ?? '').toString().toUpperCase()); 
    }
    List<String> codeList = existingCodes.toList()..sort();
    
    Set<String> allLocations = getNonGwsLocations();
    List<String> locationList = allLocations.toList()..sort();
    locationList.insert(0, "OUT LINE TO PREPARE");
    
    bool isNewCode = false;
    String newCodeText = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Icon(Icons.add_circle, color: Colors.green, size: 28), const SizedBox(width: 10), const Text("Tambah Data Baru - NON GWS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                  const Divider(height: 24),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("LOKASI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return locationList;
                                }
                                return locationList.where((location) => 
                                  location.toLowerCase().contains(textEditingValue.text.toLowerCase())
                                );
                              },
                              onSelected: (selection) {
                                lokasiController.text = selection;
                                setStateDialog(() {});
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                controller.text = lokasiController.text;
                                controller.addListener(() {
                                  lokasiController.text = controller.text;
                                  setStateDialog(() {});
                                });
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: "Cari atau ketik lokasi baru...",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: lokasiController.text == "OUT LINE TO PREPARE" 
                                        ? Colors.red.shade50 
                                        : Colors.orange.shade50,
                                    prefixIcon: Icon(
                                      lokasiController.text == "OUT LINE TO PREPARE" 
                                          ? Icons.pending_actions 
                                          : Icons.location_on,
                                      color: lokasiController.text == "OUT LINE TO PREPARE" 
                                          ? Colors.red 
                                          : Colors.orange,
                                    ),
                                    suffixIcon: controller.text.isNotEmpty 
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18),
                                            onPressed: () {
                                              controller.clear();
                                              lokasiController.clear();
                                              setStateDialog(() {});
                                            }
                                          ) 
                                        : null,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: lokasiController.text == "OUT LINE TO PREPARE" 
                                        ? Colors.red 
                                        : Colors.black,
                                    fontWeight: lokasiController.text == "OUT LINE TO PREPARE" 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CODE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: isNewCode 
                                      ? TextFormField(
                                          controller: codeController,
                                          decoration: InputDecoration(
                                            hintText: "Ketik code baru...",
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            prefixIcon: const Icon(Icons.new_label, color: Colors.green),
                                          ),
                                          style: const TextStyle(fontSize: 16),
                                          onChanged: (value) {
                                            newCodeText = value;
                                            setStateDialog(() {});
                                          },
                                        )
                                      : Autocomplete<String>(
                                          optionsBuilder: (TextEditingValue textEditingValue) {
                                            if (textEditingValue.text.isEmpty) {
                                              return codeList;
                                            }
                                            return codeList.where((code) => 
                                              code.toLowerCase().contains(textEditingValue.text.toLowerCase())
                                            );
                                          },
                                          onSelected: (selection) {
                                            codeController.text = selection;
                                            setStateDialog(() {});
                                          },
                                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                            controller.addListener(() {
                                              codeController.text = controller.text;
                                              setStateDialog(() {});
                                            });
                                            return TextFormField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                hintText: "Pilih code yang sudah ada",
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                                filled: true,
                                                fillColor: Colors.grey.shade50,
                                                prefixIcon: const Icon(Icons.inventory),
                                              ),
                                              style: const TextStyle(fontSize: 16),
                                            );
                                          },
                                        ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    setStateDialog(() {
                                      isNewCode = !isNewCode;
                                      if (isNewCode) {
                                        codeController.clear();
                                      } else {
                                        codeController.clear();
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isNewCode ? Colors.green : Colors.grey,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  ),
                                  child: Text(isNewCode ? "Gunakan Code Lama" : "Code Baru"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("QTY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: qtyController,
                                    decoration: InputDecoration(
                                      hintText: "0",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    onChanged: (value) { 
                                      setStateDialog(() { 
                                        qtyValue = int.tryParse(value) ?? 0; 
                                      }); 
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () { 
                                    int current = int.tryParse(qtyController.text) ?? 0; 
                                    if (current > 0) { 
                                      qtyController.text = (current - 1).toString(); 
                                      setStateDialog(() { qtyValue = current - 1; }); 
                                    } 
                                  },
                                  child: Container(
                                    width: 48, 
                                    height: 48, 
                                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)), 
                                    child: const Icon(Icons.remove, color: Colors.red, size: 28)
                                  ),
                                ),
                                InkWell(
                                  onTap: () { 
                                    int current = int.tryParse(qtyController.text) ?? 0; 
                                    qtyController.text = (current + 1).toString(); 
                                    setStateDialog(() { qtyValue = current + 1; }); 
                                  },
                                  child: Container(
                                    width: 48, 
                                    height: 48, 
                                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)), 
                                    child: const Icon(Icons.add, color: Colors.green, size: 28)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("WEEKLY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: weeklyController, 
                              decoration: InputDecoration(
                                hintText: "Contoh: 1526",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                helperText: "Format: 2 digit minggu + 2 digit tahun (1526 = minggu 15 tahun 2026)"
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context), 
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ), 
                          child: const Text("BATAL", style: TextStyle(fontSize: 16, color: Colors.grey))
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            String code = codeController.text.trim().toUpperCase();
                            String qty = qtyController.text.trim();
                            String weekly = weeklyController.text.trim();
                            String lokasi = lokasiController.text.trim().toUpperCase();
                            
                            if (lokasi.isEmpty) { 
                              Utils.showErrorSnackbar(context, "Lokasi harus diisi"); 
                              return; 
                            }
                            if (code.isEmpty) { 
                              Utils.showErrorSnackbar(context, "Code harus diisi"); 
                              return; 
                            }
                            if (qty.isEmpty) { 
                              Utils.showErrorSnackbar(context, "Qty harus diisi"); 
                              return; 
                            }
                            
                            try {
                              Map<String, dynamic> newData = { 
                                'code': code, 
                                'qty': int.parse(qty), 
                                'lokasi': lokasi, 
                                'weekly': weekly.isEmpty ? null : weekly, 
                                'date_time': DateTime.now().toIso8601String(),
                                'uniq_id': 'UID-${DateTime.now().millisecondsSinceEpoch}',
                                'status': 'Normal Stock'
                              };
                              
                              await Supabase.instance.client.from('inventory_non_gws').insert(newData);
                              
                              if (mounted) { 
                                Navigator.pop(context); 
                                Utils.showSuccessSnackbar(context, "Data NON GWS berhasil ditambahkan di lokasi $lokasi"); 
                                _loadAllData(); 
                              }
                            } catch (e) { 
                              if (mounted) Utils.showErrorSnackbar(context, "Error: $e"); 
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, 
                            padding: const EdgeInsets.symmetric(vertical: 14), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text("SIMPAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CEK ACTUAL - BY AREA"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshCheckedItems, tooltip: "Reset semua status CEK OKE"),
          IconButton(icon: Icon(groupByLocation ? Icons.view_list : Icons.grid_view), onPressed: () { setState(() { groupByLocation = !groupByLocation; }); }, tooltip: groupByLocation ? "Tampilkan semua baris" : "Tampilkan ringkasan"),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));

    if (!groupByLocation) {
      List<Map<String, dynamic>> allItems = getAllItems();
      if (allItems.isEmpty) return const Center(child: Text("Tidak ada data"));
      Map<String, List<Map<String, dynamic>>> groupedByLocation = {};
      for (var item in allItems) {
        String lokasi = (item['lokasi'] ?? 'Unknown').toString();
        groupedByLocation.putIfAbsent(lokasi, () => []).add(item);
      }
      List<String> sortedLocations = groupedByLocation.keys.toList()..sort();
      return ListView.builder(
        itemCount: sortedLocations.length,
        itemBuilder: (context, index) {
          String lokasi = sortedLocations[index];
          List<Map<String, dynamic>> items = groupedByLocation[lokasi]!;
          int totalQtyLokasi = items.fold(0, (sum, item) => sum + ((item['qty'] ?? 0) as int));
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ExpansionTile(
              title: Row(children: [Expanded(child: Text(lokasi, style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.add_circle, color: Colors.green, size: 20), onPressed: () => _showAddItemDialog(lokasi), tooltip: "Tambah data NON GWS di lokasi ini")]),
              subtitle: Text("${items.length} item | Total Qty: $totalQtyLokasi Pcs"),
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final String itemId = item['unique_id'];
                bool isChecked = checkedItems.contains(itemId);
                String currentNote = notes[itemId] ?? '';
                String weekly = item['weekly']?.toString() ?? '-';
                return Container(
                  color: isChecked ? Colors.green.shade100 : null,
                  child: ListTile(
                    leading: Icon(item['source'] == 'GWS' ? Icons.inventory : Icons.warehouse, color: item['source'] == 'GWS' ? Colors.blue : Colors.orange),
                    title: Row(children: [Text((item['code'] ?? '-').toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 12), Expanded(child: Text(item['ticket_bc'] ?? '-', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis))]),
                    subtitle: Row(
                      children: [
                        Text("Weekly: $weekly", 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)
                        ),
                        const SizedBox(width: 12), 
                        Text("Qty: ${item['qty']} Pcs", 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                        )
                      ]
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Edit HANYA untuk NON GWS
                        if (item['source'] == 'NON GWS')
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange, size: 20), 
                            onPressed: () => _editItemNonGwsOnly(item, item['source']), 
                            tooltip: "Edit Qty/Lokasi (NON GWS only)"
                          ),
                        IconButton(
                          icon: Icon(isChecked ? Icons.check_circle : Icons.check_circle_outline, 
                          color: isChecked ? Colors.green : Colors.grey), 
                          onPressed: () { _saveCheckedStatus(itemId, !isChecked); }
                        ),
                        IconButton(
                          icon: Icon(currentNote.isNotEmpty ? Icons.edit_note : Icons.note_add, 
                          color: currentNote.isNotEmpty ? Colors.blue : Colors.grey), 
                          onPressed: () { _showNoteDialog(itemId, currentNote); }
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    }
    
    var blocks = getBlocksWithLines();
    if (blocks.isEmpty) return const Center(child: Text("Tidak ada data lokasi"));

    return ListView.builder(
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        String block = blocks.keys.elementAt(index);
        List<String> lines = blocks[block]!;
        int totalQtyBlock = 0;
        for (var line in lines) {
          var items = getItemsByLine(line);
          for (var item in items) totalQtyBlock += (item['qty'] ?? 0) as int;
        }
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ExpansionTile(
            leading: CircleAvatar(backgroundColor: block.startsWith('1') ? Colors.blue.shade100 : Colors.green.shade100, child: Text(block)),
            title: Text("BLOK $block", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text("${lines.length} Line | Total Qty: $totalQtyBlock Pcs"),
            children: lines.map((line) {
              var items = getItemsByLine(line);
              int totalQtyLine = items.fold(0, (sum, item) => sum + ((item['qty'] ?? 0) as int));
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: block.startsWith('1') ? Colors.blue.shade50 : Colors.green.shade50,
                child: ExpansionTile(
                  title: Row(children: [Expanded(child: Text(line, style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.add_circle, color: Colors.green, size: 20), onPressed: () => _showAddItemDialog(line), tooltip: "Tambah data NON GWS di lokasi ini")]),
                  subtitle: Text("${items.length} item | Total Qty: $totalQtyLine Pcs"),
                  children: items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final String itemId = item['unique_id'];
                    bool isChecked = checkedItems.contains(itemId);
                    String currentNote = notes[itemId] ?? '';
                    String weekly = item['weekly']?.toString() ?? '-';
                    return Container(
                      color: isChecked ? Colors.green.shade100 : null,
                      child: ListTile(
                        leading: Icon(item['source'] == 'GWS' ? Icons.inventory : Icons.warehouse, color: item['source'] == 'GWS' ? Colors.blue : Colors.orange),
                        title: Row(children: [Text((item['code'] ?? '-').toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 12), Expanded(child: Text(item['ticket_bc'] ?? '-', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis))]),
                        subtitle: Row(
                          children: [
                            Text("Weekly: $weekly", 
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)
                            ),
                            const SizedBox(width: 12), 
                            Text("Qty: ${item['qty']} Pcs", 
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                            )
                          ]
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Edit HANYA untuk NON GWS
                            if (item['source'] == 'NON GWS')
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange, size: 20), 
                                onPressed: () => _editItemNonGwsOnly(item, item['source']), 
                                tooltip: "Edit Qty/Lokasi (NON GWS only)"
                              ),
                            IconButton(
                              icon: Icon(isChecked ? Icons.check_circle : Icons.check_circle_outline, 
                              color: isChecked ? Colors.green : Colors.grey), 
                              onPressed: () { _saveCheckedStatus(itemId, !isChecked); }
                            ),
                            IconButton(
                              icon: Icon(currentNote.isNotEmpty ? Icons.edit_note : Icons.note_add, 
                              color: currentNote.isNotEmpty ? Colors.blue : Colors.grey), 
                              onPressed: () { _showNoteDialog(itemId, currentNote); }
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}