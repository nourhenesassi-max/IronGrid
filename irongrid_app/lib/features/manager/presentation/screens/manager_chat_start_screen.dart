import 'package:flutter/material.dart';
import '../../../employee/data/me_service.dart';
import '../../data/services/manager_message_repository.dart';

class ManagerChatStartScreen extends StatefulWidget {
  const ManagerChatStartScreen({super.key});

  @override
  State<ManagerChatStartScreen> createState() => _ManagerChatStartScreenState();
}

class _ManagerChatStartScreenState extends State<ManagerChatStartScreen> {
  final ManagerMessageRepository _repo = ManagerMessageRepository();
  final MeService _meService = MeService();

  bool _loading = true;
  String? _error;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;
    _startConversation();
  }

  int? _parseContactId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String? _cleanAvatar(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  Future<void> _startConversation() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      setState(() {
        _loading = false;
        _error = "Arguments absents";
      });
      return;
    }

    final contactId = _parseContactId(args['contactId']);
    final contactName = (args['contactName'] ?? '').toString();
    final contactRole = (args['contactRole'] ?? '').toString();
    final contactAvatarUrl = _cleanAvatar(args['contactAvatarUrl']);

    if (contactId == null) {
      setState(() {
        _loading = false;
        _error = "contactId invalide";
      });
      return;
    }

    try {
      final myProfile = await _meService.getMe();
      final conversation = await _repo.startConversation(contactId);

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/manager/chat-detail',
        arguments: {
          'conversationId': conversation.id,
          'contactName': contactName,
          'contactRole': contactRole,
          'contactAvatarUrl': contactAvatarUrl,
          'myAvatarUrl': _cleanAvatar(myProfile.avatarUrl),
          'myName': myProfile.name,
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = "Erreur: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Démarrage conversation"),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: _loading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text("Création de la conversation..."),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error ?? 'Erreur inconnue',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}