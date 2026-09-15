import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

abstract class HomeApi {
  static void details() async {
    Uri url = Uri.https("api.themoviedb.org", "/3/movie/popular");

    var response = await http.get(
      url,
      headers: {
        "Authorization":
            "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzYzZhMjg0ZTE1NGRmNDMyYjc1MzljNTI5ZDE3MWIwMyIsIm5iZiI6MTc4ODM4ODUwOC44NCwic3ViIjoiNmE5OGE0OWM2N2E2N2IzODJjNWU1YzIyIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.wfkacaJVPQldkszRyrfm-mXvcS8SM9KNPy2r_40bJ34",
      },
    );

    log("Status Code: ${response.statusCode}");

    var responseString = response.body;

    var json = jsonDecode(responseString);

    log("First Movie: ${json['results'][0]['title']}");
  }
}
