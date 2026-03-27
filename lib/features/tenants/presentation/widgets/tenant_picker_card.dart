import 'package:flutter/material.dart';

import '../../../../core/models/fluxa_models.dart';

class TenantPickerCard extends StatefulWidget {
  const TenantPickerCard({
    required this.activeTenantId,
    required this.isBusy,
    required this.onSwitch,
    required this.tenants,
    super.key,
  });

  final String activeTenantId;
  final bool isBusy;
  final Future<void> Function(String tenantId) onSwitch;
  final List<FluxaTenantMembership> tenants;

  @override
  State<TenantPickerCard> createState() => _TenantPickerCardState();
}

class _TenantPickerCardState extends State<TenantPickerCard> {
  late String _selectedTenantId;

  @override
  void initState() {
    super.initState();
    _selectedTenantId = widget.activeTenantId;
  }

  @override
  void didUpdateWidget(covariant TenantPickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTenantId != widget.activeTenantId) {
      _selectedTenantId = widget.activeTenantId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active tenant',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tenant scope',
              ),
              value: _selectedTenantId,
              items: widget.tenants
                  .map(
                    (tenant) => DropdownMenuItem(
                      value: tenant.tenantId,
                      child: Text('${tenant.tenantName} · ${tenant.role}'),
                    ),
                  )
                  .toList(),
              onChanged: widget.isBusy
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedTenantId = value;
                      });
                    },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.isBusy || _selectedTenantId == widget.activeTenantId
                    ? null
                    : () => widget.onSwitch(_selectedTenantId),
                child: Text(widget.isBusy ? 'Switching...' : 'Switch tenant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
