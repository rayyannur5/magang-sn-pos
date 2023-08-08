import 'package:flutter/material.dart';

class receiptWidget extends StatelessWidget {
  const receiptWidget({
    super.key,
    required this.data,
  });

  final Map data;

  @override
  Widget build(BuildContext context) {
    TextStyle bold = const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, color: Colors.black);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Image.asset('assets/image/logo.png', scale: 2),
          Image.asset('assets/image/text-print.png', scale: 2),
          Text("-- ${data['brand_store']} --", style: bold),
          Text("-- ${data['name_store']} --", style: bold),
          Text(data['tanggal'], style: bold),
          const SizedBox(height: 10),
          Row(
            children: [
              Text("Kasir     : ${data['name']}", style: bold),
            ],
          ),
          Row(
            children: [
              Text("Pelanggan : -", style: bold),
            ],
          ),
          Text('--------------------------------', style: bold),
          for (int i = 0; i < data['data'].length; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['data'][i]['name'], style: const TextStyle(fontFamily: 'SpaceMono', color: Colors.black)),
                Text(data['data'][i]['harga'], style: const TextStyle(fontFamily: 'SpaceMono', color: Colors.black)),
              ],
            ),
          Text('--------------------------------', style: bold),
          const Text('TOTAL', style: TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),
          Text(data['total'], style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),
          Text('--------------------------------', style: bold),
          Text(data['message_store'], style: bold),
          Text(data['address_store'], style: bold),
          Text(data['phone_store'], style: bold),
          const SizedBox(height: 10),
          Text(data['id_trx'], style: bold),
        ],
      ),
    );
  }
}
