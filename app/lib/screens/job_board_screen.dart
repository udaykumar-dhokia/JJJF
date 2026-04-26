import 'package:app/constants/color.dart';
import 'package:app/models/job_model.dart';
import 'package:app/provider/job_provider.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/widgets/location_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  String _selectedType = 'all'; // all, vacancy, seeker

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          "Job Board",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateJobSheet(context),
        backgroundColor: AppColors.primary,
        label: Text('Post Job', style: GoogleFonts.mulish(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.jobs.isEmpty) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final filtered = provider.jobs.where((job) {
            if (_selectedType == 'all') return true;
            return job.type == _selectedType;
          }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildTypeChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildTypeChip('Vacancy Available', 'vacancy'),
                    const SizedBox(width: 8),
                    _buildTypeChip('Job Required', 'seeker'),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<JobProvider>().fetchJobs(forceRefresh: true),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                            Center(
                              child: Text(
                                'No jobs found yet',
                                style: GoogleFonts.mulish(color: Colors.grey),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _JobCard(job: filtered[index]);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.mulish(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateJobSheet(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String type = 'vacancy';
    final titleController = TextEditingController();
    final roleController = TextEditingController();
    final descriptionController = TextEditingController();
    final contactNameController = TextEditingController();
    final contactPhoneController = TextEditingController();
    final contactEmailController = TextEditingController();
    final linkController = TextEditingController();

    // CSC picker values stored locally
    String stateValue = '';
    String cityValue = '';
    bool isSubmitting = false;

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.mulish(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      );
    }

    Widget buildTypeButton(
      String title,
      String value,
      StateSetter setModalState,
    ) {
      final isSelected = type == value;
      return Expanded(
        child: InkWell(
          onTap: () {
            setModalState(() {
              type = value;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: GoogleFonts.mulish(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
                top: 12,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create Job Post',
                            style: GoogleFonts.mulish(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1D1E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          buildTypeButton(
                            'Vacancy Available',
                            'vacancy',
                            setModalState,
                          ),
                          const SizedBox(width: 12),
                          buildTypeButton(
                            'Job Required',
                            'seeker',
                            setModalState,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: inputDecoration('Job Title*'),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: roleController,
                        decoration: inputDecoration('Role / Position*'),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      IndiaLocationPicker(
                        selectedState: stateValue,
                        selectedCity: cityValue,
                        stateDropdownLabel: "State",
                        cityDropdownLabel: "City",
                        onStateChanged: (state) {
                          setModalState(() {
                            stateValue = state ?? '';
                            cityValue = '';
                          });
                        },
                        onCityChanged: (city) {
                          setModalState(() {
                            cityValue = city ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: inputDecoration(
                          'Description*',
                        ).copyWith(alignLabelWithHint: true),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Contact Details',
                        style: GoogleFonts.mulish(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1D1E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contactNameController,
                        decoration: inputDecoration('Contact Name*'),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contactPhoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: inputDecoration(
                          'Contact Phone*',
                        ).copyWith(counterText: ""),
                        validator: (v) => (v == null || v.length != 10)
                            ? 'Enter valid 10-digit number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contactEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: inputDecoration('Contact Email (optional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: linkController,
                        keyboardType: TextInputType.url,
                        decoration: inputDecoration(
                          type == 'vacancy'
                              ? 'Apply Link (optional)'
                              : 'Resume Link (optional)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;

                                  if (stateValue.isEmpty ||
                                      stateValue == 'State') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select a state'),
                                      ),
                                    );
                                    return;
                                  }
                                  if (cityValue.isEmpty ||
                                      cityValue == 'City') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select a city'),
                                      ),
                                    );
                                    return;
                                  }

                                  final user = context
                                      .read<UserProvider>()
                                      .user;
                                  if (user == null) return;

                                  setModalState(() {
                                    isSubmitting = true;
                                  });

                                  final jobProvider = context
                                      .read<JobProvider>();
                                  final success = await jobProvider.createJob(
                                    userId: user.uuid,
                                    title: titleController.text.trim(),
                                    description: descriptionController.text
                                        .trim(),
                                    type: type,
                                    role: roleController.text.trim(),
                                    city: cityValue,
                                    state: stateValue,
                                    contactName: contactNameController.text
                                        .trim(),
                                    contactPhone: contactPhoneController.text
                                        .trim(),
                                    contactEmail:
                                        contactEmailController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : contactEmailController.text.trim(),
                                    link: linkController.text.trim().isEmpty
                                        ? null
                                        : linkController.text.trim(),
                                  );

                                  setModalState(() {
                                    isSubmitting = false;
                                  });

                                  if (success && context.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Job post submitted for approval',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CupertinoActivityIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit Job Post',
                                  style: GoogleFonts.mulish(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobData job;

  const _JobCard({required this.job});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVacancy = job.type == 'vacancy';
    final accentColor = isVacancy ? AppColors.primary : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left gradient strip
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.6), accentColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: GoogleFonts.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1D1E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.role,
                                  style: GoogleFonts.mulish(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isVacancy ? 'Vacancy' : 'Job Required',
                              style: GoogleFonts.mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        job.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.mulish(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Location & Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${job.city}, ${job.state}',
                                style: GoogleFonts.mulish(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeago.format(job.createdAt),
                                style: GoogleFonts.mulish(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      // Contact Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primaryLight
                                      .withOpacity(0.15),
                                  child: Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    job.contactName,
                                    style: GoogleFonts.mulish(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (job.link != null && job.link!.isNotEmpty) ...[
                                IconButton(
                                  onPressed: () => _launchUrl(job.link!),
                                  icon: const Icon(Icons.link),
                                  color: Colors.purple,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.purple.withValues(
                                      alpha: 0.1,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              IconButton(
                                onPressed: () =>
                                    _launchUrl('tel:${job.contactPhone}'),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCall,
                                ),
                                color: AppColors.primary,
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _launchUrl(
                                  'https://wa.me/91${job.contactPhone}?text=Hi, I am contacting you regarding your job post: ${job.title}',
                                ),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedWhatsapp,
                                ),
                                color: AppColors.primaryLight,
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
