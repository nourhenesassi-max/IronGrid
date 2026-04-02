import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/leave_service.dart';
import '../../data/me_service.dart';
import '../../data/employee_repository.dart';
import '../../data/models/employee_profile.dart';
import '../../data/models/employee_models.dart';
import '../../data/models/leave_models.dart';
import '../widgets/time_tracking_card_widget.dart';
import '../widgets/machine_status_card_widget.dart';
import '../widgets/leave_request_card_widget.dart';
import '../widgets/quick_actions_sheet.dart';
import '../widgets/employee_bottom_nav.dart';
import '../widgets/employee_badge_store.dart';
import 'employee_machine_state_history_screen.dart';
import 'employee_leave_screen.dart';
import 'employee_new_leave_screen.dart';

// Employee screens
import 'planification/planification_screen_employee.dart';
import 'production/production_screen_employee.dart';
import 'qualite/qualite_screen_employee.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  final _leaveService = LeaveService();
  final _meService = MeService();
  final _employeeRepository = EmployeeRepository();

  Timer? _messagesPollingTimer;

  int _bottomIndex = 0;
  String _selectedLine = "Ligne Production A";

  EmployeeProfile? _profile;
  bool _profileLoading = true;
  String? _profileError;

  LeaveStatsResponse? _leaveStats;
  bool _leaveLoading = true;
  String? _leaveError;

  AttendanceCardData? _attendance;
  bool _attendanceLoading = true;
  String? _attendanceError;

  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _startUnreadMessagesPolling();
  }

  @override
  void dispose() {
    _messagesPollingTimer?.cancel();
    super.dispose();
  }

  void _startUnreadMessagesPolling() {
    _messagesPollingTimer?.cancel();
    _messagesPollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadUnreadMessages(),
    );
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadProfile(),
      _loadLeaveStats(),
      _loadUnreadNotifications(),
      _loadUnreadMessages(),
      _loadAttendance(),
    ]);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _profileLoading = true;
      _profileError = null;
    });

    try {
      final profile = await _meService.getMe();
      if (!mounted) return;

      setState(() {
        _profile = profile;
        _profileLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _profileError = e.toString();
        _profileLoading = false;
      });
    }
  }

  Future<void> _loadLeaveStats() async {
    setState(() {
      _leaveLoading = true;
      _leaveError = null;
    });

    try {
      final stats = await _leaveService.getStats();
      if (!mounted) return;

      setState(() {
        _leaveStats = stats;
        _leaveLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _leaveError = e.toString();
        _leaveLoading = false;
      });
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final notifications = await _employeeRepository.getNotifications();
      if (!mounted) return;

      setState(() {
        _unreadNotifications =
            notifications.where((n) => n.isRead == false).length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unreadNotifications = 0;
      });
    }
  }

  Future<void> _loadUnreadMessages() async {
    try {
      final count = await _employeeRepository.getUnreadMessagesCount();
      if (!mounted) return;
      EmployeeBadgeStore.setUnreadMessages(count);
    } catch (_) {
      if (!mounted) return;
      EmployeeBadgeStore.setUnreadMessages(0);
    }
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _attendanceLoading = true;
      _attendanceError = null;
    });

    try {
      final data = AttendanceCardData(
        status: AttendanceStatus.notStarted,
        todayWorked: '0h 0m',
        weekWorked: '0h 0m',
        lastEventLabel: null,
        anomalyMessage: null,
        primaryActionLabel: 'Démarrer',
        primaryActionIcon: Icons.play_arrow,
      );

      if (!mounted) return;

      setState(() {
        _attendance = data;
        _attendanceLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _attendanceError = e.toString();
        _attendanceLoading = false;
      });
    }
  }

  Future<void> _handleAttendanceAction() async {
    if (_attendance == null) return;

    try {
      switch (_attendance!.status) {
        case AttendanceStatus.notStarted:
          setState(() {
            _attendance = AttendanceCardData(
              status: AttendanceStatus.working,
              todayWorked: _attendance!.todayWorked,
              weekWorked: _attendance!.weekWorked,
              lastEventLabel: "Check-in maintenant",
              anomalyMessage: null,
              primaryActionLabel: "Terminer",
              primaryActionIcon: Icons.stop,
            );
          });
          break;

        case AttendanceStatus.working:
          setState(() {
            _attendance = AttendanceCardData(
              status: AttendanceStatus.notStarted,
              todayWorked: "8h 00m",
              weekWorked: "8h 00m",
              lastEventLabel: "Check-out maintenant",
              anomalyMessage: null,
              primaryActionLabel: "Démarrer",
              primaryActionIcon: Icons.play_arrow,
            );
          });
          break;

        case AttendanceStatus.onBreak:
          setState(() {
            _attendance = AttendanceCardData(
              status: AttendanceStatus.working,
              todayWorked: _attendance!.todayWorked,
              weekWorked: _attendance!.weekWorked,
              lastEventLabel: "Reprise maintenant",
              anomalyMessage: null,
              primaryActionLabel: "Terminer",
              primaryActionIcon: Icons.stop,
            );
          });
          break;

        case AttendanceStatus.incomplete:
          if (!mounted) return;
          await Navigator.pushNamed(context, "/employe-timesheet");
          return;

        case AttendanceStatus.pendingValidation:
          _toast("Cette journée est en attente de validation.");
          return;
      }
    } catch (e) {
      _toast("Erreur : $e");
    }
  }

  void _openPlanificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlanificationScreenEmployee(),
      ),
    );
  }

  void _openProductionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductionScreenEmployee(),
      ),
    );
  }

  void _openQualiteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QualiteScreenEmployee(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      'Ligne Production A',
      'Ligne Production B',
      'Ligne Production C',
    ];

    final machines = <MachineStatus>[
      MachineStatus(
        name: 'Machine M-204',
        code: 'M-204',
        statusText: 'Opérationnelle',
        statusColorValue: Colors.green.value,
        lastCheck: 'Aujourd’hui',
      ),
      MachineStatus(
        name: 'Machine M-310',
        code: 'M-310',
        statusText: 'Maintenance',
        statusColorValue: Colors.orange.value,
        lastCheck: 'Il y a 1h',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF6F8FC),
        titleSpacing: 16,
        title: const Text(
          "Tableau de bord",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          _buildNotificationsIcon(),
          IconButton(
            onPressed: _openQuickActions,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_horiz, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (_profileLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_profileError != null)
              _buildErrorCard("Erreur profil : $_profileError")
            else if (_profile != null)
              _buildShiftProjectHeader(_profile!),
            const SizedBox(height: 16),
            if (_attendanceLoading)
              const Center(child: CircularProgressIndicator())
            else if (_attendanceError != null)
              _buildErrorCard("Erreur temps : $_attendanceError")
            else if (_attendance != null)
              TimeTrackingCardWidget(
                data: _attendance!,
                lines: lines,
                selectedLine: _selectedLine,
                onLineChanged: (v) => setState(() => _selectedLine = v),
                onPrimaryAction: _handleAttendanceAction,
                isLoading: _attendanceLoading,
              ),
            const SizedBox(height: 20),
            _buildSectionTitle('Mes pôles'),
            const SizedBox(height: 12),
            _buildModulesSection(),
            const SizedBox(height: 20),
            _buildSectionTitle('État des machines'),
            const SizedBox(height: 12),
            MachineStatusCardWidget(
              machines: machines,
              onTapState: _openMachineStateHistory,
              onLongPressScan: () => _toast("Scanner QR (à brancher)"),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(
              'Congés',
              onTap: _openAcceptedLeavesPage,
            ),
            const SizedBox(height: 12),
            if (_leaveLoading)
              const Center(child: CircularProgressIndicator())
            else if (_leaveError != null)
              _buildErrorCard(_leaveError!)
            else if (_leaveStats != null)
              _buildLeaveCardSection(),
          ],
        ),
      ),
      bottomNavigationBar: EmployeeBottomNav(
        currentIndex: _bottomIndex,
        onTap: (i) => _handleBottomNav(context, i),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    final titleRow = Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          Row(
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
      ],
    );

    if (onTap == null) return titleRow;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: titleRow,
        ),
      ),
    );
  }

  Widget _buildLeaveCardSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _openAcceptedLeavesPage,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: LeaveRequestCardWidget(
            leave: LeaveStats(
              annualDays: "${_leaveStats!.annualDaysRemaining} jours",
              sickDays: "${_leaveStats!.sickDaysRemaining} jours",
              pendingApprovals:
                  "${_leaveStats!.pendingCount} ${_leaveStats!.pendingCount > 1 ? 'demandes' : 'demande'}",
            ),
            onOpenLeaves: _openAcceptedLeavesPage,
          ),
        ),
      ),
    );
  }

  Widget _buildModulesSection() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _buildModuleCard(
          title: 'Planification',
          icon: Icons.event_note_outlined,
          color: Colors.blue,
          onTap: _openPlanificationScreen,
        ),
        _buildModuleCard(
          title: 'Production',
          icon: Icons.precision_manufacturing_outlined,
          color: Colors.green,
          onTap: _openProductionScreen,
        ),
        _buildModuleCard(
          title: 'Qualité',
          icon: Icons.verified_outlined,
          color: Colors.purple,
          onTap: _openQualiteScreen,
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftProjectHeader(EmployeeProfile profile) {
    final hour = DateTime.now().hour;

    String equipe;
    IconData shiftIcon;
    if (hour >= 5 && hour < 12) {
      equipe = "Équipe matinale";
      shiftIcon = Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 18) {
      equipe = "Équipe d'après-midi";
      shiftIcon = Icons.sunny;
    } else {
      equipe = "Équipe de nuit";
      shiftIcon = Icons.nights_stay_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              shiftIcon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipe,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Travaille sur : ${profile.projectLabel}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildInfoChip(
                      icon: Icons.person_outline,
                      label: profile.name,
                    ),
                    _buildInfoChip(
                      icon: Icons.groups_rounded,
                      label: profile.teamLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAcceptedLeavesPage() async {
    await Navigator.pushNamed(context, "/employe-leaves");
    await _loadLeaveStats();
  }

  Future<void> _openNewLeaveRequestPage() async {
    try {
      await Navigator.pushNamed(context, "/employe-leaves/new");
    } catch (_) {
      await Navigator.pushNamed(context, "/employe-leaves");
    }

    if (!mounted) return;
    await _loadLeaveStats();
  }

  void _openMachineStateHistory(String stateLabel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeMachineStateHistoryScreen(
          stateLabel: stateLabel,
        ),
      ),
    );
  }

  Widget _buildNotificationsIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.textDark,
            ),
          ),
          onPressed: () async {
            await Navigator.pushNamed(context, "/employe-notifications");
            await _loadUnreadNotifications();
          },
        ),
        if (_unreadNotifications > 0)
          Positioned(
            right: 4,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _unreadNotifications > 99 ? '99+' : '$_unreadNotifications',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleBottomNav(BuildContext context, int index) async {
    if (index == _bottomIndex) return;

    setState(() => _bottomIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        await Navigator.pushNamed(context, "/employe-timesheet");
        break;
      case 2:
        EmployeeBadgeStore.clear();
        await Navigator.pushNamed(context, "/employe-messages");
        await _loadUnreadMessages();
        break;
      case 3:
        await Navigator.pushNamed(context, "/employe-profile");
        break;
    }

    if (!mounted) return;
    setState(() => _bottomIndex = 0);
  }

  void _openQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => QuickActionsSheet(
        onTap: (action) async {
          Navigator.pop(context);

          switch (action) {
            case "Pointer Entrée/Sortie":
              await Navigator.pushNamed(context, "/employe-timesheet");
              break;
            case "Messages":
              EmployeeBadgeStore.clear();
              await Navigator.pushNamed(context, "/employe-messages");
              await _loadUnreadMessages();
              break;
            case "Notifications":
              await Navigator.pushNamed(context, "/employe-notifications");
              await _loadUnreadNotifications();
              break;
            case "Congés":
              await _openAcceptedLeavesPage();
              break;
            default:
              _toast("$action (à brancher)");
          }
        },
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}