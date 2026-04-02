class TimeStats {
  final String today;
  final String week;

  TimeStats({
    required this.today,
    required this.week,
  });
}

class RecentEntry {
  final String title;
  final String dateRange;
  final String duration;

  RecentEntry({
    required this.title,
    required this.dateRange,
    required this.duration,
  });
}

class MachineStatus {
  final String name;
  final String code;
  final String statusText;
  final int statusColorValue;
  final String lastCheck;

  MachineStatus({
    required this.name,
    required this.code,
    required this.statusText,
    required this.statusColorValue,
    required this.lastCheck,
  });
}

class LeaveStats {
  final String annualDays;
  final String sickDays;
  final String pendingApprovals;

  LeaveStats({
    required this.annualDays,
    required this.sickDays,
    required this.pendingApprovals,
  });
}

class EmployeeProject {
  final String id;
  final String projectName;
  final String managerName;
  final String deadline;
  final String status;
  final String priority;
  final List<ProjectTask> tasks;

  EmployeeProject({
    required this.id,
    required this.projectName,
    required this.managerName,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.tasks,
  });

  factory EmployeeProject.fromJson(Map<String, dynamic> json) {
    final tasksJson = (json['tasks'] as List<dynamic>? ?? []);

    return EmployeeProject(
      id: (json['id'] ?? '').toString(),
      projectName: (json['projectName'] ?? '').toString(),
      managerName:
          (json['employeeName'] ?? json['managerName'] ?? 'Manager').toString(),
      deadline: (json['deadline'] ?? '').toString(),
      status: (json['status'] ?? 'En cours').toString(),
      priority: (json['priority'] ?? '').toString(),
      tasks: tasksJson.map((e) => ProjectTask.fromJson(e)).toList(),
    );
  }
}

class ProjectTask {
  final String id;
  final String title;
  final String status;
  final String deadline;
  final String assignedBy;

  ProjectTask({
    required this.id,
    required this.title,
    required this.status,
    required this.deadline,
    required this.assignedBy,
  });

  factory ProjectTask.fromJson(dynamic raw) {
    if (raw is String) {
      return ProjectTask(
        id: raw,
        title: raw,
        status: 'À faire',
        deadline: '',
        assignedBy: 'Manager',
      );
    }

    final json = raw as Map<String, dynamic>;
    return ProjectTask(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? 'À faire').toString(),
      deadline: (json['deadline'] ?? '').toString(),
      assignedBy: (json['assignedBy'] ?? 'Manager').toString(),
    );
  }
}

class EmployeeNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  EmployeeNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  factory EmployeeNotification.fromJson(Map<String, dynamic> json) {
    return EmployeeNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['content'] ?? json['message'] ?? '').toString(),
      time: (json['createdAt'] ?? json['time'] ?? '').toString(),
      isRead: json['read'] == true || json['isRead'] == true,
    );
  }
}

class EmployeeMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String? senderAvatarUrl;
  final String content;
  final String sentAt;
  final bool isMine;
  final bool deleted;

  EmployeeMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderAvatarUrl,
    required this.content,
    required this.sentAt,
    required this.isMine,
    required this.deleted,
  });

  factory EmployeeMessage.fromJson(Map<String, dynamic> json) {
    return EmployeeMessage(
      id: (json['id'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? '').toString(),
      senderAvatarUrl: json['senderAvatarUrl']?.toString(),
      content: (json['content'] ?? '').toString(),
      sentAt: (json['sentAt'] ?? '').toString(),
      isMine: json['mine'] == true,
      deleted: json['deleted'] == true,
    );
  }
}

class EmployeeConversation {
  final String id;
  final String? contactId;
  final String contactName;
  final String contactRole;
  final String? avatarUrl;
  final List<EmployeeMessage> messages;
  final EmployeeMessage? lastMessage;

  final bool isGroup;
  final String? groupName;
  final int memberCount;
  final int unreadCount;

