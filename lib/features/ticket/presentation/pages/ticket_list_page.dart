import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'ticket_detail_page.dart';
import 'create_ticket_page.dart';
import 'package:project_mobile/core/theme/app_theme.dart';

class TicketListPage extends ConsumerStatefulWidget {
  final bool isTab;

  const TicketListPage({super.key, this.isTab = false});

  @override
  ConsumerState<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends ConsumerState<TicketListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _statuses = ['All', 'Open', 'Assigned', 'In Progress', 'Closed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Re-build when changing tabs to filter list
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProviderVal = ref.watch(authProvider);
    final ticketProviderVal = ref.watch(ticketProvider);
    final user = authProviderVal.currentUser!;

    // Fetch and filter list
    final baseTickets = ticketProviderVal.getTicketsForRole(user.role, user.email);

    // Apply search filter
    var filteredTickets = baseTickets.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'All' || t.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    // Group categories list
    final List<String> categories = ['All', 'IT Support', 'Network', 'Hardware', 'Software', 'Facilities'];

    // Render list for current status tab
    Widget buildListForStatus(String status) {
      final statusTickets = filteredTickets.where((t) {
        return status == 'All' || t.status == status;
      }).toList();

      if (statusTickets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No tickets found in "$status"',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Try resetting your search or filters.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 800)),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: statusTickets.length,
          itemBuilder: (context, index) {
            final ticket = statusTickets[index];
            return _buildTicketListItem(ticket, context, isDark);
          },
        ),
      );
    }

    final scaffoldContent = Column(
      children: [
        // Top Search Bar & Filters
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
            ),
          ),
          child: Column(
            children: [
              // Search Input
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search ticket ID, title, description...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal Category Chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;

                    return FilterChip(
                      selected: isSelected,
                      label: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Custom Tab Bar
        Container(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: _statuses.map((status) {
              final count = baseTickets.where((t) {
                return status == 'All' || t.status == status;
              }).length;
              
              return Tab(
                child: Row(
                  children: [
                    Text(status),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tabController.index == _statuses.indexOf(status)
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Tab View showing lists
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _statuses.map((status) => buildListForStatus(status)).toList(),
          ),
        ),
      ],
    );

    if (widget.isTab) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Tickets'),
          automaticallyImplyLeading: false,
          actions: user.role == 'User'
              ? [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ]
              : null,
        ),
        body: scaffoldContent,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tickets Archive'),
        ),
        body: scaffoldContent,
        floatingActionButton: user.role == 'User'
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
      );
    }
  }

  Widget _buildTicketListItem(dynamic ticket, BuildContext context, bool isDark) {
    Color statusColor;
    switch (ticket.status) {
      case 'Open':
        statusColor = AppTheme.statusOpen;
        break;
      case 'In Progress':
        statusColor = AppTheme.statusInProgress;
        break;
      case 'Resolved':
        statusColor = AppTheme.statusResolved;
        break;
      default:
        statusColor = AppTheme.statusClosed;
    }

    Color priorityColor;
    switch (ticket.priority) {
      case 'Low':
        priorityColor = AppTheme.priorityLow;
        break;
      case 'Medium':
        priorityColor = AppTheme.priorityMedium;
        break;
      default:
        priorityColor = AppTheme.priorityHigh;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TicketDetailPage(ticketId: ticket.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.id,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Priority Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: priorityColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.priority,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        ticket.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  ticket.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description snippet
                Text(
                  ticket.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 10),

                // Footer Metadata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          ticket.category,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.person_pin_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          ticket.assignedToName ?? 'Unassigned',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(ticket.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}';
  }
}
