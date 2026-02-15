import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/employee_repository.dart';
import '../widgets/shift_info_header_widget.dart';
import '../widgets/time_tracking_card_widget.dart';
import '../widgets/recent_entries_card_widget.dart';
import '../widgets/machine_status_card_widget.dart';
import '../widgets/expense_capture_card_widget.dart';
import '../widgets/leave_request_card_widget.dart';
import '../widgets/quick_actions_sheet.dart';
import '../widgets/employee_bottom_nav.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  final _repo = EmployeeRepository();

  int _bottomIndex = 0;
  String _selectedLine = "Ligne Production A";

  @override
  Widget build(BuildContext context) {
    final profile = _repo.getProfile();
    final timeStats = _repo.getTimeStats();
    final lines = _repo.getLines();
    final recent = _repo.getRecentEntries();
    final machines = _repo.getMachines();
    final leave = _repo.getLeaveStats();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bg,
        title: const Text(
          "Tableau de Bord",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openQuickActions,
            icon: const Icon(Icons.more_horiz, color: AppColors.textDark),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          ShiftInfoHeaderWidget(profile: profile),
          const SizedBox(height: 14),
          TimeTrackingCardWidget(
            stats: timeStats,
            lines: lines,
            selectedLine: _selectedLine,
            onLineChanged: (v) => setState(() => _selectedLine = v),
            onStart: () => _toast("Démarrer (à brancher)"),
          ),
          const SizedBox(height: 14),
          RecentEntriesCardWidget(entries: recent),
          const SizedBox(height: 14),
          MachineStatusCardWidget(
            machines: machines,
            onLongPressScan: () => _toast("Scanner QR (à brancher)"),
          ),
          const SizedBox(height: 14),
          ExpenseCaptureCardWidget(
            // ✅ NOW OPENS SCAN FRAIS SCREEN
            onScan: () => Navigator.pushNamed(context, "/employe-scan-frais"),
            onAuto: () => _toast("Traitement auto (à brancher)"),
            onCat: () => _toast("Catégorisation (à brancher)"),
          ),
          const SizedBox(height: 14),
          LeaveRequestCardWidget(
            leave: leave,
            onNewRequest: () => _toast("Nouvelle demande (à brancher)"),
          ),
        ],
      ),

      // ✅ BOTTOM NAV NOW ROUTES
      bottomNavigationBar: EmployeeBottomNav(
        currentIndex: _bottomIndex,
        onTap: (i) => _handleBottomNav(context, i),
      ),
    );
  }

  void _handleBottomNav(BuildContext context, int index) {
    if (index == _bottomIndex) return;

    setState(() => _bottomIndex = index);

    switch (index) {
      case 0:
        // ✅ Stay on dashboard
        Navigator.pushReplacementNamed(context, "/employe");
        break;

      case 1:
        _toast("Temps (à brancher)");
        break;

      case 2:
        // ✅ FRAIS TAB -> list screen
        Navigator.pushReplacementNamed(context, "/employe-frais");
        break;

      case 3:
        _toast("Approbations (à brancher)");
        break;

      case 4:
        // ✅ PROFIL
        Navigator.pushReplacementNamed(context, "/employe-profile");
        break;
    }
  }

  void _openQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => QuickActionsSheet(
        onTap: (action) {
          Navigator.pop(context); // ✅ close sheet

          switch (action) {
            case "Capturer Frais":
              Navigator.pushNamed(context, "/employe-scan-frais");
              break;

            case "Pointer Entrée/Sortie":
              _toast("Pointer Entrée/Sortie (à brancher)");
              break;

            case "Signaler Incident":
              _toast("Signaler Incident (à brancher)");
              break;

            case "Scanner QR Machine":
              _toast("Scanner QR Machine (à brancher)");
              break;

            default:
              _toast("$action (à brancher)");
          }
        },
      ),
    );
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
