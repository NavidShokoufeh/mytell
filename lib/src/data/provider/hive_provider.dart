import 'package:hive/hive.dart';
import 'package:voipmax/src/bloc/bloc.dart';
import 'package:voipmax/src/data/models/recent_calls_model.dart';
import 'package:voipmax/src/repo.dart';

class HiveDBProvider extends Bloc {
  late Box<dynamic> box;
  MyTelRepo repo = MyTelRepo();

  saveRecentCallLog({required List<RecentCallsModel>? callLog}) {
    try {
      box.put("${repo.sipServer?.data?.extension}@recentCalls", callLog);
    } catch (e) {
      print(e);
    }
  }

  Future<List<RecentCallsModel>> getRecentCalls() async {
    List<RecentCallsModel> recents = [];
    try {
      box = await Hive.openBox("recents");
      recents =
          box.get("${repo.sipServer?.data?.extension}@recentCalls") != null
              ? box
                      .get("${repo.sipServer?.data?.extension}@recentCalls")
                      .cast<RecentCallsModel>() ??
                  []
              : [];
    } catch (e) {
      recents = [];
    }
    return recents;
  }
}
