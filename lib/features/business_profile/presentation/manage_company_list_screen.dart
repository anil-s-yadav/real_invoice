import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/business_profile_repository.dart';
import '../domain/business_profile_model.dart';
import 'business_profile_screen.dart';

class ManageCompanyListScreen extends StatefulWidget {
  const ManageCompanyListScreen({super.key});

  @override
  State<ManageCompanyListScreen> createState() => _ManageCompanyListScreenState();
}

class _ManageCompanyListScreenState extends State<ManageCompanyListScreen> {
  late final BusinessProfileRepository _repository;
  List<BusinessProfile> _profiles = [];
  bool _isLoading = true;
  String _activeId = '';

  @override
  void initState() {
    super.initState();
    _repository = context.read<BusinessProfileRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profiles = await _repository.getAllProfiles();
    final activeId = await _repository.getActiveProfileId();
    setState(() {
      _profiles = profiles;
      _activeId = activeId;
      _isLoading = false;
    });
  }

  Future<void> _setActive(String id) async {
    await _repository.setActiveProfileId(id);
    _loadData();
    // Dispatch events to reload global states if needed, wait for user if they want this.
  }

  Future<void> _delete(BusinessProfile profile) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Company',
      message: 'Are you sure you want to delete ${profile.businessName}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirm) {
      await _repository.deleteProfile(profile.id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Companies', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.canvas,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                final isActive = profile.id == _activeId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.border,
                        backgroundImage: profile.logoPath != null && profile.logoPath!.isNotEmpty
                            ? FileImage(File(profile.logoPath!))
                            : null,
                        child: profile.logoPath == null || profile.logoPath!.isEmpty
                            ? const Icon(Icons.storefront, color: AppColors.textSecondary)
                            : null,
                      ),
                      title: Text(
                        profile.businessName.isEmpty ? 'Unnamed Company' : profile.businessName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isActive ? 'Active Company' : 'Tap to set active',
                        style: TextStyle(
                          color: isActive ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isActive)
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                              onPressed: () => _setActive(profile.id),
                              tooltip: 'Set as Active',
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BusinessProfileScreen(profileId: profile.id),
                                ),
                              );
                              _loadData();
                            },
                          ),
                          if (!isActive)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.statusOverdueText),
                              onPressed: () => _delete(profile),
                            ),
                        ],
                      ),
                      onTap: () {
                         if (!isActive) _setActive(profile.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BusinessProfileScreen(profileId: ''),
            ),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Company'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
