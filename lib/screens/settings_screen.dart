import 'package:flutter/material.dart';

import '../logic/app_settings.dart';
import '../logic/plan_rules.dart';

// This screen shows every setting. Each change is saved right away.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // This method saves one setting and shows a message if saving fails.
  Future<void> _save(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the setting. Please try again.'),
        ),
      );
    }
  }

  // This method builds a section title above a group of settings.
  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    // The screen redraws whenever a setting changes.
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        // An unknown saved focus is shown as "No preference" so the menu still works.
        final focus = PlanRules.focusAreas.contains(settings.preferredFocus)
            ? settings.preferredFocus
            : null;

        return Scaffold(
          // The AppBar adds a back button at the top left automatically.
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _sectionTitle(context, 'Sound'),
              ListTile(
                title: const Text('Volume'),
                trailing: Text('${(settings.volume * 100).round()}%'),
              ),
              // The slider is labelled so screen readers say what it changes.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Slider(
                  value: settings.volume,
                  divisions: 10,
                  label: '${(settings.volume * 100).round()}%',
                  semanticFormatterCallback: (value) =>
                      'Volume ${(value * 100).round()} percent',
                  onChanged: (value) =>
                      _save(context, () => settings.setVolume(value)),
                ),
              ),
              SwitchListTile(
                title: const Text('Music'),
                subtitle: const Text('Play sounds during workouts.'),
                value: settings.musicOn,
                onChanged: (value) =>
                    _save(context, () => settings.setMusicOn(value)),
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate when a timer ends.'),
                value: settings.vibrationOn,
                onChanged: (value) =>
                    _save(context, () => settings.setVibrationOn(value)),
              ),
              _sectionTitle(context, 'Display'),
              SwitchListTile(
                title: const Text('Dark mode'),
                value: settings.darkMode,
                onChanged: (value) =>
                    _save(context, () => settings.setDarkMode(value)),
              ),
              _sectionTitle(context, 'Workout'),
              ListTile(
                title: const Text('Rest between exercises'),
                trailing: Text('${settings.restSeconds} sec'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Slider(
                  value: settings.restSeconds.toDouble(),
                  min: AppSettings.minRestSeconds.toDouble(),
                  max: AppSettings.maxRestSeconds.toDouble(),
                  // Ten divisions make the slider move in 5 second steps.
                  divisions: 10,
                  label: '${settings.restSeconds} sec',
                  semanticFormatterCallback: (value) =>
                      'Rest ${value.round()} seconds',
                  onChanged: (value) => _save(
                    context,
                    () => settings.setRestSeconds(value.round()),
                  ),
                ),
              ),
              _sectionTitle(context, 'Suggestions'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String?>(
                  initialValue: focus,
                  decoration: const InputDecoration(
                    labelText: 'Preferred focus',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No preference'),
                    ),
                    for (final area in PlanRules.focusAreas)
                      DropdownMenuItem<String?>(value: area, child: Text(area)),
                  ],
                  onChanged: (value) =>
                      _save(context, () => settings.setPreferredFocus(value)),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Show workout suggestions'),
                subtitle: const Text('Show the Focus Match card on Home.'),
                value: settings.showSuggestions,
                onChanged: (value) =>
                    _save(context, () => settings.setShowSuggestions(value)),
              ),
            ],
          ),
        );
      },
    );
  }
}
