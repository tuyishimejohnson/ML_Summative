import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle CO2 Emission Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown values
  String? _selectedVehicleClass;
  String? _selectedTransmission;
  String? _selectedFuelType;

  // Text field controllers
  final TextEditingController _engineSizeController = TextEditingController();
  final TextEditingController _cylindersController = TextEditingController();
  final TextEditingController _fuelConsumptionCityController = TextEditingController();
  final TextEditingController _fuelConsumptionHwyController = TextEditingController();
  final TextEditingController _fuelConsumptionCombController = TextEditingController();
  final TextEditingController _fuelConsumptionCombMpgController = TextEditingController();

  String _prediction = '';

  // Dropdown items
  final List<String> _vehicleClasses = [
    'COMPACT', 'MID-SIZE', 'MINICOMPACT', 'SUBCOMPACT', 'SUV - SMALL', 'TWO-SEATER'
  ];

  final List<String> _transmissions = [
    'A6', 'AS5', 'AS6', 'AV7', 'M6', 'AM7'
  ];

  final List<String> _fuelTypes = [
    'Z'
  ];

  Future<void> _predict() async {
    if (_selectedVehicleClass == null || _selectedTransmission == null || _selectedFuelType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select all dropdown options')));
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'VEHICLECLASS': _selectedVehicleClass!,
        'ENGINESIZE': double.parse(_engineSizeController.text),
        'CYLINDERS': int.parse(_cylindersController.text),
        'TRANSMISSION': _selectedTransmission!,
        'FUELTYPE': _selectedFuelType!,
        'FUELCONSUMPTION_CITY': double.parse(_fuelConsumptionCityController.text),
        'FUELCONSUMPTION_HWY': double.parse(_fuelConsumptionHwyController.text),
        'FUELCONSUMPTION_COMB': double.parse(_fuelConsumptionCombController.text),
        'FUELCONSUMPTION_COMB_MPG': double.parse(_fuelConsumptionCombMpgController.text),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _prediction = jsonDecode(response.body)['prediction'].toString();
      });
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle CO2 Emission Prediction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedVehicleClass,
                hint: Text('Select Vehicle Class'),
                items: _vehicleClasses.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVehicleClass = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select vehicle class' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _engineSizeController,
                decoration: InputDecoration(labelText: 'Engine Size'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter engine size';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cylindersController,
                decoration: InputDecoration(labelText: 'Cylinders'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter number of cylinders';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedTransmission,
                hint: Text('Select Transmission'),
                items: _transmissions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTransmission = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select transmission' : null,
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                hint: Text('Select Fuel Type'),
                items: _fuelTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFuelType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select fuel type' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _fuelConsumptionCityController,
                decoration: InputDecoration(labelText: 'Fuel Consumption City'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter fuel consumption city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fuelConsumptionHwyController,
                decoration: InputDecoration(labelText: 'Fuel Consumption Highway'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter fuel consumption highway';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fuelConsumptionCombController,
                decoration: InputDecoration(labelText: 'Fuel Consumption Combined'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter fuel consumption combined';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fuelConsumptionCombMpgController,
                decoration: InputDecoration(labelText: 'Fuel Consumption Combined MPG'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter fuel consumption combined MPG';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _predict();
                    }
                  },
                  child: Text('Predict'),
                ),
              ),
              Text(
                _prediction.isEmpty ? 'Enter data to predict CO2 emission' : 'Predicted CO2 Emission: $_prediction',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
