class CommodityCategorySummary {
  final String category;
  final String description;
  final List<String> sampleItems;
  final int count;

  CommodityCategorySummary({
    required this.category,
    required this.description,
    required this.sampleItems,
    required this.count,
  });

  factory CommodityCategorySummary.fromJson(Map<String, dynamic> json) {
    return CommodityCategorySummary(
      category: json['category'] ?? 'General Food',
      description: json['description'] ?? '',
      sampleItems: (json['sample_items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'description': description,
        'sample_items': sampleItems,
        'count': count,
      };
}

class CommoditySummaryResult {
  final String source;
  final int totalFoods;
  final int totalMaterials;
  final List<CommodityCategorySummary> categories;

  CommoditySummaryResult({
    required this.source,
    required this.totalFoods,
    required this.totalMaterials,
    required this.categories,
  });

  factory CommoditySummaryResult.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'] as List<dynamic>? ?? [];
    return CommoditySummaryResult(
      source: json['source'] ?? 'fallback',
      totalFoods: (json['total_foods'] as num?)?.toInt() ?? 0,
      totalMaterials: (json['total_materials'] as num?)?.toInt() ?? 7,
      categories: rawCats
          .map((c) => CommodityCategorySummary.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
