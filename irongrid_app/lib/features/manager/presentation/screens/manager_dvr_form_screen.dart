import 'package:flutter/material.dart';

import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_surveillance_model.dart';
import '../../data/services/manager_surveillance_store.dart';

class ManagerDvrFormScreen extends StatefulWidget {
  final ManagerDvr? initialDvr;

  const ManagerDvrFormScreen({
    super.key,
    this.initialDvr,
  });

  bool get isEditing => initialDvr != null;

  @override
  State<ManagerDvrFormScreen> createState() => _ManagerDvrFormScreenState();
}

class _ManagerDvrFormScreenState extends State<ManagerDvrFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _siteController;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _cameraCountController;
  late final TextEditingController _notesController;

  late String _status;
  late String _protocol;
  late String _streamProfile;

  static const List<String> _statuses = <String>[
    'online',
    'degraded',
    'offline',
  ];
  static const List<String> _protocols = <String>[
    'RTSP',
    'ONVIF',
    'HTTP',
  ];
  static const List<String> _profiles = <String>[
    'HD',
    'Full HD',
    '4K',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDvr;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _siteController = TextEditingController(text: initial?.site ?? '');
    _ipController = TextEditingController(text: initial?.ipAddress ?? '');
    _portController =
        TextEditingController(text: (initial?.port ?? 554).toString());
    _cameraCountController = TextEditingController(
      text: (initial?.totalCameras ?? 4).toString(),
    );
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _status = initial?.status ?? _statuses.first;
    _protocol = initial?.protocol ?? _protocols.first;
    _streamProfile = initial?.streamProfile ?? 'Full HD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _siteController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _cameraCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final initial = widget.initialDvr;
    final dvr = ManagerSurveillanceStore.composeDvr(
      id: initial?.id,
      name: _nameController.text,
      site: _siteController.text,
      ipAddress: _ipController.text,
      port: int.tryParse(_portController.text.trim()) ?? 554,
      status: _status,
      protocol: _protocol,
      streamProfile: _streamProfile,
      cameraCount: int.tryParse(_cameraCountController.text.trim()) ?? 4,
      notes: _notesController.text,
      existingCameras: initial?.cameras ?? const <ManagerCameraFeed>[],
    );

    Navigator.pop(context, dvr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isEditing ? 'Modifier le DVR' : 'Ajouter un DVR',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionCard(
                  title: 'Identite du DVR',
                  subtitle: 'Renseigne les informations reseau et le site surveille.',
                  children: <Widget>[
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nom du DVR',
                      hint: 'DVR Ligne Nord',
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _siteController,
                      label: 'Site',
                      hint: 'Usine Centrale - Bloc A',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _ipController,
                            label: 'Adresse IP',
                            hint: '192.168.10.15',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _portController,
                            label: 'Port',
                            hint: '554',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Configuration video',
                  subtitle:
                      'Le nombre de cameras genere automatiquement les canaux et les flux.',
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Etat du DVR',
                            value: _status,
                            items: _statuses,
                            itemLabelBuilder: _statusLabel,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _status = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Protocole',
                            value: _protocol,
                            items: _protocols,
                            itemLabelBuilder: (value) => value,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _protocol = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Profil streaming',
                            value: _streamProfile,
                            items: _profiles,
                            itemLabelBuilder: (value) => value,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _streamProfile = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _cameraCountController,
                            label: 'Nombre de cameras',
                            hint: '4',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Notes de supervision',
                  subtitle:
                      'Ces informations sont visibles dans IronGrid et dans la supervision dediee.',
                  children: <Widget>[
                    _buildTextField(
                      controller: _notesController,
                      label: 'Observations',
                      hint: 'Maintenance prevue, acces reserve, flux prioritaire...',
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    widget.isEditing
                        ? 'Les modifications seront enregistrees dans la base de donnees puis visibles automatiquement dans IronGrid Surveillance.'
                        : 'Le nouveau DVR sera enregistre dans la base de donnees et remontera automatiquement dans l application IronGrid Surveillance.',
                    style: TextStyle(
                      color: AppColors.textDark.withValues(alpha: 0.78),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.save_outlined),
          label: Text(
            widget.isEditing
                ? 'Enregistrer les modifications'
                : 'Creer le DVR',
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      validator: (value) {
        final input = value?.trim() ?? '';
        if (input.isEmpty) {
          return 'Champ obligatoire';
        }

        if (label == 'Port') {
          final port = int.tryParse(input);
          if (port == null || port < 1 || port > 65535) {
            return 'Port invalide';
          }
        }

        if (label == 'Nombre de cameras') {
          final count = int.tryParse(input);
          if (count == null || count < 1 || count > 32) {
            return 'Choisis une valeur entre 1 et 32';
          }
        }

        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required String Function(String value) itemLabelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(itemLabelBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'online':
        return 'Operationnel';
      case 'degraded':
        return 'Degrade';
      case 'offline':
        return 'Hors ligne';
      default:
        return status;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.94),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
