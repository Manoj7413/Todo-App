import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> MyItems = [];

  @override
  void initState() {
    super.initState();
    LoadData();
  }

  void SaveData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('my_notes', jsonEncode(MyItems));
  }

  void LoadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? StoredData = pref.getString('my_notes');

    if (StoredData != null) {
      setState(() {
        MyItems = List<Map<String, dynamic>>.from(jsonDecode(StoredData));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hi, Write Something To Remember",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.only(left: 15),
                height: 50,
                width: screenwidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Write your note here",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_controller.text.isNotEmpty) {
                            MyItems.insert(0, {
                              "NoteText": _controller.text,
                              "isChecked": false
                            });
                          }
                          SaveData();
                          _controller.clear();
                        });
                      },
                      icon: const Icon(Icons.send, color: Colors.purple, size: 25),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: MyItems.map((item) => (item.isNotEmpty ? newContainer(item) : const SizedBox())).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget newContainer(Map<String, dynamic> item) {
    final screenwidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(top: 10),
      width: screenwidth * 0.9,
      decoration: BoxDecoration(
        color: CupertinoColors.lightBackgroundGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item['isChecked'],
            onChanged: (bool? newval) {
              setState(() {
                item['isChecked'] = newval ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            side: const BorderSide(color: Colors.blue, width: 2),
            checkColor: Colors.white,
            activeColor: Colors.blue,
          ),
          Expanded(
            child: Text(
              item['NoteText'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              maxLines: null,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                MyItems.remove(item);
                SaveData();
              });
            },
            icon: const Icon(Icons.delete_outline, color: Colors.orangeAccent),
          )
        ],
      ),
    );
  }
}
