// ignore: file_names
import 'package:flutter/foundation.dart';

class ItemManagement extends ChangeNotifier {
  List _item = [];
  int _banyakItems = 0;
  final List<int> _penghitungItem = [];

  void setItems(List data, int banyakData) {
    _item = data;
    _banyakItems = banyakData;
    for (int i = 0; i < banyakData; i++) {
      _penghitungItem.add(0);
    }
  }

  int getBanyakItems() {
    return _banyakItems;
  }

  int getCounter() {
    int hitung = 0;
    for (int i = 0; i < _banyakItems; i++) {
      hitung += _penghitungItem[i];
    }
    return hitung;
  }

  int getPrice() {
    int price = 0;
    for (int i = 0; i < _banyakItems; i++) {
      price += (_penghitungItem[i] * int.parse(_item[i]['harga_produk']));
    }
    return price;
  }

  List getItems() {
    return _item;
  }

  List getItemsSelected() {
    List result = [];
    for (int i = 0; i < _banyakItems; i++) {
      if (_penghitungItem[i] != 0)
        result.add({'id_produk': _item[i]['id_produk'], 'name': _item[i]['nama_produk'], 'count': _penghitungItem[i], 'price': _penghitungItem[i] * int.parse(_item[i]['harga_produk'])});
    }
    return result;
  }

  int getItem(int index) {
    return _penghitungItem[index];
  }

  void setItem(int index, int val) {
    _penghitungItem[index] = val;
  }

  void reset() {
    for (int i = 0; i < _banyakItems; i++) {
      _penghitungItem[i] = 0;
    }
    _item = [];
  }
}
