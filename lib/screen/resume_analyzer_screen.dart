import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ResumeAnalyzerScreen extends StatefulWidget {
  const ResumeAnalyzerScreen({super.key});

  @override
  _ResumeAnalyzerScreenState createState() =>
      _ResumeAnalyzerScreenState();
}

class _ResumeAnalyzerScreenState
    extends State<ResumeAnalyzerScreen> {

  final controller = TextEditingController();
  String result = "";
  bool loading = false;

  void analyze() async {
    setState(() {
      loading = true;
    });

    String res =
        await AIService().analyzeResume(controller.text);

    setState(() {
      result = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Resume Analyzer")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Paste your resume here...",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: analyze,
              child: Text("Analyze"),
            ),

            SizedBox(height: 20),

            if (loading) CircularProgressIndicator(),

            if (!loading)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}