
import 'package:stock_submat/main.dart';

class SupabaseFunc{
  Future<List<Map<String, dynamic>>> fetchSrn(String tablename, String items, String conditions, String groupby) async{
    final data = await supabase.rpc('select_groupby', params: {
      'table_name': tablename, 
      'select_item': items, 
      'conditions': conditions,
      'group_by': groupby
      });

    if(data != null && data is List){
      return List<Map<String, dynamic>>.from(data);
    } else {
      return [];
    }
  }
}