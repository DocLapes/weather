import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  MyApp({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          return MaterialApp(
            title: 'Weather App',
            theme: weatherProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: WeatherScreen(),
          );
        },
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var weatherProvider = Provider.of<WeatherProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).weatherApp),
        actions: [
          IconButton(
            icon: Icon(weatherProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => weatherProvider.toggleTheme(),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              S.load(Locale(value));
              setState(() {});
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                PopupMenuItem(
                  value: 'ru',
                  child: Text('Русский'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: S.of(context).enterCity,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                weatherProvider.fetchWeather(value);
              },
            ),
            SizedBox(height: 20),
            weatherProvider.isLoading
                ? CircularProgressIndicator()
                : weatherProvider.weatherData != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${S.of(context).temperature}: ${weatherProvider.weatherData['main']['temp']}°C',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '${S.of(context).weather}: ${weatherProvider.weatherData['weather'][0]['description']}',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '${S.of(context).humidity}: ${weatherProvider.weatherData['main']['humidity']}%',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '${S.of(context).pressure}: ${weatherProvider.weatherData['main']['pressure']} hPa',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '${S.of(context).windSpeed}: ${weatherProvider.weatherData['wind']['speed']} m/s',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 20),
                          weatherProvider.forecastData != null
                              ? SizedBox(
                                  height: 200,
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    title: ChartTitle(text: S.of(context).fiveDayForecast),
                                    series: <ChartSeries>[
                                      LineSeries<dynamic, String>(
                                        dataSource: weatherProvider.forecastData['list'],
                                        xValueMapper: (dynamic data, _) => DateFormat('E').format(DateTime.parse(data['dt_txt'])),
                                        yValueMapper: (dynamic data, _) => data['main']['temp'],
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      )
                    : Text(
                        S.of(context).enterCityToGetWeather,
                        style: TextStyle(fontSize: 24),
                      ),
          ],
        ),
      ),
    );
  }
}
