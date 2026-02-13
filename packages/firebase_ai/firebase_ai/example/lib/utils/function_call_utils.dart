// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class Location {
  final String city;
  final String state;

  Location(this.city, this.state);
}

// This is a hypothetical API to return a fake weather data collection for
// certain location
Future<Map<String, Object?>> fetchWeather(
  Location location,
  String date,
) async {
  // TODO(developer): Call a real weather API.
  // Mock response from the API. In developer live code this would call the
  // external API and return what that API returns.
  final apiResponse = {
    'temperature': 38,
    'chancePrecipitation': '56%',
    'cloudConditions': 'partly-cloudy',
  };
  return apiResponse;
}

Future<Map<String, Object?>> fetchWeatherCallable(
  Map<String, Object?> args,
) async {
  final locationData = args['location']! as Map<String, Object?>;
  final city = locationData['city']! as String;
  final state = locationData['state']! as String;
  final date = args['date']! as String;
  return fetchWeather(Location(city, state), date);
}
