import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/home/checkout_screen.dart';
import 'package:sn_pos/home/items.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/styles/general_button.dart';
import 'package:http/http.dart' as http;
import 'package:sn_pos/styles/navigator.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  Future kirimTRXkeDB() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getKeys());
    for (var i in pref.getKeys()) {
      if (i.contains('TRX')) {
        var id_user = pref.getString('id_user') ?? 0;
        var store_id_active = pref.getString('store_id_active');
        var shift = pref.getString('shift');
        String qty = (pref.getString(i)!.split('C').length - 1).toString();
        String data = pref.getString(i) ?? '';
        data = data.substring(0, data.length - 1);
        String trx = i.split('-').last;
        var resp = await http.get(Uri.parse('${Constants.urlKirimTransaksi}?id=$id_user&shift=$shift&store=$store_id_active&qty=$qty&trx=$trx&data=$data'));

        print(resp.body);
        if (resp.body.contains('aytechsuksestransaksi-')) {
          pref.remove(i);
          print('masuk sini');
        }
      }
    }
  }

  HomeScreen({super.key}) {
    kirimTRXkeDB();
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAbsen = true;
  List dataProduk = [];
  int banyakProduk = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<ItemManagement>(
        builder: (context, itemManagement, child) => FutureBuilder<dynamic>(
            future: Item().getItem(),
            builder: (context, snapshot) {
              if (itemManagement.getItems().isEmpty) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                String response = snapshot.data;

                if (response == 'XXXX--') {
                  isAbsen = false;
                } else if (response == '404') {
                  // SchedulerBinding.instance.addPostFrameCallback((_) {
                  //   Navigator.push(context, new MaterialPageRoute(builder: (context) => NoInternetScreen()));
                  // });
                } else if (response == 'error') {
                } else {
                  var splitBanyakProduk = response.split('QWDF--');
                  var splitProduk = splitBanyakProduk[1].split('CYMG--');

                  banyakProduk = int.parse(splitBanyakProduk[0]);

                  for (int i = 0; i < banyakProduk; i++) {
                    var produk = splitProduk[i].split('ZXZX--');
                    dataProduk.add({
                      'id_produk': produk[0],
                      'nama_produk': produk[1],
                      'kategori': produk[2],
                      'harga_produk': produk[3],
                    });
                  }
                  itemManagement.setItems(dataProduk, banyakProduk);
                }
                // print(dataProduk);
              }
              return Column(
                children: [
                  Container(
                    height: (size.height) / 6,
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.fromLTRB(size.width / 15, 0, size.width / 15, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Katalog', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800)),
                        isAbsen
                            ? Row(
                                children: [
                                  itemManagement.getPrice() != 0
                                      ? GestureDetector(
                                          onTap: () {
                                            itemManagement.reset();
                                            setState(() {});
                                          },
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.red, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 4))]),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(width: 10),
                                  Material(
                                    elevation: 10,
                                    color: const Color(0xff03045E),
                                    borderRadius: BorderRadius.circular(15),
                                    child: InkWell(
                                      onTap: () {
                                        if (itemManagement.getPrice() != 0) Nav.push(context, const CheckoutScreen());
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: 50,
                                        width: itemManagement.getPrice() == 0 ? 50 : 100,
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            itemManagement.getPrice() != 0
                                                ? Text(
                                                    itemManagement.getPrice().toString(),
                                                    style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                                  )
                                                : const SizedBox(),
                                            const Icon(Icons.shopping_cart, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height - (size.height / 5),
                    // width: size.width,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        itemManagement.reset();
                        Nav.pushReplacement(context, const MenuScreen(initialPage: 0));
                      },
                      child: ListView(
                        children: isAbsen
                            ? [
                                for (int i = 0; i < itemManagement.getBanyakItems(); i++)
                                  cardItem(size, itemManagement.getItems()[i]['kategori'], itemManagement.getItems()[i]['nama_produk'], itemManagement.getItems()[i]['harga_produk'], i),
                                const SizedBox(height: 100),
                              ]
                            : [
                                Image.asset('assets/image/belum-absen.png', scale: 2),
                                const Text('Absen dulu ya...', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
                                  child: GeneralButton(text: 'Absen', onTap: () => Nav.pushReplacement(context, const MenuScreen(initialPage: 1))),
                                )
                              ],
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }

  Container cardItem(Size size, kategori, String title, price, index) {
    String icon = "";
    if (kategori == '0') {
      if (title.contains('MOTOR')) {
        icon = 'assets/image/icon-motor.png';
      } else {
        icon = 'assets/image/icon-mobil.png';
      }
    } else {
      icon = 'assets/image/icon-other.png';
    }
    return Container(
      height: 95,
      margin: EdgeInsets.symmetric(vertical: 7.5, horizontal: size.width / 15),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(15),
        child: Consumer<ItemManagement>(builder: (context, itemManagement, child) {
          return InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              int dataItem = itemManagement.getItem(index);
              itemManagement.setItem(index, dataItem + 1);
              setState(() {});
              print(title + ' tambah');
            },
            child: Row(
              children: [
                const SizedBox(width: 10),
                Image.asset(icon, scale: 2),
                const SizedBox(width: 10),
                SizedBox(
                  // color: Colors.blue,
                  width: (size.width - 70) / 1.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Rp $price,00', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          itemManagement.getItem(index) != 0
                              ? GestureDetector(
                                  onTap: () {
                                    int dataItem = itemManagement.getItem(index);
                                    itemManagement.setItem(index, dataItem - 1);
                                    setState(() {});
                                    print(title + ' kurang');
                                  },
                                  child: Image.asset('assets/image/icon-min.png', scale: 1.8))
                              : const SizedBox(),
                          const SizedBox(width: 10),
                          itemManagement.getItem(index) != 0
                              ? Text(itemManagement.getItem(index).toString(), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))
                              : const SizedBox(),
                          const SizedBox(width: 10),
                          Image.asset('assets/image/icon-add.png', scale: 1.8),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
