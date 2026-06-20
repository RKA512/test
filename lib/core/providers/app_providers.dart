import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

// --- Entities & Repositories imports ---
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

import '../../features/apartments/domain/entities/apartment_entity.dart';
import '../../features/apartments/domain/repositories/apartment_repository.dart';
import '../../features/apartments/data/repositories/apartment_repository_impl.dart';
import '../../features/apartments/data/models/apartment_model.dart';

import '../../features/guests/domain/entities/guest_entity.dart';
import '../../features/guests/domain/repositories/guest_repository.dart';
import '../../features/guests/data/repositories/guest_repository_impl.dart';
import '../../features/guests/data/models/guest_model.dart';

import '../../features/bookings/domain/entities/booking_entity.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/data/models/booking_model.dart';

import '../../features/expenses/domain/entities/expense_entity.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/data/models/expense_model.dart';

import '../../features/payments/domain/entities/payment_entity.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/data/models/payment_model.dart';

import '../services/backup_service.dart';

// ==========================================
// REPOSITORY PROVIDERS
// ==========================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(dbHelper: DatabaseHelper.instance);
});

final apartmentRepositoryProvider = Provider<ApartmentRepository>((ref) {
  return ApartmentRepositoryImpl(dbHelper: DatabaseHelper.instance);
});

final guestRepositoryProvider = Provider<GuestRepository>((ref) {
  return GuestRepositoryImpl(dbHelper: DatabaseHelper.instance);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(dbHelper: DatabaseHelper.instance);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(dbHelper: DatabaseHelper.instance);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(dbHelper: DatabaseHelper.instance);
});

// ==========================================
// AUTHENTICATION PROVIDER (StateNotifier)
// ==========================================

class AuthState {
  final UserEntity? currentUser;
  final bool isLoading;
  final String? errorMessage;

  const AuthState(
      {this.currentUser, this.isLoading = false, this.errorMessage});

  AuthState copyWith(
      {UserEntity? currentUser, bool? isLoading, String? errorMessage}) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _initSession();
  }

  Future<void> _initSession() async {
    final user = await _repository.fetchCurrentUser();
    if (user != null) {
      state = AuthState(currentUser: user);
      DatabaseHelper.activeUserId = user.id;
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user =
          await _repository.login(username: username, password: password);
      state = AuthState(currentUser: user);
      DatabaseHelper.activeUserId = user.id;
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
    DatabaseHelper.activeUserId = null;
  }

  Future<void> createUser(
      String username, String password, String fullName, String role) async {
    await _repository.createUser(
      username: username,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    if (state.currentUser?.id == null) return;
    await _repository.changePassword(
      userId: state.currentUser!.id!,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

// ==========================================
// APARTMENTS PROVIDER
// ==========================================

class ApartmentsNotifier
    extends StateNotifier<AsyncValue<List<ApartmentEntity>>> {
  final ApartmentRepository _repository;

  ApartmentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadApartments();
  }

  Future<void> loadApartments() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchAllApartments();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createApartment(ApartmentModel apt) async {
    await _repository.createApartment(apt);
    await loadApartments();
  }

  Future<void> updateApartment(ApartmentModel apt) async {
    await _repository.updateApartment(apt);
    await loadApartments();
  }

  Future<void> changeStatus(int id, ApartmentStatus status) async {
    await _repository.changeApartmentStatus(id, status);
    await loadApartments();
  }

  Future<void> deleteApartment(int id, int adminUserId) async {
    await _repository.deleteApartment(id, adminUserId: adminUserId);
    await loadApartments();
  }
}

final apartmentsProvider = StateNotifierProvider<ApartmentsNotifier,
    AsyncValue<List<ApartmentEntity>>>((ref) {
  final repo = ref.watch(apartmentRepositoryProvider);
  return ApartmentsNotifier(repo);
});

// ==========================================
// GUEST PROVIDER
// ==========================================

class GuestsNotifier extends StateNotifier<AsyncValue<List<GuestEntity>>> {
  final GuestRepository _repository;

  GuestsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadGuests();
  }

  Future<void> loadGuests() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchAllGuests();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> createGuest(GuestModel guest) async {
    final id = await _repository.createGuest(guest);
    await loadGuests();
    return id;
  }

  Future<void> updateGuest(GuestModel guest) async {
    await _repository.updateGuest(guest);
    await loadGuests();
  }

  Future<void> deleteGuest(int id) async {
    await _repository.deleteGuest(id);
    await loadGuests();
  }
}

final guestsProvider =
    StateNotifierProvider<GuestsNotifier, AsyncValue<List<GuestEntity>>>((ref) {
  final repo = ref.watch(guestRepositoryProvider);
  return GuestsNotifier(repo);
});

// ==========================================
// BOOKINGS PROVIDER
// ==========================================

class BookingsNotifier extends StateNotifier<AsyncValue<List<BookingEntity>>> {
  final BookingRepository _repository;
  final Ref _ref;

  BookingsNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchAllBookings();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    await _repository.createBooking(booking);

    // Refresh bookings & apartments as occupied
    await loadBookings();
    await _ref.read(apartmentsProvider.notifier).loadApartments();
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _repository.updateBooking(booking);
    await loadBookings();
    await _ref.read(apartmentsProvider.notifier).loadApartments();
  }

  Future<void> updateStatus({
    required int bookingId,
    required BookingStatus status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) async {
    await _repository.updateBookingStatus(
      bookingId: bookingId,
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );
    await loadBookings();
    await _ref.read(apartmentsProvider.notifier).loadApartments();
  }

  Future<void> cancelBooking(int bookingId) async {
    await _repository.cancelBooking(bookingId);
    await loadBookings();
    await _ref.read(apartmentsProvider.notifier).loadApartments();
  }
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, AsyncValue<List<BookingEntity>>>(
        (ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return BookingsNotifier(repo, ref);
});

// ==========================================
// EXPENSES PROVIDER
// ==========================================

class ExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseEntity>>> {
  final ExpenseRepository _repository;

  ExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchAllExpenses();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createExpense(ExpenseModel expense) async {
    await _repository.createExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _repository.deleteExpense(id);
    await loadExpenses();
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<ExpenseEntity>>>(
        (ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return ExpensesNotifier(repo);
});

// ==========================================
// PAYMENTS PROVIDER
// ==========================================

class PaymentsNotifier extends StateNotifier<AsyncValue<List<PaymentEntity>>> {
  final PaymentRepository _repository;

  PaymentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAllPayments();
  }

  Future<void> loadAllPayments() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchAllPayments();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<PaymentEntity>> loadPaymentsForBooking(int bookingId) async {
    try {
      final list = await _repository.fetchPaymentsForBooking(bookingId);
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    await _repository.createPayment(payment);
    await loadAllPayments();
  }
}

final paymentsProvider =
    StateNotifierProvider<PaymentsNotifier, AsyncValue<List<PaymentEntity>>>(
        (ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentsNotifier(repo);
});
