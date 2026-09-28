/// Recommendation Report Generation & Offline Synthesis Service (Module 12).
/// Assembles comprehensive packaging specification reports from active recommendation state
/// with seamless automatic fallback to embedded offline calculation engines.
library;

import '../models/recommendation_report_model.dart';
import '../models/packaging_model.dart';
import '../models/sustainability_model.dart';
import '../models/cost_estimation_model.dart';
import 'offline_sustainability_engine.dart';
import 'offline_cost_engine.dart';

class ReportGeneratorService {
  /// Synthesizes a complete RecommendationReportModel from recommendation state.
  /// Automatically resolves missing LCA or Cost profiles via offline parity engines.
  static RecommendationReportModel synthesizeReport({
    required PackagingRecommendationResult result,
    required PackagingInput input,
    SustainabilityProfile? sustainabilityProfile,
    CostEstimationResponse? costResponse,
    int batchSize = 10000,
    double pcrPercentage = 0.0,
    String? customReportId,
  }) {
    // 1. Resolve SustainabilityProfile via OfflineSustainabilityEngine if not provided
    var resolvedLca = sustainabilityProfile;
    if (resolvedLca == null) {
      final lcaInput = SustainabilityEvaluateInput(
        materialId: result.primaryRecommendation.polymerFamily.toLowerCase(),
        materialName: result.primaryRecommendation.materialName,
        packageType: result.primaryRecommendation.packagingFormat,
        lengthCm: input.length,
        widthCm: input.width,
        depthOrGussetCm: input.height,
        thicknessMicrons: result.primaryRecommendation.barrierProfile.thicknessMicrons,
        batchSizeUnits: batchSize,
        pcrPercentage: pcrPercentage,
      );
      resolvedLca = OfflineSustainabilityEngine.evaluate(lcaInput);
    }

    // 2. Resolve CostEstimationResponse via OfflineCostEngine if not provided
    var resolvedCost = costResponse;
    if (resolvedCost == null) {
      final costReq = CostEstimationRequest(
        materialName: result.primaryRecommendation.materialName,
        packagingType: PackagingFormFactor.fromString(result.primaryRecommendation.packagingFormat),
        dimensions: PackageDimensions(
          lengthCm: input.length,
          widthCm: input.width,
          depthOrGussetCm: input.height,
          thicknessMicrons: result.primaryRecommendation.barrierProfile.thicknessMicrons,
        ),
        productFillQuantity: '${input.weight.toStringAsFixed(0)}g',
        numberOfPackages: batchSize,
      );
      resolvedCost = OfflineCostEngine.calculateCostEstimate(costReq);
    }

    // 3. Assemble and return full RecommendationReportModel
    return RecommendationReportModel.fromRecommendationResult(
      result: result,
      input: input,
      sustainabilityProfile: resolvedLca,
      costResponse: resolvedCost,
      batchSize: batchSize,
      pcrPercentage: pcrPercentage,
      customReportId: customReportId,
    );
  }

  /// Generates Markdown specification document from report model.
  static String generateMarkdown(RecommendationReportModel report) {
    return report.toMarkdownString();
  }
}
