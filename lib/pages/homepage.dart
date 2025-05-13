
import 'package:flutter/material.dart';
import 'package:stock_submat/services/supabase_func.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supaFunc = SupabaseFunc();
  final _controllerSRN = TextEditingController();
  bool _selectBool = false;
  String itemTitle = '';
  String subTitle = '';
  String textTitle = '';
  String srntext = '';

  List<Map<String, dynamic>> data = [];

  Future<List<Map<String, dynamic>>> clickItemCode(srnNo) async {
    final result = await supaFunc.fetchSrn(
      'srn_sm',
      ' "SRN_NO", "Item_code", "Locator", "sewing_packing", "UOM", "Item_Desc", SUM("Issue_Qty") as "Issue_Qty" ',
      ' "SRN_NO" LIKE \'%$srnNo%\' AND "user_stock" IS NULL ',
      ' "SRN_NO", "Item_code", "Locator", "sewing_packing", "UOM", "Item_Desc"'
    );

    if (result.isNotEmpty) {
      setState(() {
        data = List<Map<String, dynamic>>.from(result);
      });
      _selectBool = true;
      srntext = data[0]['SRN_NO'];
      return data;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> clickLocator(srnNo) async {
    final result = await supaFunc.fetchSrn(
      'srn_sm',
      ' "SRN_NO", "Locator", "Item_code", "sewing_packing", "UOM", "Item_Desc", SUM("Issue_Qty") as "Issue_Qty" ',
      ' "SRN_NO" LIKE \'%$srnNo%\' AND "user_stock" IS NULL ',
      ' "SRN_NO", "Locator", "Item_code", "sewing_packing", "UOM", "Item_Desc"'
    );
    if (result.isNotEmpty) {
      setState(() {
        data = List<Map<String, dynamic>>.from(result);
      });
      _selectBool = false;
      srntext = data[0]['SRN_NO'];
      return data;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP SubMat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controllerSRN,
              decoration: InputDecoration(
                hintText: 'Tìm theo SRN_NO',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                _controllerSRN.value = _controllerSRN.value.copyWith(
                  text: value.toUpperCase(),
                  selection: TextSelection.collapsed(offset: value.length),
                );
              },
            ),
            const SizedBox(height: 15,),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12), 
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_controllerSRN.text.isNotEmpty) {
                        clickItemCode(_controllerSRN.text);
                      }
                    },
                    child: const Text('Item Code'),
                  ),
                  ElevatedButton(onPressed: (){
                    if (_controllerSRN.text.isNotEmpty) {
                      clickLocator(_controllerSRN.text);
                    }
                  }, child: const Text('Locator'))
                ],
              ),
            ),
            // Hiển thị số SRN_NO ở đây
            const SizedBox(height: 20,),
            
            if (data.isNotEmpty)
              Row(
                children: [
                  Text('SRN_NO: $srntext'),
                ],
              ),

              const SizedBox(height: 20,),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    if (_selectBool) {
                      itemTitle = item['Item_code'];
                      subTitle = item['Locator'];
                      textTitle = 'Locator';
                    }else{
                      itemTitle = item['Locator'];
                      subTitle = item['Item_code'];
                      textTitle = 'Item Code';
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        
                        title: Text(
                          itemTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$textTitle: $subTitle'),
                            Text('Issue Qty: ${item['Issue_Qty']}'),
                            Text('Loại: ${item['sewing_packing']}'),
                          ],
                        ),

                        trailing: const Icon(Icons.info_outline, color: Colors.blueAccent),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Thông tin thêm'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('UOM: ${item['UOM']}'),
                                  Text('Item Desc: ${item['Item_Desc']}'),
                                  
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Đóng'),
                                  onPressed: () => Navigator.of(context).pop(),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
          ]
        ),
      ),
    );
  }
}