import 'package:flutter/material.dart';
import 'package:sn_pos/absen/absen.dart';
import 'package:sn_pos/profile/camera_screen_tambahan.dart';
import 'package:sn_pos/profile/report_tambahan.dart';
import 'package:sn_pos/styles/navigator.dart';

class ReportTambahanScreen extends StatefulWidget {
  const ReportTambahanScreen({super.key});

  @override
  State<ReportTambahanScreen> createState() => _ReportTambahanScreenState();
}

class _ReportTambahanScreenState extends State<ReportTambahanScreen> {
  DateTime begin_date = DateTime.now().subtract(const Duration(days: 7));
  DateTime end_date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FutureBuilder<dynamic>(
          future: Absen().cekAbsenHariIni(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
            if (snapshot.data == "SUDAH_ABSEN_MASUK") {
              return FloatingActionButton(
                onPressed: () => Nav.pushReplacement(context, const CameraScreenTambahan()),
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox();
          }),
      body: Column(
        children: [
          Container(
            height: (size.height) / 7,
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(size.width / 30, 0, size.width / 15, 10),
            child: Row(
              children: [
                IconButton(
                    onPressed: () => Nav.pop(context),
                    icon: const Icon(
                      Icons.navigate_before,
                      size: 25,
                    )),
                const Text('Laporan Tambahan', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
            child: GestureDetector(
              onTap: () async {
                try {
                  DateTimeRange? date = await showDateRangePicker(context: context, firstDate: DateTime.parse('20200101'), lastDate: DateTime.parse('20300101'));
                  begin_date = date!.start;
                  end_date = date.end;
                  setState(() {});
                } catch (e) {
                  print(e);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: size.width / 2 - 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(child: Text(begin_date.toString().substring(0, 10), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                  ),
                  Container(
                    height: 40,
                    width: size.width / 2 - 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(child: Text(end_date.toString().substring(0, 10), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: ReportTambahan.getData(begin_date, end_date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                List data = snapshot.data;

                if (data.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView(
                      children: [Image.asset('assets/image/no-data.png')],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(size.width / 15),
                    itemCount: data.length,
                    itemBuilder: (context, index) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 8,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        title: Text("${data[index]['name_store']}\n${data[index]['kategori']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text("${data[index]['created_at_rpt'].substring(0, 10)}\n${data[index]['descrip_rpt']}", textAlign: TextAlign.justify),
                        trailing: SizedBox(width: 50, child: Image.network(data[index]['image_url'])),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
