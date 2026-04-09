import 'package:flutter/material.dart';
import '../../../../core/config/api_config.dart';
import '../../../employee/data/me_service.dart';
import '../../data/models/manager_conversation_model.dart';
import '../../data/models/message_contact_model.dart';
import '../../data/services/manager_message_repository.dart';
import '../widgets/manager_badge_store.dart';
import '../widgets/manager_bottom_nav.dart';

class ManagerMessagesScreen extends StatefulWidget {
  const ManagerMessagesScreen({super.key});

  @override
  State<ManagerMessagesScreen> createState() => _ManagerMessagesScreenState();
}

class _ManagerMessagesScreenState extends State<ManagerMessagesScreen> {
  final ManagerMessageRepository _repo = ManagerMessageRepository();
  final MeService _meService = MeService();
  final TextEditingController _searchController = TextEditingController();

  String get _backendBaseUrl => ApiConfig.baseUrl;

  List<ManagerConversationModel> _conversations = [];
  List<ManagerConversationModel> _filteredConversations = [];
  bool _loading = true;
  String? _error;

  bool _selectionMode = false;
  final Set<int> _selectedConversationIds = {};

  String? _myAvatarUrl;
  String? _myName;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadMyProfile(),
      _loadConversations(),
    ]);
  }

  Future<void> _loadMyProfile() async {
    try {
      final me = await _meService.getMe();
      if (!mounted) return;
      setState(() {
        _myAvatarUrl = _cleanAvatar(me.avatarUrl);
        _myName = me.name.trim().isNotEmpty ? me.name.trim() : null;
      });
    } catch (_) {}
  }

  String? _cleanAvatar(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repo.getConversations();
      if (!mounted) return;

      _updateUnreadBadge(data);

      setState(() {
        _conversations = data;
        _filteredConversations = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _updateUnreadBadge(List<ManagerConversationModel> conversations) {
    int unreadTotal = 0;

    for (final c in conversations) {
      if (c.hasUnread) {
        unreadTotal += 1;
      }
    }

    ManagerBadgeStore.setUnreadMessages(unreadTotal);
  }

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations.where((c) {
          final lastText = _formatSubtitle(c).toLowerCase();
          return c.contactName.toLowerCase().contains(query) ||
              c.contactRole.toLowerCase().contains(query) ||
              lastText.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _openNewConversationDialog() async {
    try {
      final contacts = await _repo.getMessageableUsers();
      if (!mounted) return;

      final selected = await showModalBottomSheet<MessageContactModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ContactPickerSheet(
          contacts: contacts,
          backendBaseUrl: _backendBaseUrl,
        ),
      );

      if (selected == null || !mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final conversation = await _repo.startConversation(selected.id);
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      Navigator.pushNamed(
        context,
        '/manager/chat-detail',
        arguments: {
          'conversationId': conversation.id,
          'contactName': selected.name,
          'contactRole': selected.role,
          'contactAvatarUrl': selected.avatarUrl,
          'myAvatarUrl': _myAvatarUrl,
          'myName': _myName,
        },
      ).then((_) => _loadConversations());
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _openConversation(ManagerConversationModel conversation) {
    Navigator.pushNamed(
      context,
      '/manager/chat-detail',
      arguments: {
        'conversationId': conversation.id,
        'contactName': conversation.contactName,
        'contactRole': conversation.contactRole,
        'contactAvatarUrl': conversation.avatarUrl,
        'myAvatarUrl': _myAvatarUrl,
        'myName': _myName,
      },
    ).then((_) => _loadConversations());
  }

  void _enableSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedConversationIds.clear();
    });
  }

  void _disableSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedConversationIds.clear();
    });
  }

  void _toggleConversationSelection(int conversationId) {
    setState(() {
      if (_selectedConversationIds.contains(conversationId)) {
        _selectedConversationIds.remove(conversationId);
      } else {
        _selectedConversationIds.add(conversationId);
      }

      if (_selectedConversationIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  Future<void> _confirmDeleteSelectedConversations() async {
    if (_selectedConversationIds.isEmpty) return;

    final count = _selectedConversationIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Supprimer la conversation'),
        content: Text(
          count == 1
              ? 'Voulez-vous vraiment supprimer cette conversation ?'
              : 'Voulez-vous vraiment supprimer $count conversations ?',
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
      await _deleteSelectedConversations();
    }
  }

  Future<void> _deleteSelectedConversations() async {
    try {
      final idsToDelete = _selectedConversationIds.toList();

      for (final id in idsToDelete) {
        await _repo.deleteConversation(id);
      }

      if (!mounted) return;

      final updatedConversations =
          _conversations.where((c) => !idsToDelete.contains(c.id)).toList();

      setState(() {
        _conversations = updatedConversations;
        _selectionMode = false;
        _selectedConversationIds.clear();
      });

      _updateUnreadBadge(updatedConversations);
      _applySearch();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            idsToDelete.length == 1
                ? 'Conversation supprimée'
                : '${idsToDelete.length} conversations supprimées',
          ),
        ),
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

  String _formatSubtitle(ManagerConversationModel item) {
    final last = item.lastMessage;
    if (last == null) return 'Commencer une conversation';
    if (last.deleted) {
      return last.mine
          ? 'Vous avez supprim\u00e9 un message'
          : 'Ce message a \u00e9t\u00e9 supprim\u00e9';
    }
    return last.content;
  }

  String _formatTime(String value) {
    if (value.trim().isEmpty) return '';
    final parts = value.split('T');
    if (parts.length == 2 && parts[1].length >= 5) {
      return parts[1].substring(0, 5);
    }
    if (value.length >= 16) {
      return value.substring(value.length - 5);
    }
    return value;
  }

  String? _conversationAvatarUrl(ManagerConversationModel item) {
    final value = item.avatarUrl;
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  String _normalizeImageUrl(String url) {
    return ApiConfig.resolveUrl(url);
  }

  Widget _buildAvatar({
    required String name,
    String? avatarUrl,
    double radius = 28,
  }) {
    final normalizedUrl = (avatarUrl != null && avatarUrl.trim().isNotEmpty)
        ? _normalizeImageUrl(avatarUrl)
        : null;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.indigo.withValues(alpha: 0.12),
      ),
      child: ClipOval(
        child: normalizedUrl != null
            ? Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_selectionMode) {
      return AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        leading: IconButton(
          onPressed: _disableSelectionMode,
          icon: const Icon(Icons.close),
        ),
        title: Text('${_selectedConversationIds.length} sélectionné(s)'),
        actions: [
          IconButton(
            onPressed: _selectedConversationIds.isEmpty
                ? null
                : _confirmDeleteSelectedConversations,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('Messages'),
      backgroundColor: Colors.indigo,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: _enableSelectionMode,
          child: const Text(
            'Sélectionner',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? Colors.indigo : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.indigo : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(
            color: Colors.indigo,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation...',
                prefixIcon: const Icon(Icons.search),
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Erreur: $_error'))
                    : _filteredConversations.isEmpty
                        ? const Center(child: Text('Aucune conversation.'))
                        : RefreshIndicator(
                            onRefresh: _loadConversations,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredConversations.length,
                              itemBuilder: (context, index) {
                                final item = _filteredConversations[index];
                                final unreadApprox = item.hasUnread;
                                final isSelected =
                                    _selectedConversationIds.contains(item.id);
                                final avatarUrl = _conversationAvatarUrl(item);

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.indigo.withValues(alpha: 0.06)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: isSelected
                                        ? Border.all(
                                            color:
                                                Colors.indigo.withValues(alpha: 0.35),
                                            width: 1.4,
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
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    onTap: () {
                                      if (_selectionMode) {
                                        _toggleConversationSelection(item.id);
                                      } else {
                                        _openConversation(item);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          if (_selectionMode) ...[
                                            _buildSelectionIndicator(isSelected),
                                            const SizedBox(width: 12),
                                          ],
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              _buildAvatar(
                                                name: item.contactName,
                                                avatarUrl: avatarUrl,
                                                radius: 28,
                                              ),
                                              if (unreadApprox)
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.contactName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: unreadApprox
                                                              ? FontWeight.w800
                                                              : FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _formatTime(
                                                        item.lastMessage?.sentAt ?? '',
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: unreadApprox
                                                            ? Colors.indigo
                                                            : Colors.grey.shade500,
                                                        fontWeight: unreadApprox
                                                            ? FontWeight.w700
                                                            : FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  item.contactRole,
                                                  style: TextStyle(
                                                    color: Colors.indigo.shade400,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _formatSubtitle(item),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: unreadApprox
                                                        ? Colors.black87
                                                        : Colors.grey.shade600,
                                                    fontWeight: unreadApprox
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!_selectionMode && unreadApprox) ...[
                                            const SizedBox(width: 10),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                '1',
                                                style: TextStyle(
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
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.indigo,
              onPressed: _openNewConversationDialog,
              child: const Icon(Icons.add_comment_outlined),
            ),
      bottomNavigationBar: const ManagerBottomNav(currentIndex: 2),
    );
  }
}

class _ContactPickerSheet extends StatelessWidget {
  final List<MessageContactModel> contacts;
  final String backendBaseUrl;

  const _ContactPickerSheet({
    required this.contacts,
    required this.backendBaseUrl,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String? _contactAvatarUrl(MessageContactModel contact) {
    final value = contact.avatarUrl;
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  String _normalizeImageUrl(String url) {
    return ApiConfig.resolveUrl(url);
  }

  Widget _buildAvatar({
    required String name,
    String? avatarUrl,
  }) {
    final normalizedUrl = (avatarUrl != null && avatarUrl.trim().isNotEmpty)
        ? _normalizeImageUrl(avatarUrl)
        : null;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.indigo.withValues(alpha: 0.12),
      ),
      child: ClipOval(
        child: normalizedUrl != null
            ? Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  _initials(name),
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
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nouveau message',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: contacts.isEmpty
                ? const Center(child: Text('Aucun contact disponible'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final c = contacts[index];
                      final avatarUrl = _contactAvatarUrl(c);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: _buildAvatar(
                            name: c.name,
                            avatarUrl: avatarUrl,
                          ),
                          title: Text(
                            c.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(c.role),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 17,
                            color: Colors.indigo,
                          ),
                          onTap: () => Navigator.pop(context, c),
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
