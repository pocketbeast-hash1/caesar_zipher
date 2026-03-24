import 'package:caesar_zipher/models/global_state_model.dart';
import 'package:caesar_zipher/utils/queue.dart';

abstract class QueueFacade {
  static Future<void> loadQueue(List<String> codes, GlobalStateModel state) async {
    await Queue.loadQueue(codes);
    state.setCodes(codes);
  }
}