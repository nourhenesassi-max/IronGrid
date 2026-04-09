import 'package:flutter/material.dart';
import '../../../../core/storage/secure_store.dart';
import '../../../employee/data/employee_message_api.dart';
import '../../data/models/employee_models.dart';
import 'employee_chat_args.dart';
import 'package:irongrid_app/core/config/api_config.dart';

class EmployeeChatDetailScreen extends StatefulWidget {
  const EmployeeChatDetailScreen({super.key});

  @override
  State<EmployeeChatDetailScreen> createState() =>
      _EmployeeChatDetailScreenState();
}

class _EmployeeChatDetailScreenState extends State<EmployeeChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final EmployeeMessageApi api;

  EmployeeConversation? _conversation;
  MessageableUser? _selectedUser;

  bool _loading = true;
  bool _sending = false;
  String? _loadedConversationId;
  String? _myName;
  bool _currentUserLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = EmployeeMessageApi(
      baseUrl: ApiConfig.baseUrl,
      tokenProvider: () async => await SecureStore.readToken(),
    );

    if (!_currentUserLoaded) {
      _currentUserLoaded = true;
      _loadCurrentUserMeta();
    }

    final args = ModalRoute.of(context)!.settings.arguments as EmployeeChatArgs;

    if (args.conversation != null) {
      if (_loadedConversationId != args.conversation!.id) {
        _loadedConversationId = args.conversation!.id;
        _selectedUser = null;
        _loadConversation(args.conversation!.id);
      }
    } else if (args.selectedUser != null) {
      _selectedUser = args.selectedUser;
      _conversation = null;
      _loading = false;
    }
  }

  Future<void> _loadCurrentUserMeta() async {
    final profileName = await SecureStore.getProfileName();
    if (!mounted) return;

    final cleanName = profileName?.trim();
    if (cleanName != null && cleanName.isNotEmpty) {
      setState(() {
        _myName = cleanName;
      });
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    setState(() {
      _loading = true;
    });

    try {
      final conversation = await api.getConversation(conversationId);
      if (!mounted) return;

      setState(() {
        _conversation = conversation;
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
    });

    try {
      final EmployeeConversation currentConversation =
          _conversation ?? await api.startConversation(_selectedUser!.id);

      final newMessage = await api.sendMessage(
        conversationId: currentConversation.id,
        content: text,
      );

      if (!mounted) return;

      setState(() {
        _conversation = currentConversation.copyWith(
          lastMessage: newMessage,
          messages: [...currentConversation.messages, newMessage],
        );
        _messageController.clear();
        _sending = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _showMessageActions(EmployeeMessage message) {
    if (!message.isMine || message.deleted) return;

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
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Le message restera dans la conversation comme supprim\u00e9',
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _confirmDeleteMessage(message);
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

  Future<void> _confirmDeleteMessage(EmployeeMessage message) async {
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
      await _deleteMessage(message);
    }
  }

  Future<void> _deleteMessage(EmployeeMessage message) async {
    final conversation = _conversation;
    if (conversation == null) return;

    try {
      await api.deleteMessage(
        conversationId: conversation.id,
        messageId: message.id,
      );

      await _loadConversation(conversation.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message supprim\u00e9')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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

  String? _cleanAvatarValue(String? value) {
    if (value == null) return null;
    final clean = value.trim();
    if (clean.isEmpty || clean.toLowerCase() == 'null') {
      return null;
    }
    return clean;
  }

  String _normalizeImageUrl(String url) {
    return ApiConfig.resolveUrl(url);
  }

  String? _resolveAvatarUrl(String? rawUrl) {
    final clean = _cleanAvatarValue(rawUrl);
    if (clean == null) return null;
    return _normalizeImageUrl(clean);
  }

  String? _contactAvatarUrl() {
    return _resolveAvatarUrl(_conversation?.avatarUrl ?? _selectedUser?.avatarUrl);
  }

  String? _myAvatarUrl() {
    final List<EmployeeMessage> messages =
        _conversation?.messages ?? const <EmployeeMessage>[];

    for (final message in messages.reversed) {
      if (!message.isMine) continue;
      final resolved = _resolveAvatarUrl(message.senderAvatarUrl);
      if (resolved != null) {
        return resolved;
      }
    }

    return null;
  }

  Widget _buildMessageAvatar(EmployeeMessage message) {
    final String displayName = message.isMine
        ? ((_myName != null && _myName!.trim().isNotEmpty)
            ? _myName!
            : message.senderName)
        : message.senderName;
    final String? avatarUrl = _resolveAvatarUrl(
      message.senderAvatarUrl ??
          (message.isMine ? _myAvatarUrl() : _contactAvatarUrl()),
    );
    final bool hasAvatar = avatarUrl != null;

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.indigo.shade100,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
      child: hasAvatar
          ? null
          : Text(
              displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  Widget _buildBubble(EmployeeMessage message) {
    final bool isMine = message.isMine;
    final bool isDeleted = message.deleted;
    final String displayText = isDeleted
        ? (isMine
            ? 'Vous avez supprim\u00e9 un message'
            : 'Ce message a \u00e9t\u00e9 supprim\u00e9')
        : message.content;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            SizedBox(
              width: 40,
              child: _buildMessageAvatar(message),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress:
                  isMine && !isDeleted ? () => _showMessageActions(message) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.76,
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
                  color: isDeleted ? Colors.white : (isMine ? null : Colors.white),
                  border: isDeleted
                      ? Border.all(color: const Color(0xFFE3E6EF))
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMine ? 20 : 6),
                    bottomRight: Radius.circular(isMine ? 6 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMine && !isDeleted) ...[
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDeleted
                            ? Colors.blueGrey.shade400
                            : (isMine ? Colors.white : Colors.black87),
                        fontStyle:
                            isDeleted ? FontStyle.italic : FontStyle.normal,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(message.sentAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDeleted
                                ? Colors.blueGrey.shade300
                                : (isMine
                                    ? Colors.white70
                                    : Colors.grey.shade600),
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
            SizedBox(
              width: 40,
              child: _buildMessageAvatar(message),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderAvatar() {
    final String? conversationAvatar = _contactAvatarUrl();
    final bool hasConversationAvatar = conversationAvatar != null;

    final String fallbackName =
        _conversation?.displayTitle ?? _selectedUser?.fullName ?? 'C';
    final String fallbackLetter =
        fallbackName.isNotEmpty ? fallbackName[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white.withValues(alpha: 0.16),
      backgroundImage:
          hasConversationAvatar ? NetworkImage(conversationAvatar) : null,
      child: hasConversationAvatar
          ? null
          : Text(
              fallbackLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  Widget _buildEmptyState(String displayName) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 72,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Commencez la conversation avec $displayName',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessages() {
    final List<EmployeeMessage> messages =
        _conversation?.messages ?? const <EmployeeMessage>[];

    return RefreshIndicator(
      onRefresh: () async {
        if (_conversation != null) {
          await _loadConversation(_conversation!.id);
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildBubble(message);
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFF4F6FB);
    const Color appBarBg = Colors.indigo;

    final String displayName = _conversation?.displayTitle ??
        _selectedUser?.fullName ??
        'Conversation';

    final String subtitle = _conversation != null
        ? _conversation!.displaySubtitle
        : _selectedUser?.role ?? '';

    final bool hasMessages =
        _conversation != null && _conversation!.messages.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            _buildHeaderAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
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
          : Column(
              children: [
                Expanded(
                  child: hasMessages
                      ? _buildMessages()
                      : _buildEmptyState(displayName),
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
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: TextField(
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Écrire un message...',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: InputBorder.none,
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
                            onPressed: _sending ? null : _sendMessage,
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
