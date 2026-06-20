import '../../../../core/error/failures.dart';
import '../entities/guest_entity.dart';
import '../../data/models/guest_model.dart';

abstract class GuestRepository {
  Future<List<GuestEntity>> fetchAllGuests();
  Future<GuestEntity?> fetchGuestById(int id);
  Future<int> createGuest(GuestModel guest);
  Future<void> updateGuest(GuestModel guest);
  Future<void> deleteGuest(int id);
}
