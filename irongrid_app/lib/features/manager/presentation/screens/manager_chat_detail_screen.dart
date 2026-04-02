import 'package:flutter/material.dart';
import '../../../../core/config/api_config.dart';
import '../../data/models/manager_conversation_model.dart';
import '../../data/services/manager_message_repository.dart';
import '../widgets/manager_badge_store.dart';

class ManagerChatDetailScreen extends StatefulWidget {
  const ManagerChatDetailScreen({super.key});

  @override
  State<ManagerChatDetailScreen> createState() =>
      _ManagerChatDetailScreenState();
}

class _ManagerChatDetailScreenState extends State<ManagerChatDetailScreen> {
  final ManagerMessageRepository _repo = ManagerMessageRepository();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ManagerConversationModel? _conversation;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _initialized = false;

  late int _conversationId;
  late String _contactName;
  late String _contactRole;
  String? _contactAvatarUrl;

  String? _myAvatarUrl;
  String? _myName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    _conversationId = args['conversationId'] as int;
    _contactName = (args['contactName'] ?? '').toString();
    _contactRole = (args['contactRole'] ?? '').toString();
    _contactAvatarUrl = _cleanAvatarValue(args['contactAvatarUrl']);
    _myAvatarUrl = _cleanAvatarValue(args['myAvatarUrl']);
    _myName = (args['myName'] ?? '').toString().trim();

    _loadConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repo.getConversation(_conversationId);
      if (!mounted) return;

      setState(() {
        _conversation = data;
        _loading = false;
      });

