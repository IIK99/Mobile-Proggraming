import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  double? _result;

  void _calculate(String operation) {
    double? num1 = double.tryParse(_num1Controller.text);
    double? num2 = double.tryParse(_num2Controller.text);

    if (num1 != null && num2 != null) {
      setState(() {
        switch (operation) {
          case '+':
            _result = num1 + num2;
            break;
          case '-':
            _result = num1 - num2;
            break;
          case '*':
            _result = num1 * num2;
            break;
          case '/':
            _result = num2 != 0 ? num1 / num2 : double.nan;
            break;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Simple Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _num1Controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number 1',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _num2Controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number 2',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _calculate('+'),
                child: const Text('+'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('-'),
                child: const Text('-'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('*'),
                child: const Text('*'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('/'),
                child: const Text('/'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _result != null ? 'Result: $_result' : 'Result: ',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
