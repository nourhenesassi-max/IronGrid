import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/expense_repository.dart';
import '../../data/models/expense_model.dart';

class EmployeScanFraisScreen extends StatefulWidget {
  const EmployeScanFraisScreen({super.key});

  @override
  State<EmployeScanFraisScreen> createState() => _EmployeScanFraisScreenState();
}

class _EmployeScanFraisScreenState extends State<EmployeScanFraisScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _category = "Transport";
  DateTime _date = DateTime.now();
  bool _loading = false;

  File? _image;

  final _categories = const [
    "Transport",
    "Repas",
    "Hôtel",
    "Fournitures",
    "Autre",
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (xfile == null) return;

      setState(() => _image = File(xfile.path));
    } catch (e) {
      _snack("Erreur caméra: $e");
    }
  }

  Future<void> _saveTempAndGoList() async {
    if (_image == null) {
      _snack("Veuillez prendre une photo du reçu.");
      return;
    }

    final amount =
        double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _snack("Montant invalide.");
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 250)); // simulate

    // ✅ SAVE TEMP IN MEMORY
    ExpenseRepository().add(
      Expense(
        category: _category,
        amount: amount,
        date: _date,
        note: _noteCtrl.text.trim(),
        imagePath: _image!.path,
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    // ✅ Replace so list shows directly and back doesn't return to half-filled form
    Navigator.pushReplacementNamed(context, "/employe-frais");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Scanner un Reçu"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Photo du reçu",
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: InkWell(
                    onTap: _takePhoto,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.textMuted.withOpacity(0.15),
                        ),
                      ),
                      child: _image == null
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      size: 28, color: AppColors.primary),
                                  SizedBox(height: 10),
                                  Text("Appuyez pour prendre une photo",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Détails",
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                _label("Catégorie"),
                _dropdown(),
                const SizedBox(height: 10),
                _label("Montant (TND)"),
                _input(_amountCtrl, "Ex: 25.50", TextInputType.number),
                const SizedBox(height: 10),
                _label("Date"),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.textMuted.withOpacity(0.15)),
                        ),
                        child: Text(
                          "${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.date_range),
                      label: const Text("Choisir"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _label("Note (optionnel)"),
                _input(_noteCtrl, "Ex: Taxi vers site", TextInputType.text),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _saveTempAndGoList,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _loading ? "Enregistrement..." : "Enregistrer",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: child,
      );

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          s,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _dropdown() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _category,
            isExpanded: true,
            items: _categories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
        ),
      );

  Widget _input(TextEditingController c, String hint, TextInputType type) =>
      TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.bg,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
