import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../providers/tts_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAvatar(auth),
            const SizedBox(height: 16),
            _buildName(context, auth),
            if (!auth.isGuest) ...[
              const SizedBox(height: 4),
              _buildEmail(context, auth),
            ],
            const SizedBox(height: 32),
            _buildStatsSection(context, app),
            const SizedBox(height: 32),
            _buildTTSSettings(context),
            const SizedBox(height: 32),
            if (auth.isLoggedIn) _buildSyncButton(context, app),
            if (auth.isGuest) _buildGuestPrompt(context),
            const SizedBox(height: 16),
            if (auth.isLoggedIn) _buildSignOutButton(context, auth),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(AuthProvider auth) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
      child: Icon(
        auth.isGuest ? Icons.person_outline : Icons.person,
        size: 48,
        color: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildName(BuildContext context, AuthProvider auth) {
    final name = auth.isGuest ? 'Guest' : (auth.displayName ?? 'Student');
    return Text(
      name,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEmail(BuildContext context, AuthProvider auth) {
    final email = auth.user?.email ?? '';
    if (email.isEmpty) return const SizedBox.shrink();
    return Text(
      email,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AppProvider app) {
    final topicsDone = app.topics
        .where((t) => app.getTopicProgress(t.id) >= 1.0)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            context,
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            label: 'Day Streak',
            value: '${app.progress.streak}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            context,
            icon: Icons.star,
            iconColor: Colors.cyan,
            label: 'Total Points',
            value: '${app.progress.totalPoints}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            context,
            icon: Icons.quiz,
            iconColor: Colors.purple,
            label: 'Topics Done',
            value: '$topicsDone',
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTTSSettings(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, tts, _) {
        String speedLabel;
        if (tts.speechRate <= 0.3) {
          speedLabel = 'Very Slow';
        } else if (tts.speechRate <= 0.5) {
          speedLabel = 'Slow';
        } else if (tts.speechRate <= 0.8) {
          speedLabel = 'Normal';
        } else if (tts.speechRate <= 1.1) {
          speedLabel = 'Fast';
        } else {
          speedLabel = 'Very Fast';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.secondaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.record_voice_over,
                    color: AppTheme.secondaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Voice Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Speed'),
                  const Spacer(),
                  Text(
                    '${tts.speechRate.toStringAsFixed(1)}x  ($speedLabel)',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.slow_motion_video, size: 16),
                  Expanded(
                    child: Slider(
                      value: tts.speechRate,
                      min: 0.25,
                      max: 1.5,
                      divisions: 10,
                      onChanged: (value) {
                        tts.setSpeechRate(value);
                      },
                      activeColor: AppTheme.secondaryColor,
                    ),
                  ),
                  const Icon(Icons.speed, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    tts.speak(
                      'This is how your voice sounds at the current speed setting.',
                    );
                  },
                  icon: Icon(
                    tts.isPlaying ? Icons.stop : Icons.play_arrow,
                    size: 18,
                  ),
                  label: Text(tts.isPlaying ? 'Playing...' : 'Test Voice'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryColor,
                    side: BorderSide(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSyncButton(BuildContext context, AppProvider app) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await app.syncNow();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Progress synced successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        icon: const Icon(Icons.sync),
        label: const Text('Sync Now'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 40,
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Your progress is stored locally',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account to sync your progress across devices and never lose your data.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create Account / Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showSignOutDialog(context, auth),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accentColor,
          side: BorderSide(
            color: AppTheme.accentColor.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your local progress will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
