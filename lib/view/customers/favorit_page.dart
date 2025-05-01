import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FavoritListPage(),
    );
  }
}

class Person {
  final String name;
  final String location;
  final bool available;

  Person({required this.name, required this.location, required this.available});
}

class FavoritListPage extends StatefulWidget {
  const FavoritListPage({Key? key}) : super(key: key);

  @override
  _FavoritListPageState createState() => _FavoritListPageState();
}

class _FavoritListPageState extends State<FavoritListPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Person> _allPersons = [
    Person(name: 'محمد', location: 'القاهرة', available: true),
    Person(name: 'أحمد', location: 'الرياض', available: false),
    Person(name: 'خالد', location: 'عمّان', available: true),
    Person(name: 'سلمى', location: 'نابلس', available: false),
    // أضف المزيد من البيانات الوهمية حسب الحاجة
  ];
  List<Person> _filteredPersons = [];

  @override
  void initState() {
    super.initState();
    _filteredPersons = List.from(_allPersons);
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPersons =
          _allPersons.where((person) {
            return person.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _removePerson(int index) {
    setState(() {
      _filteredPersons.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الأشخاص'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPersons.length,
              itemBuilder: (context, index) {
                final person = _filteredPersons[index];
                return Dismissible(
                  key: Key(person.name),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removePerson(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${person.name} تم حذفه')),
                    );
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: PersonCard(person: person),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PersonCard extends StatelessWidget {
  final Person person;

  const PersonCard({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: Icon(
          person.available ? Icons.check_circle : Icons.cancel,
          color: person.available ? Colors.green : Colors.red,
        ),
        title: Text(person.name),
        subtitle: Text(person.location),
      ),
    );
  }
}
