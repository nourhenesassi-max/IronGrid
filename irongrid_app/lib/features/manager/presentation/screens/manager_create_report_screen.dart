import 'package:flutter/material.dart';

class ManagerCreateReportScreen extends StatefulWidget {
  const ManagerCreateReportScreen({super.key});

  @override
  State<ManagerCreateReportScreen> createState() =>
      _ManagerCreateReportScreenState();
}

class _ManagerCreateReportScreenState extends State<ManagerCreateReportScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Report"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Report Title",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Report created")),
                );
              },
              child: const Text("Submit Report"),
            )
          ],
        ),
      ),
    );
  }
}