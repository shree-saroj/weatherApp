import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weatherData;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "Pokhara";
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey"),
      );
      final data = jsonDecode(res.body);
      if (data["cod"] != "200") {
        throw data["message"];
      } else {
        return data;
      }
    } catch (e) {
      throw "Unable to connect to the weather server";
    }
  }

  @override
  void initState() {
    super.initState();
    weatherData = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weatherData = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          } else {
            final data = snapshot.data;
            final currTemp = data?['list'][0]['main']['temp'];
            final currSky = data?['list'][0]['weather'][0]['main'];
            final IconData icon = (currSky == "Clouds")
                ? WeatherIcons.day_cloudy
                : (currSky == "Rain")
                    ? WeatherIcons.rain
                    : Icons.wb_sunny_rounded;
            final currPressure = data?['list'][0]['main']['pressure'];
            final currHumidity = data?['list'][0]['main']['humidity'];
            final currWindSpeed = data?['list'][0]['wind']['speed'];
            return Padding(
              padding: const EdgeInsets.all(
                16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              16.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "$currTemp K",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Icon(
                                  icon,
                                  size: 64,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  currSky,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Hourly Forecast",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data?["list"].length,
                      itemBuilder: (context, index) {
                        return HourlyForeCastItem(
                          icon: data?['list'][index]['weather'][0]['main'] ==
                                  "Clouds"
                              ? WeatherIcons.day_cloudy
                              : (data?['list'][index]['weather'][0]['main'] ==
                                      "Rain")
                                  ? WeatherIcons.rain
                                  : Icons.wb_sunny_rounded,
                          time: DateFormat.jm().format(
                            (DateTime.parse(data?['list'][index]["dt_txt"])),
                          ),
                          temperature:
                              "${data?['list'][index]["main"]["temp"]} K",
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Additional Information",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoItem(
                        icon: WeatherIcons.humidity,
                        label: "Humidity",
                        value: "$currHumidity",
                      ),
                      AdditionalInfoItem(
                        icon: WeatherIcons.strong_wind,
                        label: "Wind Speed",
                        value: "$currWindSpeed",
                      ),
                      AdditionalInfoItem(
                        icon: WeatherIcons.small_craft_advisory,
                        label: "Pressure",
                        value: "$currPressure",
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
