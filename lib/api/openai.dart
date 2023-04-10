import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class OpenAi {
  Future<Map<String, String>> chatCompletion(prompt) async {
    // construct the prompt:
    prompt = '''
Return to me a Bible verse that includes the topic hard work: 
1
Colossians 3:23-24
Whatever you do, do it from the heart for the Lord and not for people.
You know that you will receive an inheritance as a reward. You serve the Lord Christ
Return to me a Bible verse that includes the topic $prompt. 
''';

    const url = 'https://api.openai.com/v1/completions';
    String apiKey = '';
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": prompt,
          "max_tokens": 256,
          "temperature": 0.7,
        }));

    if (response.statusCode == 200) {
      log("status code 200");
      Map<String, dynamic> data = jsonDecode(response.body);
      log("status code: 200 \n ouptput is: ${data}");
      return {
        'status': '200',
        'text': data['choices'][0]['text'],
      };
    } else {
      log('Error: ${response.statusCode}');
      return {
        'status': response.statusCode.toString(),
        'text': "Ops something went wrong status: ${response.statusCode}",
      };
    }
  }
}
