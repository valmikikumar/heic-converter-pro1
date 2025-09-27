import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/conversion_model.dart';
import '../utils/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Operations
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Conversion Operations
  Future<void> saveConversion(ConversionModel conversion) async {
    try {
      await _firestore
          .collection(AppConstants.conversionsCollection)
          .doc(conversion.id)
          .set(conversion.toJson());
      
      // Update user's total conversions count
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(conversion.userId)
          .update({
        'totalConversions': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to save conversion: $e');
    }
  }

  Future<List<ConversionModel>> getUserConversions(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.conversionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('convertedAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ConversionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user conversions: $e');
    }
  }

  Future<void> deleteConversion(String conversionId) async {
    try {
      await _firestore
          .collection(AppConstants.conversionsCollection)
          .doc(conversionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete conversion: $e');
    }
  }

  // Purchase Operations
  Future<void> savePurchase(String userId, Map<String, dynamic> purchaseData) async {
    try {
      await _firestore
          .collection(AppConstants.purchasesCollection)
          .add({
        'userId': userId,
        'purchaseData': purchaseData,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to save purchase: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserPurchases(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.purchasesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      throw Exception('Failed to get user purchases: $e');
    }
  }

  // Analytics Operations
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final conversionsSnapshot = await _firestore
          .collection(AppConstants.conversionsCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      final conversions = conversionsSnapshot.docs
          .map((doc) => ConversionModel.fromJson(doc.data()))
          .toList();
      
      final totalFiles = conversions.length;
      final totalOriginalSize = conversions.fold<int>(
        0,
        (sum, conversion) => sum + conversion.originalSize,
      );
      final totalConvertedSize = conversions.fold<int>(
        0,
        (sum, conversion) => sum + conversion.convertedSize,
      );
      final spaceSaved = totalOriginalSize - totalConvertedSize;
      
      // Group by format
      final formatStats = <String, int>{};
      for (final conversion in conversions) {
        formatStats[conversion.outputFormat] = 
            (formatStats[conversion.outputFormat] ?? 0) + 1;
      }
      
      return {
        'totalFiles': totalFiles,
        'totalOriginalSize': totalOriginalSize,
        'totalConvertedSize': totalConvertedSize,
        'spaceSaved': spaceSaved,
        'formatStats': formatStats,
        'averageCompression': totalOriginalSize > 0 
            ? ((spaceSaved / totalOriginalSize) * 100).toStringAsFixed(1)
            : '0.0',
      };
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  // Admin Operations
  Future<List<UserModel>> getAllUsers({int limit = 100}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  Future<Map<String, dynamic>> getAppStats() async {
    try {
      final usersSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .get();
      
      final conversionsSnapshot = await _firestore
          .collection(AppConstants.conversionsCollection)
          .get();
      
      final totalUsers = usersSnapshot.docs.length;
      final totalConversions = conversionsSnapshot.docs.length;
      final proUsers = usersSnapshot.docs
          .where((doc) => (doc.data()['isPro'] ?? false) == true)
          .length;
      
      return {
        'totalUsers': totalUsers,
        'totalConversions': totalConversions,
        'proUsers': proUsers,
        'freeUsers': totalUsers - proUsers,
        'conversionRate': totalUsers > 0 ? (totalConversions / totalUsers).toStringAsFixed(2) : '0.0',
      };
    } catch (e) {
      throw Exception('Failed to get app stats: $e');
    }
  }
}
