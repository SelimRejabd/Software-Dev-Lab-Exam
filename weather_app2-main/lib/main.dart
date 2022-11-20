import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:time/time.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Weather App",
      home: Home(),
    ));

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? selected_value;
  var temp,
      city,
      description,
      humidity,
      pressure,
      lon,
      lat,
      apikey,
      currTemp,
      local,
      sunrise,
      sunset,
      date,
      feels_like;
  TextEditingController textEditingController = TextEditingController();
  var cityList = ['London', 'Rajshahi', 'Dhaka'];
  void Location() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lon = position.longitude.toStringAsFixed(4);
      lat = position.latitude.toStringAsFixed(4);
    });
  }

  void locationWeather() async {
    apikey = '56c6ebf76fffc33698398004b9dbf5cb';
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=56c6ebf76fffc33698398004b9dbf5cb';
    http.Response res = await http.get(Uri.parse(url));
    var result = await jsonDecode(res.body);
    setState(() {
      this.temp = result['main']['temp'];
      this.description = result['weather'][0]['description'];
      this.humidity = result['main']['humidity'];
      this.pressure = result['main']['pressure'];
      this.feels_like = result['main']['feels_like'];
      sunrise = result['sys']['sunrise'];
      sunset = result["sys"]["sunset"];
      city = result["name"];
    });
  }

  void weatherapi() async {
    String apikey = '56c6ebf76fffc33698398004b9dbf5cb';
    String url =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apikey';
    var res = await http.get(Uri.parse(url));
    var result = jsonDecode(res.body);

    setState(() {
      lon = result['coord']['lon'];
      lat = result['coord']['lat'];
      this.temp = result['main']['temp'];
      this.description = result['weather'][0]['description'];
      this.humidity = result['main']['humidity'];
      this.pressure = result['main']['pressure'];
      this.feels_like = result['main']['feels_like'];
      sunrise = result['sys']['sunrise'];
      sunset = result['sys']['sunset'];
    });
    // print(pressure);
  }

  // void changeCity() {
  //   setState(() {
  //     city = textEditingController.text;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    weatherapi();
    //changeCity();
    locationWeather();
    Location();
  }

  @override
  Widget build(BuildContext context) {
    var dt = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 20,
                  child: DropdownButton2(
                    items: cityList
                        .map((e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ))
                        .toList(),
                    value: selected_value,
                    onChanged: (val) {
                      setState(() {
                        selected_value = val as String;
                        city = selected_value.toString();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                ),
                MaterialButton(
                    child: Text("Location"),
                    color: Colors.red,
                    textColor: Colors.black,
                    onPressed: () {
                      locationWeather();
                      Location();
                    }),
              ],
            )),
            Text(
              "Latitude :" + lat.toString(),
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Longitude :" + lon.toString(),
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              city.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            MaterialButton(
              textColor: Colors.white,
              child: Text('submit'),
              color: Colors.blue,
              onPressed: () {
                // changeCity();
                weatherapi();
              },
            ),
            //Image.network("http://openweathermap.org/img/wn/$description@2x.png"),
            Text(dt.toString(),
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                )),
            Text(temp != null ? temp.toString() + "\u00B0C" : "loading",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w600,
                )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.sun),
                      title: Text("আদ্রতা"),
                      trailing: Text(
                          humidity != null ? humidity.toString() : "Loading"),
                    ),
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.wind),
                      title: Text("চাপ"),
                      trailing: Text(
                          pressure != null ? pressure.toString() : "Loading"),
                    ),
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.sun),
                      title: Text("তাপমাত্রা"),
                      trailing: Text(feels_like != null
                          ? feels_like.toString()
                          : "Loading"),
                    ),
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.solidSun),
                      title: Text("সূর্যোদয়"),
                      trailing:
                          Text(sunset != null ? formatted(sunset) : "loading"),
                    ),
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.solidSun),
                      title: Text("সূর্যাস্ত"),
                      trailing: Text(
                          sunrise != null ? formatted(sunrise) : "loading"),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

String formatted(timeStamp) {
  final DateTime date1 = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  return DateFormat('hh:mm a').format(date1);
}