  EmployeeConversation({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.contactRole,
    this.avatarUrl,
    required this.messages,
    required this.lastMessage,
    required this.isGroup,
    required this.groupName,
    required this.memberCount,
    required this.unreadCount,
  });

  factory EmployeeConversation.fromJson(Map<String, dynamic> json) {
    final List<dynamic> messagesJson =
        (json['messages'] as List<dynamic>?) ?? const [];

    final dynamic unread = json['unreadCount'];

    return EmployeeConversation(
      id: (json['id'] ?? '').toString(),
      contactId: json['contactId']?.toString(),
      contactName: (json['contactName'] ?? '').toString(),
      contactRole: (json['contactRole'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      messages: messagesJson
          .map((e) => EmployeeMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? EmployeeMessage.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            )
          : null,
      isGroup: json['group'] == true,
      groupName: json['groupName']?.toString(),
      memberCount: int.tryParse((json['memberCount'] ?? 0).toString()) ?? 0,
      unreadCount:
          unread is int ? unread : int.tryParse(unread?.toString() ?? '0') ?? 0,
    );
  }

  EmployeeConversation copyWith({
    String? id,
    String? contactId,
    String? contactName,
    String? contactRole,
    String? avatarUrl,
    List<EmployeeMessage>? messages,
    EmployeeMessage? lastMessage,
    bool? isGroup,
    String? groupName,
    int? memberCount,
    int? unreadCount,
  }) {
    return EmployeeConversation(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      contactRole: contactRole ?? this.contactRole,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messages: messages ?? this.messages,
      lastMessage: lastMessage ?? this.lastMessage,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      memberCount: memberCount ?? this.memberCount,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  String get displayTitle {
    if (isGroup) {
      return (groupName != null && groupName!.trim().isNotEmpty)
          ? groupName!
          : contactName;
    }
    return contactName;
  }

  String get displaySubtitle {
    if (isGroup) {
      return '$memberCount membres';
    }
    return contactRole;
  }
}

class MessageableUser {
  final String id;
  final String fullName;
  final String role;
  final String email;
  final String? avatarUrl;

  MessageableUser({
    required this.id,
    required this.fullName,
    required this.role,
    required this.email,
    this.avatarUrl,
  });

  factory MessageableUser.fromJson(Map<String, dynamic> json) {
    final email = (json['email'] ?? '').toString().trim();
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();
    final fullNameCandidates = <String>[
      (json['fullName'] ?? '').toString().trim(),
      (json['name'] ?? '').toString().trim(),
      '$firstName $lastName'.trim(),
      email.contains('@') ? email.split('@').first : email,
      'Utilisateur',
    ];

    return MessageableUser(
      id: (json['id'] ?? '').toString(),
      fullName: fullNameCandidates.firstWhere((value) => value.isNotEmpty),
      role: (json['role'] ?? '').toString(),
      email: email,
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

class TimesheetEntry {
  final String id;
  final String date;
  final String projectName;
  final String taskName;
  final String startTime;
  final String endTime;
  final double pauseHours;
  final double workedHours;
  final String status;

  TimesheetEntry({
    required this.id,
    required this.date,
    required this.projectName,
    required this.taskName,
    required this.startTime,
    required this.endTime,
    required this.pauseHours,
    required this.workedHours,
    required this.status,
  });
}

/// ===============================
/// ⏱️ ATTENDANCE (PRO)
/// ===============================

enum AttendanceStatus {
  notStarted,
  working,
  onBreak,
  incomplete,
  pendingValidation,
}

class AttendanceCardData {
  final AttendanceStatus status;

  final String todayWorked;
  final String weekWorked;

  final String? lastEventLabel;
  final String? anomalyMessage;

  final String primaryActionLabel;
  final dynamic primaryActionIcon;

  final bool canSelectLine;

  AttendanceCardData({
    required this.status,
    required this.todayWorked,
    required this.weekWorked,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    this.lastEventLabel,
    this.anomalyMessage,
    this.canSelectLine = true,
  });
}
