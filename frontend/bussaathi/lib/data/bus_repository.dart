import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus.dart';
import '../models/bus_position.dart';
import '../models/route_info.dart';
import '../models/stop.dart';

class BusRepository {
  SupabaseClient get _db => Supabase.instance.client;

  Future<List<RouteInfo>> routes() async {
    final rows = await _db.from('routes').select().order('id');
    return rows.map<RouteInfo>((m) => RouteInfo.fromMap(m)).toList();
  }

  Future<List<Stop>> stops(int routeId) async {
    final rows = await _db
        .from('stops')
        .select()
        .eq('route_id', routeId)
        .order('stop_order');
    return rows.map<Stop>((m) => Stop.fromMap(m)).toList();
  }

  Future<List<Bus>> buses() async {
    final rows = await _db.from('buses').select().order('id');
    return rows.map<Bus>((m) => Bus.fromMap(m)).toList();
  }

  Future<List<Bus>> busesOnRoute(int routeId) async {
    final rows =
        await _db.from('buses').select().eq('route_id', routeId).order('id');
    return rows.map<Bus>((m) => Bus.fromMap(m)).toList();
  }

  Stream<List<BusPosition>> positions() {
    return _db
        .from('bus_positions')
        .stream(primaryKey: ['bus_id'])
        .map((rows) => rows.map<BusPosition>((m) => BusPosition.fromMap(m)).toList());
  }
}

final repo = BusRepository();
