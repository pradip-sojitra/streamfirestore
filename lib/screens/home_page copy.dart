import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';


class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: const Color(0xff4e416c),
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
                        ],
                      ),
                      child: Align(
                        alignment: pradipId != null
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Padding(
                          padding: pradipId != null
                              ? const EdgeInsets.only(left: 50)
                              : const EdgeInsets.only(right: 50),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: pradipId != null
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(16.0),
                                          bottomRight: Radius.circular(16.0),
                                          topLeft: Radius.circular(16.0))
                                      : const BorderRadius.only(
                                          bottomLeft: Radius.circular(16.0),
                                          bottomRight: Radius.circular(16.0),
                                          topRight: Radius.circular(16.0)),
                                  color: pradipId != null
                                      ? const Color(0xff4e416c)
                                      : const Color(0xffF6F7FB),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 22),
                                  child: Text(
                                    storeData[index]['text'],
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        letterSpacing: 0.2,
                                        color: pradipId != null
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 6, right: 6),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 3,
                          controller: _chat,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            contentPadding: const EdgeInsets.only(
                                right: 15, left: 25, bottom: 15, top: 15),
                            filled: true,
                            fillColor: const Color(0xffF6F7FB),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () async {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );

                          if (_chat.text == "") {
                            print("isEmpty");
                          } else {
                            final id = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
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
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: const Color(0xff4e416c),
                          radius: 27,
                          child: Container(
                            padding: const EdgeInsets.only(left: 5),
                            child: const Icon(Icons.send_rounded,
                                size: 28, color: Colors.white),
                          ),
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
