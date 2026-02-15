import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/manager_repository.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/projects_tab.dart';
import '../tabs/team_tab.dart';
import '../tabs/profile_tab.dart';
import '../widgets/header_card.dart';
import '../widgets/bottom_nav.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  final _repo = ManagerRepository();
  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = _repo.getProfile();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HeaderCard(profile: profile),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                  tabs: const [
                    Tab(text: "Tableau"),
                    Tab(text: "Projets"),
                    Tab(text: "Équipe"),
                    Tab(text: "Profil"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: [
                    DashboardTab(repo: _repo),
                    ProjectsTab(repo: _repo),
                    TeamTab(repo: _repo),
                    ProfileTab(repo: _repo),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _bottomIndex,
          onTap: (i) => setState(() => _bottomIndex = i),
          onCenterTap: () => _toast("Temps (à brancher)"),
        ),
      ),
    );
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
