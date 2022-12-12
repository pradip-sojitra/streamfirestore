import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time/date_time.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _chat = TextEditingController();

  Stream<QuerySnapshot>? studentStream =
      FirebaseFirestore.instance.collection("chat").snapshots();

  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade200,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color.fromARGB(254, 30, 150, 138),
      ),
      body: StreamBuilder<QuerySnapshot?>(
        stream: studentStream,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          if (snapshot.hasError) {
            print('stream error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List storeData = [];
          snapshot.data!.docs.map((DocumentSnapshot document) {
            Map a = document.data() as Map<String, dynamic>;
            storeData.add(a);
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final pradipId = storeData[index]['pradipId'];
                    final harshId = storeData[index]['harshId'];
                    final ruchitId = storeData[index]['ruchitId'];
                    return Slidable(
                      endActionPane: ActionPane(
                        extentRatio: 0.20,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              pradipId != null
                                  ? await FirebaseFirestore.instance
                                      .collection('chat')
                                      .doc(pradipId)
                                      .delete()
                                  : harshId != null
                                      ? await FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(harshId)
                                          .delete()
                                      : ruchitId != null
                                          ? await FirebaseFirestore.instance
                                              .collection('chat')
                                              .doc(ruchitId)
                                              .delete()
                                          : Container();
                            },
                            borderRadius: BorderRadius.circular(10),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      child: Align(
                        alignment: storeData[index]['pradipId'] != null
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          elevation: 1.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          color: pradipId != null
                              ? Colors.green.shade100
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ruchitId != null
                                      ? 'Ruchit'
                                      : harshId != null
                                          ? 'Harsh'
                                          : 'Pradip',
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: ruchitId != null
                                          ? Colors.red
                                          : harshId != null
                                              ? Colors.green
                                              : Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  storeData[index]['text'],
                                  style: const TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2),
                                ),
                                Text(
                                  (storeData[index]["pradipId"] != null)
                                      ? storeData[index]["time"].toString()
                                      : storeData[index]["time"].toString(),
                                  style: const TextStyle(
                                      fontSize: 9.0,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 100,
                          controller: _chat,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            contentPadding: const EdgeInsets.only(
                                left: 25, bottom: 15, top: 15),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () async {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          final id =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          final time = DateFormat('hh:mm a')
                              .format(DateTime.now())
                              .toString();

                          await FirebaseFirestore.instance
                              .collection('chat')
                              .doc(id)
                              .set({
                            "text": _chat.text,
                            "pradipId": id,
                            "time": time
                          });
                          _chat.clear();
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 27,
                          child: Icon(Icons.send_rounded,
                              size: 30, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