      ManagerBadgeStore.setUnreadMessages(0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(jump: true);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    try {
      setState(() => _sending = true);

      await _repo.sendMessage(
        conversationId: _conversationId,
        content: text,
      );

      _controller.clear();
      await _loadConversation();

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.maxScrollExtent;
    if (jump) {
      _scrollController.jumpTo(position);
    } else {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _showMessageActions(dynamic msg) {
    if (!msg.mine || msg.deleted == true) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Supprimer le message',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Cette action est définitive'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _confirmDeleteMessage(msg.id);
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteMessage(int messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Supprimer le message'),
        content: const Text(
          'Voulez-vous vraiment supprimer ce message ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteMessage(messageId);
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    try {
      await _repo.deleteMessage(
        conversationId: _conversationId,
        messageId: messageId,
      );

      await _loadConversation();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message supprimé')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatTime(String value) {
    if (value.trim().isEmpty) return '';
    final parts = value.split('T');
    if (parts.length == 2 && parts[1].length >= 5) {
      return parts[1].substring(0, 5);
    }
    if (value.contains(' ') && value.length >= 16) {
      return value.substring(value.length - 5);
    }
    return value;
  }

  String? _cleanAvatarValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  String? _tryGetMyAvatarUrl() {
    final value = _cleanAvatarValue(_myAvatarUrl);
    if (value == null) return null;
    return _normalizeImageUrl(value);
  }

  String? _tryGetContactAvatarUrl() {
    final value = _cleanAvatarValue(_contactAvatarUrl);
    if (value == null) return null;
    return _normalizeImageUrl(value);
  }

  String? _tryGetConversationAvatarUrl() {
    final c = _conversation;
    if (c == null) return null;

    try {
      final dynamic dc = c;

      final direct = _cleanAvatarValue(dc.avatarUrl);
      if (direct != null) return _normalizeImageUrl(direct);

      final avatar = _cleanAvatarValue(dc.profilePicture);
      if (avatar != null) return _normalizeImageUrl(avatar);

      final photo = _cleanAvatarValue(dc.photoUrl);
      if (photo != null) return _normalizeImageUrl(photo);

      return null;
    } catch (_) {
      return null;
    }
  }

  String? _tryGetMessageAvatarUrl(dynamic msg) {
    if (msg == null) return null;

    try {
      final direct = _cleanAvatarValue(msg.senderAvatarUrl);
      if (direct != null) return _normalizeImageUrl(direct);

      final fallback1 = _cleanAvatarValue(msg.avatarUrl);
      if (fallback1 != null) return _normalizeImageUrl(fallback1);

      final fallback2 = _cleanAvatarValue(msg.profilePicture);
      if (fallback2 != null) return _normalizeImageUrl(fallback2);

      final fallback3 = _cleanAvatarValue(msg.photoUrl);
      if (fallback3 != null) return _normalizeImageUrl(fallback3);

      try {
        final sender = msg.sender;

        final nested1 = _cleanAvatarValue(sender.avatarUrl);
        if (nested1 != null) return _normalizeImageUrl(nested1);

        final nested2 = _cleanAvatarValue(sender.profilePicture);
        if (nested2 != null) return _normalizeImageUrl(nested2);

        final nested3 = _cleanAvatarValue(sender.photoUrl);
        if (nested3 != null) return _normalizeImageUrl(nested3);
      } catch (_) {}

      return null;
    } catch (_) {
      return null;
    }
  }

  String _normalizeImageUrl(String url) {
    return ApiConfig.resolveUrl(url);
  }

  Widget _avatar({
    required String name,
    String? avatarUrl,
    double radius = 20,
    Color backgroundColor = const Color(0xFFE8ECF8),
    Color textColor = Colors.white,
  }) {
    final imageUrl =
        (avatarUrl != null && avatarUrl.trim().isNotEmpty) ? avatarUrl : null;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      _initials(name),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  _initials(name),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, String? conversationAvatarUrl,
      String? myAvatarUrl) {
    final isMine = msg.mine;
    final isDeleted = msg.deleted == true;

    final senderAvatarUrl = isMine
        ? (_tryGetMessageAvatarUrl(msg) ?? myAvatarUrl)
        : (_tryGetMessageAvatarUrl(msg) ?? conversationAvatarUrl);

    final displaySenderName =
        (_myName != null && _myName!.isNotEmpty && isMine) ? _myName! : msg.senderName;
    final messageText = isDeleted
        ? (isMine
            ? 'Vous avez supprim\u00e9 un message'
            : 'Ce message a \u00e9t\u00e9 supprim\u00e9')
        : msg.content;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            _avatar(
              name: msg.senderName,
              avatarUrl: senderAvatarUrl,
              radius: 18,
              backgroundColor: Colors.indigo.shade100,
              textColor: Colors.indigo,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress:
                  isMine && !isDeleted ? () => _showMessageActions(msg) : null,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.76,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isMine && !isDeleted
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF4F5BD5),
                            Color(0xFF6574F7),
                          ],
                        )
                      : null,
                  color:
                      isDeleted ? Colors.white : (isMine ? null : Colors.white),
                  border: isDeleted
                      ? Border.all(color: const Color(0xFFE3E6EF))
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMine ? 20 : 6),
                    bottomRight: Radius.circular(isMine ? 6 : 20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMine && !isDeleted)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          msg.senderName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                    Text(
                      messageText,
                      style: TextStyle(
                        color: isDeleted
                            ? Colors.blueGrey.shade400
                            : (isMine ? Colors.white : Colors.black87),
                        fontSize: 15,
                        height: 1.35,
                        fontStyle:
                            isDeleted ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(msg.sentAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDeleted
                                ? Colors.blueGrey.shade300
                                : (isMine
                                    ? Colors.white70
                                    : Colors.grey.shade500),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isMine && !isDeleted) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.done_all_rounded,
                            size: 14,
                            color: Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 8),
            _avatar(
              name: displaySenderName,
              avatarUrl: senderAvatarUrl,
              radius: 18,
              backgroundColor: Colors.indigo.shade100,
              textColor: Colors.indigo,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = _conversation?.messages ?? [];
    final lastMessage = messages.isNotEmpty ? messages.last : null;

    final conversationAvatarUrl = _tryGetContactAvatarUrl() ??
        _tryGetConversationAvatarUrl() ??
        _tryGetMessageAvatarUrl(lastMessage);

    final myAvatarUrl = _tryGetMyAvatarUrl();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            _avatar(
              name: _contactName,
              avatarUrl: conversationAvatarUrl,
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              textColor: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _contactName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _contactRole,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildMessageBubble(
                            msg,
                            conversationAvatarUrl,
                            myAvatarUrl,
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F8),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: TextField(
                                  controller: _controller,
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _send(),
                                  decoration: const InputDecoration(
                                    hintText: 'Écrire un message...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4F5BD5),
                                    Color(0xFF6574F7),
                                  ],
                                ),
                              ),
                              child: IconButton(
                                onPressed: _sending ? null : _send,
                                icon: _sending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
