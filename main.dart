import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // ==========================================
  // ⚙️ ส่วนตั้งค่าตัวละครและ API ของคุณ
  // ==========================================
  final String characterName = "คุณหนูอลิซ"; 
  final String systemPrompt = "คุณคือ อลิซ เด็กสาวปากแข็งแต่ใจดี ชอบเรียกผู้ใช้ว่า 'นายทึ่ม' พูดลงท้ายด้วย 'ย่ะ/เชอะ' จงตอบเป็นภาษาไทยเสมอ";
  final String apiKey = "ใส่_OPENROUTER_API_KEY_ที่นี่"; 
  // ==========================================

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "deepseek/deepseek-chat:free", // ใช้โมเดลฟรี
          "messages": [
            {"role": "system", "content": systemPrompt},
            ..._messages,
          ],
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final botReply = data['choices'][0]['message']['content'];

      setState(() {
        _messages.add({"role": "assistant", "content": botReply});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "เกิดข้อผิดพลาดในการเชื่อมต่อ"});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(characterName), backgroundColor: Colors.pinkAccent),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final isUser = _messages[i]['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.pinkAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _messages[i]['content']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "พิมพ์ข้อความที่นี่...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pinkAccent),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
