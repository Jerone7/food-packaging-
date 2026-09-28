import 'package:flutter/material.dart';
import '../../../models/packaging_comparison_model.dart';
import '../../../models/material_catalog_model.dart';
import '../../../services/api_service.dart';

/// Modal dialog or bottom sheet for searching and assigning a packaging material to a comparison slot.
class QuickMaterialPickerModal extends StatefulWidget {
  final ComparisonSlotId targetSlot;
  final List<String> currentlySelectedMaterialIds;
  final Function(PackagingMaterialDetail selectedMaterial) onMaterialSelected;

  const QuickMaterialPickerModal({
    super.key,
    required this.targetSlot,
    required this.currentlySelectedMaterialIds,
    required this.onMaterialSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required ComparisonSlotId targetSlot,
    required List<String> currentlySelectedMaterialIds,
    required Function(PackagingMaterialDetail selectedMaterial) onMaterialSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickMaterialPickerModal(
        targetSlot: targetSlot,
        currentlySelectedMaterialIds: currentlySelectedMaterialIds,
        onMaterialSelected: onMaterialSelected,
      ),
    );
  }

  @override
  State<QuickMaterialPickerModal> createState() => _QuickMaterialPickerModalState();
}

class _QuickMaterialPickerModalState extends State<QuickMaterialPickerModal> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late List<PackagingMaterialDetail> _allMaterials;

  @override
  void initState() {
    super.initState();
    _allMaterials = ApiService.defaultMaterials;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.targetSlot.accentColor;

    // Filter categories
    final categories = ['All', ..._allMaterials.map((m) => m.category).toSet()];

    // Filter materials
    final filtered = _allMaterials.where((mat) {
      final matchesQuery = _searchQuery.isEmpty ||
          mat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mat.polymerFamily.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mat.structure.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mat.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCat = _selectedCategory == 'All' || mat.category == _selectedCategory;

      return matchesQuery && matchesCat;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Assign to ${widget.targetSlot.label}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search by polymer name, barrier, or category...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          const SizedBox(height: 10),

          // Category filter strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel
                            ? Colors.white
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                      ),
                    ),
                    selected: isSel,
                    selectedColor: accentColor,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSel
                          ? accentColor
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Material list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No packaging materials match your criteria.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final mat = filtered[idx];
                      final isCurrentlyPicked =
                          widget.currentlySelectedMaterialIds.contains(mat.materialId);

                      return _buildMaterialItemTile(
                        context,
                        mat,
                        isDark,
                        accentColor,
                        isCurrentlyPicked,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItemTile(
    BuildContext context,
    PackagingMaterialDetail mat,
    bool isDark,
    Color accentColor,
    bool isCurrentlyPicked,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentlyPicked
              ? accentColor.withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isCurrentlyPicked ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                mat.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (isCurrentlyPicked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Already In Slot',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${mat.category} • ${mat.polymerFamily}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _specBadge(
                  'OTR: ${mat.barrierProfile.otrCcM2Day} cc/m²',
                  isDark,
                ),
                _specBadge(
                  'WVTR: ${mat.barrierProfile.wvtrGM2Day} g/m²',
                  isDark,
                ),
                _specBadge(
                  '₹${mat.economicProfile.estimatedUnitCostInr.toStringAsFixed(2)}',
                  isDark,
                  isHighlight: true,
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            widget.onMaterialSelected(mat);
            Navigator.of(context).pop();
          },
          child: const Text(
            'Select',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _specBadge(String text, bool isDark, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlight
            ? (isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE))
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2F6)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          color: isHighlight
              ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
        ),
      ),
    );
  }
}
