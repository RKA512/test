export type ApartmentStatus = 'available' | 'occupied' | 'cleaning' | 'maintenance';
export type BookingStatus = 'confirmed' | 'pending_arrival' | 'checked_in' | 'completed' | 'cancelled';
export type UserRole = 'admin' | 'receptionist';

export interface Apartment {
  id: string; // INT PRIMARY KEY AUTOINCREMENT in SQLite
  name: string;
  roomsCount: number;
  bedsCount: number;
  nightlyPrice: number;
  notes: string;
  images: string[]; // paths stored as JSON string in SQLite
  status: ApartmentStatus;
}

export interface Guest {
  id: string; // INT PRIMARY KEY AUTOINCREMENT
  fullName: string;
  phone: string;
  idCardNumber: string;
  nationality: string;
  notes: string;
}

export interface Booking {
  id: string; // INT PRIMARY KEY AUTOINCREMENT
  bookingNumber: string;
  guestId: string;
  apartmentId: string;
  checkInDate: string; // ISO String or YYYY-MM-DD
  checkOutDate: string; // ISO String or YYYY-MM-DD
  nightsCount: number;
  totalPrice: number;
  paidAmount: number;
  remainingAmount: number;
  status: BookingStatus;
  notes?: string;
  personsCount?: number;
}

export interface AppUser {
  id: string;
  username: string;
  fullName: string;
  role: UserRole;
}

export interface Expense {
  id: string;
  amount: number;
  date: string; // YYYY-MM-DD
  category: 'maintenance' | 'cleaning' | 'bills' | 'furniture' | 'other';
  notes: string;
  apartmentId?: string; // Optional related apartment ID
}

export interface SecuritySession {
  currentUser: AppUser | null;
  isAuthenticated: boolean;
}
