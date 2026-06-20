import '../../../../core/error/failures.dart';
import '../entities/apartment_entity.dart';
import '../../data/models/apartment_model.dart';

abstract class ApartmentRepository {
  Future<List<ApartmentEntity>> fetchAllApartments();
  
  Future<ApartmentEntity?> fetchApartmentById(int id);

  Future<void> createApartment(ApartmentModel apartment);

  Future<void> updateApartment(ApartmentModel apartment);

  Future<void> changeApartmentStatus(int apartmentId, ApartmentStatus status);

  Future<void> deleteApartment(int apartmentId, {required int adminUserId});
}
