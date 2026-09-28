/// Report Header Card Widget (Module 12: Recommendation Report).
/// Renders modern emerald branding header, report ID badge, timestamp,
/// commodity title, and cryptographic verification hash pill.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/recommendation_report_model.dart';
import '../../../services/report_export_service.dart';

class ReportHeaderCard extends StatelessWidget {
  final RecommendationReportModel report;

  const ReportHeaderCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final fc = report.foodContext;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Metadata & Badges Row
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Report ID Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.description_outlined, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        report.reportId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Date/Time Stamp
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF99F6E4)),
                  const SizedBox(width: 5),
                  Text(
                    '${DateFormat('yyyy-MM-dd HH:mm').format(report.generatedAt)} UTC',
                    style: const TextStyle(
                      color: Color(0xFFCCFBF1),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Commodity Title & Category
          Text(
            fc.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  fc.category,
                  style: const TextStyle(
                    color: Color(0xFFA7F3D0),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (fc.scientificName != null)
                Text(
                  fc.scientificName!,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF134E4A), height: 1),
          const SizedBox(height: 14),

          // Operational Quick Stats Bar
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildStatItem('Fill Quantity', fc.fillQuantity, Icons.inventory_2_outlined),
              _buildStatItem('Batch Volume', '${NumberFormat('#,###').format(fc.batchSizeUnits)} units', Icons.layers_outlined),
              _buildStatItem('Shelf Life', '${fc.storageDurationDays} days', Icons.calendar_today_rounded),
              _buildStatItem('Storage Regimen', fc.storageCondition, Icons.thermostat_rounded),
            ],
          ),

          const SizedBox(height: 14),

          // SHA-256 Provenance Verification Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF34D399)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SHA-256 Verified: ${report.verificationHash.length >= 16 ? report.verificationHash.substring(0, 16) : report.verificationHash}... • ${report.engineVersion}',
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 10.5,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                  tooltip: 'Copy Verification Link',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => ReportExportService.copyShareUrl(context, report),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF5EEAD4)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF99F6E4), fontSize: 9.5),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
