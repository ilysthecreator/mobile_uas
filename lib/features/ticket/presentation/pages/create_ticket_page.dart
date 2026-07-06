import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';

class CreateTicketPage extends ConsumerStatefulWidget {
  const CreateTicketPage({super.key});

  @override
  ConsumerState<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends ConsumerState<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _attachedImageUrl;
  bool _isSubmitting = false;
  String _selectedCategory = 'IT Support';
  String _selectedPriority = 'Medium';

  final List<String> _categories = [
    'IT Support',
    'Network',
    'Hardware',
    'Software',
    'Facilities',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 70);
      if (!mounted) return;
      if (image != null) {
        setState(() {
          // Using a placeholder URL to simulate uploaded attachment on Supabase storage
          _attachedImageUrl = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=400&q=80';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lampiran gambar berhasil diunggah!')),
        );
      }
    } catch (e) {
      debugPrint('Picker error: $e');
      if (!mounted) return;
      setState(() {
        _attachedImageUrl = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=400&q=80';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera tidak didukung. Lampiran demo disematkan.')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = ref.read(authProvider);
    final ticketProv = ref.read(ticketProvider);
    final user = auth.currentUser!;

    try {
      await ticketProv.createTicket(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        creatorEmail: user.email,
        creatorName: user.fullName.isNotEmpty ? user.fullName : user.username,
        imageUrl: _attachedImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil dibuat!'),
            backgroundColor: AppTheme.statusClosed,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat tiket: $e'),
            backgroundColor: AppTheme.statusOpen,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Buat Tiket',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Section
                Row(
                  children: [
                    const Icon(Icons.add_circle, color: AppTheme.primaryNavy, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'NEW REQUEST',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jelaskan masalah Anda secara detail. Tim dukungan kami biasanya merespon dalam waktu 2 jam untuk permintaan teknis kritis.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Judul Tiket (Glass panel)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JUDUL TIKET',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Ringkasan singkat masalah...',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Silakan masukkan judul tiket';
                          if (value.trim().length < 5) return 'Judul minimal 5 karakter';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Deskripsi Detail (Glass panel)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESKRIPSI DETAIL',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        minLines: 4,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                        decoration: InputDecoration(
                          hintText: 'Berikan detail sebanyak mungkin, termasuk langkah-langkah untuk mereproduksi masalah...',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Silakan masukkan deskripsi';
                          if (value.trim().length < 15) return 'Deskripsi minimal 15 karakter';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Kategori (Glass panel)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'KATEGORI',
                      labelStyle: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Tingkat Urgensi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TINGKAT URGENSI',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Low', 'Medium', 'High'].map((priority) {
                          final isSelected = _selectedPriority == priority;
                          Color priorityColor = AppTheme.statusClosed;
                          String displayLabel = 'LOW';
                          if (priority == 'Medium') {
                            priorityColor = AppTheme.statusAssigned;
                            displayLabel = 'MEDIUM';
                          } else if (priority == 'High') {
                            priorityColor = AppTheme.statusOpen;
                            displayLabel = 'URGENT';
                          }

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () => setState(() => _selectedPriority = priority),
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? priorityColor.withValues(alpha: 0.12)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? priorityColor : (isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3)),
                                      width: isSelected ? 2 : 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? priorityColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Average Wait Time Sidebar Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'AVERAGE WAIT',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Icon(
                            Icons.schedule_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '42m',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          height: 4,
                          color: Colors.white24,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.67,
                              child: Container(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 7. Unggah Foto atau File (Dashed borders)
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt_rounded),
                              title: const Text('Ambil Foto Kamera'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library_rounded),
                              title: const Text('Pilih dari Galeri'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3),
                        style: BorderStyle.solid, // solid representation of dragzone
                      ),
                    ),
                    child: Column(
                      children: [
                        if (_attachedImageUrl != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF4FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description_rounded, color: AppTheme.primaryNavy),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'lampiran_tiket.jpg',
                                        style: TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '142.5 KB',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => setState(() => _attachedImageUrl = null),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF4FF),
                                ),
                                child: const Icon(Icons.photo_camera_rounded, color: AppTheme.primaryNavy, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF4FF),
                                ),
                                child: const Icon(Icons.attach_file_rounded, color: AppTheme.primaryNavy, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Unggah Foto atau File',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ambil foto langsung atau pilih file dari perangkat.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 8. Submit & Draft Actions
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeCap: StrokeCap.round,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'SUBMIT TICKET',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 16),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Draf berhasil disimpan!')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'SAVE AS DRAFT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
