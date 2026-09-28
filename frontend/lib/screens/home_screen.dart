import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/packaging_model.dart';
import '../services/api_service.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: "Eco Ceramic Mug");
  final _lengthCtrl = TextEditingController(text: "12");
  final _widthCtrl = TextEditingController(text: "10");
  final _heightCtrl = TextEditingController(text: "15");
  final _weightCtrl = TextEditingController(text: "0.45");

  bool _isFragile = true;
  bool _ecoFriendly = true;
  bool _isLoading = false;
  PackagingRecommendationResult? _result;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final input = PackagingInput(
        itemName: _nameCtrl.text.trim(),
        length: double.parse(_lengthCtrl.text),
        width: double.parse(_widthCtrl.text),
        height: double.parse(_heightCtrl.text),
        weight: double.parse(_weightCtrl.text),
        isFragile: _isFragile,
        ecoFriendly: _ecoFriendly,
      );

      final result = await ApiService.getRecommendation(input);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Packaging Recommender"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: "Recommendation History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputCard(theme),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: SpinKitThreeBounce(
                        color: Colors.teal,
                        size: 36.0,
                      ),
                    ),
                  ),
                if (_errorMessage != null) _buildErrorCard(),
                if (_result != null && !_isLoading) _buildResultCard(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text("Item Specifications", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lengthCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Length (cm)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => double.tryParse(v ?? '') == null ? "Valid number" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _widthCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Width (cm)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => double.tryParse(v ?? '') == null ? "Valid number" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Height (cm)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => double.tryParse(v ?? '') == null ? "Valid number" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  prefixIcon: Icon(Icons.scale_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => double.tryParse(v ?? '') == null ? "Valid number" : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Fragile Item"),
                subtitle: const Text("Adds extra cushioning buffers for safety"),
                value: _isFragile,
                onChanged: (val) => setState(() => _isFragile = val ?? false),
              ),
              SwitchListTile(
                title: const Text("Eco-Friendly Packaging"),
                subtitle: const Text("Prioritizes biodegradable and honeycomb kraft materials"),
                value: _ecoFriendly,
                onChanged: (val) => setState(() => _ecoFriendly = val ?? true),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Recommend Best Packaging"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Error connecting to backend: $_errorMessage\nEnsure FastAPI server is running on http://127.0.0.1:8000.",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final res = _result!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("AI Recommendation", style: theme.textTheme.titleLarge?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: Text(
                    "Score: ${res.sustainabilityScore.toInt()}/100",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                )
              ],
            ),
            const Divider(height: 24),
            _infoRow(Icons.all_inbox_rounded, "Box Type", res.recommendedBoxType),
            _infoRow(Icons.straighten_rounded, "Box Dimensions", res.recommendedDimensions),
            _infoRow(Icons.layers_outlined, "Cushioning", res.cushioningMaterial),
            _infoRow(Icons.attach_money_rounded, "Estimated Packaging Cost", "\$${res.estimatedCost.toStringAsFixed(2)}"),
            _infoRow(Icons.pie_chart_outline_rounded, "Space Efficiency", "${res.spaceUtilizationPct}% utilized"),
            if (res.notes != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  res.notes!,
                  style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
