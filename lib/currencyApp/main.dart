import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
          secondary: Colors.indigoAccent,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
        cardColor: Colors.white,
        dividerColor: Colors.grey.shade300,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 18.0),
        ),
      ),
      home: CurrencyApp(),
    );
  }
}

class CurrencyApp extends StatefulWidget  {
  const CurrencyApp({super.key});

  @override
  State<CurrencyApp> createState() => _CurrencyAppState();
}

class _CurrencyAppState extends State<CurrencyApp> {

  final _dateController = TextEditingController();
  final _currencyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Currency App")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                labelText: 'Enter date (YYYY-MM-DD)',
                labelStyle: TextStyle(color: Colors.indigo),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _currencyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                labelText: 'Currency Code',
                labelStyle: TextStyle(color: Colors.indigo),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencyDataPage(),
                      settings: RouteSettings(
                        arguments: {
                          'date': _dateController.text,
                          'currency': _currencyController.text,
                        }
                      ),
                    ),

                );
              },
              child: const Text('Fetch Rates')
            ),
          ]
        )
      ),
    );
  }

}


class CurrencyDataPage extends StatefulWidget {
  const CurrencyDataPage({super.key});

  @override
  State<CurrencyDataPage> createState() => _CurrencyDataPageState();
}

class _CurrencyDataPageState extends State<CurrencyDataPage> {

  bool isLoading = false;
  List<dynamic> currencyData = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      fetchCurrencyData(args['date']!, args['currency']!);
      _isInitialized = true;
    }
  }

  Future<void> fetchCurrencyData(String date, String? currency) async {

    if (currency == '' || currency == null || currency.isEmpty) {
      currency = 'all';
    }

    var url = Uri.parse('https://cbu.uz/ru/arkhiv-kursov-valyut/json/$currency/$date/');

    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          print('Data received: $jsonResponse');
        }
        setState(() {
          isLoading = false;
          currencyData = jsonResponse;
        });
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}.');
        }
        setState(() {
          isLoading = false;
          currencyData = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during HTTP request: $e');
      }
      setState(() {
        isLoading = false;
        currencyData = [];
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Currency Data")),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : ListView.builder(
        itemCount: currencyData.length,
        itemBuilder: (context, index) {
          final currency = currencyData[index];
          return CurrencyCard(
            name: currency['CcyNm_EN'],
            currency: currency['Ccy'],
            rate: currency['Rate'],
            change: currency['Diff'],
            date: currency['Date'],
          );
        },
      ),
    );
  }
}

class CurrencyCard extends StatelessWidget {
  final String name;
  final String currency;
  final String rate;
  final String change;
  final String date;

  const CurrencyCard({
    super.key,
    required this.name,
    required this.currency,
    required this.rate,
    required this.change,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name ($currency)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate: $rate, Change: $change, Date: $date',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
