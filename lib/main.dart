//Importing necessary libraries
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

List<String> categories = ["All-purpose", "Personal", "Work", "Social"];
String currentCategory = categories[0];

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> tasks = [];
  List<Map<String, String>> filteredTasks = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  //Function to load tasks from persistent storage, if any
  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskStringList = prefs.getStringList('tasks');
    if (taskStringList != null) {
      setState(() {
        tasks = taskStringList.map((task) => Map<String, String>.from(jsonDecode(prefs.getString('task_$task')!))).toList();
        filterTasks();
      });
    }
  }

  //Function to save tasks to persistent storage
  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(tasks.isNotEmpty){
      List<String> taskStringList = tasks.map((task) => task['title']!).toList();
      prefs.setStringList('tasks', taskStringList);
      for (var task in tasks) {
        prefs.setString('task_${task['title']}', jsonEncode(task));
      }
    } 
  }

  //Function to add tasks to list and enable UI rendering
  void addTask() {
    TextEditingController nameController = TextEditingController();
    TextEditingController deadlineController = TextEditingController();
    String priority = 'Low';

    showDialog(
      barrierColor: Colors.pinkAccent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(      //Lets user enter necessary details
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Enter task title'),
                  ),
                  TextField(
                    controller: deadlineController,
                    decoration: const InputDecoration(hintText: 'Enter deadline date/time'),
                  ),
                  DropdownButton<String>(
                    borderRadius: const BorderRadius.all(Radius.elliptical(4, 2)),
                    iconDisabledColor: Colors.lightGreen,
                    iconEnabledColor: Colors.lightGreen,
                    value: priority,
                    items: ['Low', 'Medium', 'High'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );}).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        priority = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      tasks.add({
                        "title": nameController.text,
                        "category": currentCategory,
                        "priority": priority,
                        "dueDate": deadlineController.text,
                      });
                      saveTasks();
                      filterTasks();
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task added successfully!"),
                        duration: Duration(seconds: 2),
                      ));
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //Function to let user edit info of existing tasks
  void editTask(int index) {
    TextEditingController titleController = TextEditingController(text: filteredTasks[index]['title']);
    TextEditingController dueDateController = TextEditingController(text: filteredTasks[index]['dueDate']);
    String priority = filteredTasks[index]['priority'] ?? 'Low';

    showDialog(
      barrierColor: Colors.pinkAccent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(      //Similar to the add task dialog
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Enter task title'),
                  ),
                  TextField(
                    controller: dueDateController,
                    decoration: const InputDecoration(hintText: 'Enter deadline data/time'),
                  ),
                  DropdownButton<String>(
                    borderRadius: const BorderRadius.all(Radius.elliptical(4, 2)),
                    iconEnabledColor: Colors.lightGreen,
                    iconDisabledColor: Colors.lightGreen,
                    value: priority,
                    items: ['Low', 'Medium', 'High'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        priority = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      filteredTasks[index]['title'] = titleController.text;
                      filteredTasks[index]['dueDate'] = dueDateController.text;
                      filteredTasks[index]['priority'] = priority;
                      tasks = filteredTasks;
                      saveTasks();
                      filterTasks();
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task edited successfully!"),
                        duration: Duration(seconds: 2),
                      ));
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                )
              ],
            );
          },
        );
      },
    );
  }

  //Function to let the user remove tasks from list and UI
  void endTask(int index) {
    setState(() {
      filteredTasks.removeAt(index);
      tasks = filteredTasks;
      saveTasks(); // Save tasks after removing
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Task removed successfully!"),
        duration: Duration(seconds: 2),
      ),
    );
  }


  //Function to fetch search results
  void filterTasks() {
    setState(() {
      filteredTasks = currentCategory == "All-purpose"
          ? tasks.where((task) => task['title']!.toLowerCase().contains(searchQuery.toLowerCase())).toList()
          : tasks.where((task) => (task['category'] == currentCategory || task['category'] == "All-purpose") && task['title']!.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   //Appbar has buttons to add tasks
        title: const Text("List of pending tasks..."),
        backgroundColor: const Color.fromARGB(255, 236, 78, 67),
        actions: [
          IconButton(onPressed: addTask, icon: const Icon(Icons.add)),
        ],
        bottom: PreferredSize(    //Adding a search bar to the bottom of the appbar
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search tasks',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  filterTasks();
                });
              },
            ),
          ),
        ),
      ),
      backgroundColor: Colors.cyanAccent,
      body: Column(
        children: [
          DropdownButton<String>(     //Letting user switch between task categories
            dropdownColor: Colors.lightGreen,
            borderRadius: const BorderRadius.all(Radius.elliptical(4, 2)),
            items: categories.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );}).toList(),
            onChanged: (String? newValue) {
              setState(() {
                currentCategory = newValue!;
                filterTasks();
              });
            },
            value: currentCategory),
          Expanded(       //Rendering of task lists
            child: ListView.builder(
              padding: const EdgeInsets.all(5),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.lightGreen,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filteredTasks[index]['title']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          )),
                        Text("Due: ${filteredTasks[index]['dueDate']!}"),
                        Text("Priority: ${filteredTasks[index]['priority']!}"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [     //Each task tile has buttons to edit it or remove it
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                editTask(index);
                              }),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                endTask(index);
                              })
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
