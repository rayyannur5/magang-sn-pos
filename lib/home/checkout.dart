import 'package:flutter/foundation.dart';

class ItemManagement extends ChangeNotifier {
  int _itemTambahAnginMotor = 0;
  int _itemTambahAnginMobil = 0;
  int _itemIsiBaruMotor = 0;
  int _itemIsiBaruMobil = 0;
  int _itemTambalBanMotor = 0;
  int _itemTambalBanMobil = 0;

  final int _priceTambahAnginMotor = 2500;
  final int _priceTambahAnginMobil = 4000;
  final int _priceIsiBaruMotor = 3500;
  final int _priceIsiBaruMobil = 7000;
  final int _priceTambalBanMotor = 10000;
  final int _priceTambalBanMobil = 15000;

  int getCounter() {
    return _itemTambahAnginMotor + _itemTambahAnginMobil + _itemIsiBaruMotor + _itemIsiBaruMobil + _itemTambalBanMotor + _itemTambalBanMobil;
  }

  int getPrice() {
    return (_itemTambahAnginMotor * _priceTambahAnginMotor) +
        (_itemTambahAnginMobil * _priceTambahAnginMobil) +
        (_itemIsiBaruMotor * _priceIsiBaruMotor) +
        (_itemIsiBaruMobil * _priceIsiBaruMobil) +
        (_itemTambalBanMotor * _priceTambalBanMotor) +
        (_itemTambalBanMobil * _priceTambalBanMobil);
  }

  List getItems() {
    List result = [];
    if (_itemTambahAnginMotor != 0) result.add({'name': 'Tambah Angin Motor', 'count': _itemTambahAnginMotor, 'price': _itemTambahAnginMotor * _priceTambahAnginMotor});
    if (_itemTambahAnginMobil != 0) result.add({'name': 'Tambah Angin Mobil', 'count': _itemTambahAnginMobil, 'price': _itemTambahAnginMobil * _priceTambahAnginMobil});
    if (_itemIsiBaruMotor != 0) result.add({'name': 'Isi Baru Motor', 'count': _itemIsiBaruMotor, 'price': _itemIsiBaruMotor * _priceIsiBaruMotor});
    if (_itemIsiBaruMobil != 0) result.add({'name': 'Isi baru Mobil', 'count': _itemIsiBaruMobil, 'price': _itemIsiBaruMobil * _priceIsiBaruMobil});
    if (_itemTambalBanMotor != 0) result.add({'name': 'Tambal Ban Motor', 'count': _itemTambalBanMotor, 'price': _itemTambalBanMotor * _priceTambalBanMotor});
    if (_itemTambalBanMobil != 0) result.add({'name': 'Tambah Ban Mobil', 'count': _itemTambalBanMobil, 'price': _itemTambalBanMobil * _priceTambalBanMobil});
    return result;
  }

  int getItem(int index) {
    switch (index) {
      case 0:
        return _itemTambahAnginMotor;
      case 1:
        return _itemTambahAnginMobil;
      case 2:
        return _itemIsiBaruMotor;
      case 3:
        return _itemIsiBaruMobil;
      case 4:
        return _itemTambalBanMotor;
      case 5:
        return _itemTambalBanMobil;
      default:
        return 0;
    }
  }

  void setItem(int index, int val) {
    switch (index) {
      case 0:
        _itemTambahAnginMotor = val;
        break;
      case 1:
        _itemTambahAnginMobil = val;
        break;
      case 2:
        _itemIsiBaruMotor = val;
        break;
      case 3:
        _itemIsiBaruMobil = val;
        break;
      case 4:
        _itemTambalBanMotor = val;
        break;
      case 5:
        _itemTambalBanMobil = val;
        break;
    }
  }

  int get itemTambahAnginMotor => _itemTambahAnginMotor;
  int get itemTambahAnginMobil => _itemTambahAnginMobil;
  int get itemIsiBaruMotor => _itemIsiBaruMotor;
  int get itemIsiBaruMobil => _itemIsiBaruMobil;
  int get itemTambalBanMotor => _itemTambalBanMotor;
  int get itemTambalBanMobil => _itemTambalBanMobil;

  void reset() {
    _itemTambahAnginMotor = 0;
    _itemTambahAnginMobil = 0;
    _itemIsiBaruMotor = 0;
    _itemIsiBaruMobil = 0;
    _itemTambalBanMotor = 0;
    _itemTambalBanMobil = 0;
  }

  set itemTambahAnginMotor(int val) {
    _itemTambahAnginMotor = val;
  }

  set itemTambahAnginMobil(int val) {
    _itemTambahAnginMobil = val;
  }

  set itemIsiBaruMotor(int val) {
    _itemIsiBaruMotor = val;
  }

  set itemIsiBaruMobil(int val) {
    _itemIsiBaruMobil = val;
  }

  set itemTambalBanMotor(int val) {
    _itemTambalBanMotor = val;
  }

  set itemTambalBanMobil(int val) {
    _itemTambalBanMobil = val;
  }
}
