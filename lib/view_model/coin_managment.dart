import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../ads/AdsVariable.dart';
import '../utils/app_constants.dart';


class CoinProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _coinKey = 'coins';
  static const String _uuidKey = 'uuid'; // Key to store the UUID
  final Uuid _uuidGenerator = Uuid();

  int _coins = 0;
  int get coins => _coins;

  set coins(int value) {
    _coins = value;
    notifyListeners();
  }

  // Fetch coins
  Future<void> fetchCoins() async {
    String randomId = await getRandomId();
    int? currentCoins = await getCoins(randomId);

    coins = currentCoins ?? 0;
    notifyListeners();
  }

  // Get or generate a random ID
  Future<String> getRandomId() async {
    try {
      String? storedUuid = await _storage.read(key: _uuidKey);

      if (storedUuid == null) {
        // Generate a new UUID if none exists
        String newUuid = _uuidGenerator.v4();
        await _storage.write(key: _uuidKey, value: newUuid);
        return newUuid;
      }

      return storedUuid; // Return the existing UUID
    } catch (e) {
      print('Error fetching random ID: $e');
      return _uuidGenerator.v4(); // Generate a fallback UUID
    }
  }

  // Function to create the store (initialize coins for the first time)
  Future<void> createNewStore() async {
    String randomId = await getRandomId();
    final existingCoins = await getCoins(randomId);

    // If the user has no existing coins, set the initial coins from AdsVariable
    if (existingCoins == null) {
      _coins = AdsVariable.ca_free_coin;
      await saveCoins(randomId, AdsVariable.ca_free_coin);

      print(
          'New store created for $randomId with ${AdsVariable.ca_free_coin} coins.');
    } else {
      _coins = existingCoins;
      print('Store already exists for $randomId with $existingCoins coins.');
    }
    notifyListeners();
  }

  Future<void> resetCoin() async {
    String randomId = await getRandomId();
    final existingCoins = await getCoins(randomId);
    _coins = 0;
    await saveCoins(randomId, _coins);
    notifyListeners();
  }

  Future<void> saveCoins(String randomId, int coins) async {
    await _storage.write(key: '$_coinKey$randomId', value: coins.toString());
  }

  Future<int?> getCoins(String randomId) async {
    try {
      String? value = await _storage.read(key: '$_coinKey$randomId');
      coins = int.tryParse(value ?? "0") ?? 0;
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      print('Error reading coins for $randomId: $e');
      return null;
    }
  }

  // Increment coins (e.g., when a user purchases coins)
  Future<void> incrementCoins(int amount) async {
    String randomId = await getRandomId();
    int? currentCoins = await getCoins(randomId);

    if (currentCoins != null) {
      currentCoins += amount;
      showLog("this is coind added on purcahse $currentCoins");
      await saveCoins(randomId, currentCoins);

      _coins = currentCoins;
      notifyListeners();
    }
  }

  // Decrement coins (e.g., when coins are spent, e.g., API calls)
  Future<void> decrementCoins(int amount) async {
    showLog('Call decrement coind method');
    String randomId = await getRandomId();
    int? currentCoins = await getCoins(randomId);
    showLog('decrementCoins: currentCoins=$currentCoins, amount=$amount');
    if (currentCoins != null && currentCoins >= amount) {
      currentCoins -= amount;
      await saveCoins(randomId, currentCoins);

      _coins = currentCoins;
      notifyListeners();
      showLog('this is decrement coins after $_coins');
    } else {
      showLog('Insufficient coins or no coins found.');
    }
  }

  // Reset coins to a new value
  Future<void> resetCoins(int newAmount) async {
    String randomId = await getRandomId();
    await saveCoins(randomId, newAmount);

    _coins = newAmount;
    notifyListeners();
  }
}
