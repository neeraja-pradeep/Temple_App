import 'dart:async';
import 'package:flutter/material.dart';
import 'package:temple_app/core/services/token_auto_refresh_service.dart';
import 'package:temple_app/core/theme/color/colors.dart';

/// Debug widget to show token status (for development/testing)
class TokenStatusWidget extends StatefulWidget {
  const TokenStatusWidget({super.key});

  @override
  State<TokenStatusWidget> createState() => _TokenStatusWidgetState();
}

class _TokenStatusWidgetState extends State<TokenStatusWidget> {
  Map<String, dynamic>? _tokenStatus;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTokenStatus();

    // Update every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateTokenStatus();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateTokenStatus() {
    setState(() {
      _tokenStatus = TokenAutoRefreshService.getTokenStatus();
    });
  }

  Future<void> _refreshToken() async {
    final success = await TokenAutoRefreshService.refreshTokenNow();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Token refreshed successfully' : 'Token refresh failed',
          ),
          backgroundColor: success ? Colors.green : primaryThemeColor,
        ),
      );
    }
    _updateTokenStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_tokenStatus == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Loading token status...'),
        ),
      );
    }

    final status = _tokenStatus!;
    final hasToken = status['hasToken'] as bool;
    final isExpired = status['isExpired'] as bool;
    final needsRefresh = status['needsRefresh'] as bool;
    final timeUntilExpiry = status['timeUntilExpiry'] as Duration?;
    final statusText = status['status'] as String;

    Color statusColor;
    if (isExpired) {
      statusColor = primaryThemeColor;
    } else if (needsRefresh) {
      statusColor = primaryThemeColor;
    } else {
      statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasToken ? Icons.security : Icons.security_outlined,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Token Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _refreshToken,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Token',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Status: $statusText'),
            if (timeUntilExpiry != null) ...[
              Text('Time until expiry: ${_formatDuration(timeUntilExpiry)}'),
              Text('Auto-refresh: ${needsRefresh ? 'Yes' : 'No'}'),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: hasToken && !isExpired
                  ? _calculateProgress(timeUntilExpiry)
                  : 0.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Expired';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  double _calculateProgress(Duration? timeUntilExpiry) {
    if (timeUntilExpiry == null || timeUntilExpiry.isNegative) return 0.0;

    // Assume token is valid for 1 hour (3600 seconds)
    const totalDuration = Duration(hours: 1);
    final remaining = timeUntilExpiry.inSeconds;
    final total = totalDuration.inSeconds;

    return (remaining / total).clamp(0.0, 1.0);
  }
}

/// Floating action button to show token status
class TokenStatusFAB extends StatelessWidget {
  const TokenStatusFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Token Status'),
            content: const TokenStatusWidget(),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      tooltip: 'Token Status',
      child: const Icon(Icons.security),
    );
  }
}
