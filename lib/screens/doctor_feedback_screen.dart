import 'package:flutter/material.dart';

class DoctorFeedbackScreen extends StatefulWidget {
  const DoctorFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<DoctorFeedbackScreen> createState() => _DoctorFeedbackScreenState();
}

class _DoctorFeedbackScreenState extends State<DoctorFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  int npsScore = 0;
  final Map<String, String> answers = {};

  Widget _buildQuestion(String question, {bool multiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: multiline ? 3 : 1,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Your answer here...",
          ),
          onChanged: (value) => answers[question] = value,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Feedback"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NPS SCORE QUESTION
                const Text(
                  "How likely are you to recommend our clinic/hospital to a friend or family member? (0-10)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: List.generate(11, (index) {
                    return ChoiceChip(
                      label: Text(index.toString()),
                      selected: npsScore == index,
                      onSelected: (_) => setState(() => npsScore = index),
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(
                        color: npsScore == index ? Colors.white : Colors.black,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                _buildQuestion("What is the primary reason for your score?", multiline: true),
                _buildQuestion("What specific issues led to your rating and how can we address them?", multiline: true),
                _buildQuestion("What could we have done to improve your experience?", multiline: true),


                const SizedBox(height: 16),

                _buildQuestion("Did the healthcare provider listen carefully to all of your concerns?"),
                _buildQuestion("How well did we address your questions or concerns during your visit?", multiline: true),
                _buildQuestion("How would you rate the amount of time your provider spent with you?"),


                const SizedBox(height: 16),

                _buildQuestion("How satisfied were you with the doctor's treatment and care?"),
                _buildQuestion("Were you given clear, easy-to-understand instructions for your follow-up care?"),


                const SizedBox(height: 16),

                _buildQuestion("How easy was it to book your appointment?"),
                _buildQuestion("How would you rate the wait time before seeing the doctor?"),
                _buildQuestion("How easy was it to find your way around our facility?"),

                const SizedBox(height: 32),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Feedback submitted successfully!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Submit Feedback",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}