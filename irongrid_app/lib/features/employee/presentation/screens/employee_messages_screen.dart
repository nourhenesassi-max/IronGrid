import 'package:flutter/material.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_store.dart';
import '../../data/employee_message_api.dart';
import '../../data/models/employee_models.dart';
import '../widgets/employee_badge_store.dart';
import 'employee_chat_args.dart';

class EmployeeMessagesScreen extends StatefulWidget {
  const EmployeeMessagesScreen({super.key});

  @override
  State<EmployeeMessagesScreen> createState() => _EmployeeMessagesScreenState();
}

class _EmployeeMessagesScreenState extends State<EmployeeMessagesScreen> {
  late final EmployeeMessageApi api;
  late Future<List<EmployeeConversation>> _future;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    api = EmployeeMessageApi(
      baseUrl: ApiConfig.baseUrl,
      tokenProvider: () async => await SecureStore.readToken(),
    );

    _future = _loadConversationsAndBadge();
  }

  Future<List<EmployeeConversation>> _loadConversationsAndBadge() async {
    final conversations = await api.getConversations();

    int unreadCount = 0;
    for (final conversation in conversations) {
      unreadCount += _extractUnreadCount(conversation);
    }

    EmployeeBadgeStore.setUnreadMessages(unreadCount);
    return conversations;
  }

  int _extractUnreadCount(EmployeeConversation conversation) {
    return conversation.unreadCount;
  }

  Future<void> _reload() async {
    final future = _loadConversationsAndBadge();

    setState(() {
      _future = future;
    });

    await future;
  }

  Future<void> _showCreateMenu() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Nouveau message',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2559),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choisissez une action pour demarrer une conversation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: const Text('Nouvelle conversation'),
                  subtitle: const Text('Envoyer un message à un utilisateur'),
                  onTap: () => Navigator.pop(context, 'direct'),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.group_outlined),
                  ),
                  title: const Text('Nouveau groupe'),
                  subtitle:
                      const Text('Créer un groupe et discuter à plusieurs'),
                  onTap: () => Navigator.pop(context, 'group'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || choice == null) return;

    if (choice == 'direct') {
      await _newDirectConversation();
    } else if (choice == 'group') {
      await _newGroupConversation();
    }
  }

  Future<void> _newDirectConversation() async {
    try {
      final users = await api.getMessageableUsers();
      if (!mounted) return;

      final sortedUsers = [...users]
        ..sort(
          (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );

      final selected = await showModalBottomSheet<MessageableUser>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _UserPickerSheet(users: sortedUsers),
      );

      if (selected == null || !mounted) return;

      await Navigator.pushNamed(
        context,
        '/employe-chat-detail',
        arguments: EmployeeChatArgs(selectedUser: selected),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    }
  }

  Future<void> _newGroupConversation() async {
    try {
      final users = await api.getMessageableUsers();
      if (!mounted) return;

      final sortedUsers = [...users]
        ..sort(
          (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );

      final result = await showModalBottomSheet<_GroupCreationResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (_) => _CreateGroupSheet(users: sortedUsers),
      );

      if (result == null) return;

      final conversation = await api.createGroupConversation(
        groupName: result.groupName,
        memberIds: result.memberIds,
      );

      if (!mounted) return;

      await Navigator.pushNamed(
        context,
        '/employe-chat-detail',
        arguments: EmployeeChatArgs(conversation: conversation),
      );

      await _reload();
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }

  String _formatPreviewTime(String raw) {
    if (raw.trim().isEmpty) return '';
    if (raw.length >= 16) {
      return raw.substring(11, 16);
    }
    return raw;
  }

  String _conversationPreview(EmployeeConversation conversation) {
    final lastMessage = conversation.lastMessage;
    if (lastMessage == null) {
      return 'Touchez pour ouvrir la conversation';
    }

    if (lastMessage.deleted) {
      return lastMessage.isMine
          ? 'Vous avez supprim\u00e9 un message'
          : 'Ce message a \u00e9t\u00e9 supprim\u00e9';
    }

    return lastMessage.content;
  }

  String? _normalizeAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null) return null;
    final clean = avatarUrl.trim();
    if (clean.isEmpty || clean.toLowerCase() == 'null') return null;
    return ApiConfig.resolveUrl(clean);
  }

  String _initials(String value) {
    final parts = value.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildPersonAvatar({
    required String name,
    required String? avatarUrl,
    double radius = 28,
    Color backgroundColor = const Color(0xFFE8ECF8),
    Color textColor = Colors.indigo,
  }) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl,
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

  Widget _buildConversationAvatar(EmployeeConversation conversation) {
    if (conversation.isGroup) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE9F7EF),
              Color(0xFFD9F0E3),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.groups_rounded,
          color: Color(0xFF1F8F5F),
          size: 28,
        ),
      );
    }

    return _buildPersonAvatar(
      name: conversation.displayTitle,
      avatarUrl: _normalizeAvatarUrl(conversation.avatarUrl),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F7FB);
    const primary = Colors.indigo;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: _showCreateMenu,
        child: const Icon(Icons.add_comment_outlined),
      ),
      body: Column(
        children: [
          Container(
            color: primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<EmployeeConversation>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final q = _searchCtrl.text.trim().toLowerCase();

                final conversations = all.where((c) {
                  if (q.isEmpty) return true;
                  return c.displayTitle.toLowerCase().contains(q) ||
                      c.displaySubtitle.toLowerCase().contains(q) ||
                      _conversationPreview(c).toLowerCase().contains(q);
                }).toList();

                if (conversations.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 180),
                        Icon(
                          Icons.forum_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Aucune conversation disponible.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final lastMessage = conversation.lastMessage;
                      final unreadCount = conversation.unreadCount;
                      final hasUnread = unreadCount > 0;

                      return InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/employe-chat-detail',
                            arguments: EmployeeChatArgs(
                              conversation: conversation,
                            ),
                          );
                          await _reload();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: hasUnread
                                ? Border.all(
                                    color: primary.withValues(alpha: 0.28),
                                    width: 1.3,
                                  )
                                : null,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildConversationAvatar(conversation),
                                  if (hasUnread)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            conversation.displayTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: hasUnread
                                                  ? FontWeight.w800
                                                  : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          lastMessage == null
                                              ? ''
                                              : _formatPreviewTime(
                                                  lastMessage.sentAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: hasUnread
                                                ? primary
                                                : Colors.grey.shade500,
                                            fontWeight: hasUnread
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      conversation.displaySubtitle,
                                      style: TextStyle(
                                        color: Colors.indigo.shade400,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _conversationPreview(conversation),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: hasUnread
                                            ? Colors.black87
                                            : Colors.grey.shade600,
                                        fontWeight: hasUnread
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasUnread) ...[
                                const SizedBox(width: 10),
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCreationResult {
  final String groupName;
  final List<String> memberIds;

  const _GroupCreationResult({
    required this.groupName,
    required this.memberIds,
  });
}

class _UserPickerSheet extends StatefulWidget {
  final List<MessageableUser> users;

  const _UserPickerSheet({
    required this.users,
  });

  @override
  State<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends State<_UserPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  String? _normalizeAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null) return null;
    final clean = avatarUrl.trim();
    if (clean.isEmpty || clean.toLowerCase() == 'null') return null;
    return ApiConfig.resolveUrl(clean);
  }

  String _initials(String value) {
    final parts = value.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildAvatar(MessageableUser user) {
    final avatarUrl = _normalizeAvatarUrl(user.avatarUrl);
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8ECF8),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    _initials(user.fullName),
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  _initials(user.fullName),
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = widget.users.where((user) {
      if (query.isEmpty) return true;
      return user.fullName.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 560,
          child: Column(
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nouvelle conversation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2559),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('Aucun utilisateur disponible.'),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final secondaryLabel = user.email.isNotEmpty
                              ? '${user.role} · ${user.email}'
                              : user.role;
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.pop(context, user),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    _buildAvatar(user),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.fullName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            secondaryLabel,
                                            style: TextStyle(
                                              color: Colors.indigo.shade400,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: Colors.indigo,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateGroupSheet extends StatefulWidget {
  final List<MessageableUser> users;

  const _CreateGroupSheet({
    required this.users,
  });

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final TextEditingController _groupNameCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _selectedIds = {};

  String? _normalizeAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null) return null;
    final clean = avatarUrl.trim();
    if (clean.isEmpty || clean.toLowerCase() == 'null') return null;
    return ApiConfig.resolveUrl(clean);
  }

  String _initials(String value) {
    final parts = value.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildAvatar(MessageableUser user) {
    final avatarUrl = _normalizeAvatarUrl(user.avatarUrl);
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8ECF8),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    _initials(user.fullName),
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  _initials(user.fullName),
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _groupNameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _groupNameCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un nom de groupe')),
      );
      return;
    }

    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un membre'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _GroupCreationResult(
        groupName: name,
        memberIds: _selectedIds.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredUsers = widget.users.where((user) {
      if (query.isEmpty) return true;
      return user.fullName.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Créer un groupe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _groupNameCtrl,
              decoration: InputDecoration(
                hintText: 'Nom du groupe',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher des utilisateurs...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (filteredUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Aucun utilisateur disponible.'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final selected = _selectedIds.contains(user.id);
                    final secondaryLabel = user.email.isNotEmpty
                        ? '${user.role} · ${user.email}'
                        : user.role;

                    return CheckboxListTile(
                      value: selected,
                      activeColor: Colors.indigo,
                      onChanged: (_) {
                        setState(() {
                          if (selected) {
                            _selectedIds.remove(user.id);
                          } else {
                            _selectedIds.add(user.id);
                          }
                        });
                      },
                      title: Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(secondaryLabel),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: _buildAvatar(user),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.groups_rounded),
                label: const Text(
                  'Créer le groupe',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
