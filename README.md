# HomeFit Quest

## Overview

* HomeFit Quest is an offline Flutter app for planning, doing, and logging short home workouts with no equipment.
* It is built on the Movement Quest topic for Project One.
* The main idea is an honest record. Sets are grouped into sessions, so three sets from one workout count as one session.
* Target users are people who want a short routine at home without an account or internet.
* Team: HomeFit
* Member: Kirtan Patel, undergraduate pathway, all roles (UI, data, activity, smart helper, testing, documentation, demo)
* Repository: https://github.com/kirtan232/project_1_AppDev
* ClickUp board: [ADD BOARD URL]
* Kanban evidence: Kanban_Contribution_Evidence.pdf

## Features

* Three pre-built plans: Easy 5, Medium 10, and Hard 15 minutes.
* Create, edit, delete, and filter your own plans.
* Copy a pre-built plan to your own plans so you can change it.
* Pick from 25 bundled exercises and choose Easy, Medium, or Difficult.
* Play a plan as flashcards with a rep counter or a countdown timer.
* Rest countdown between exercises.
* History of sessions marked Finished or Not finished.
* Fix mistakes by changing a set, adding a missed set, or deleting a set or session.
* Stats for sessions this week and total reps.
* Settings saved on the phone, including dark mode.
* Focus Match, a rule-based helper that suggests a plan.

## How to Run

* Install Flutter stable. I used Flutter 3.47.2.
* On Windows, turn on Developer Mode so Flutter can build with plugins.
* Start an Android emulator or connect an Android phone.
* Run `flutter pub get`.
* Run `flutter run`.
* To build the release APK, run `flutter build apk --release`.
* Packages: sqflite, path, shared_preferences, and audioplayers.

## How to Use

* Tap a plan to start it.
* On each card, set what you really did and tap Done. Tap Skip to move on without saving.
* Tap How to on a card to see the steps.
* If you leave early, choose Save as Not Finished, Discard, or Keep Going.
* Tap the pen icon in History to fix a session.
* Tap the gear icon to open Settings.

## Screens

* Home: suggestion card, stats, and pre-built plans.
* Personal Plans: your plans, focus filter, and the New Plan button.
* New or Edit Plan: name, description, focus area, and exercises.
* Workout Player: the flashcards, rest card, and completion screen.
* History: past sessions, stats, and the edit sheet.
* Settings: volume, music, vibration, dark mode, rest time, preferred focus, and suggestions.

## Data

* All data stays on the phone. The app has no cloud storage and no network calls.
* SQLite has two tables, workout_plans and training_logs.
* workout_plans stores id, title, description, focus_area, exercises_json, est_minutes, is_prebuilt, and created_at.
* training_logs stores id, workout_id, session_key, exercise_label, amount, unit, logged_at, and session_finished.
* Each workout gets one session_key, and every set in that workout shares it.
* Deleting a plan warns how many sets will go with it, then deletes both together.
* Pre-built plans cannot be edited or deleted.
* SharedPreferences stores the seven settings.

## Changes From the Proposal

* A plan's exercises are stored as a structured list instead of a text note.
* The space tag and effort preference fields were removed. Description, estimated minutes, and a pre-built flag were added.
* The exercise list is a JSON file with 25 exercises instead of 15 in a Dart list.
* The app uses the default Android font and a light blue accent to keep things simple.

## Smart Helper

* Focus Match is a rule-based smart helper, not a trained model.
* It keeps plans in your preferred focus, then suggests the one you finished longest ago.
* See AI_FEATURE.md for the method and test cases.

## Credits

* Exercise names and instruction text are based on the exercises-dataset by Hasan Emir Yildirim (https://github.com/hasaneyldrm/exercises-dataset), used under the MIT License.
* Exercise animation GIFs are © Gym visual — https://gymvisual.com/. They are kept at their original 180x180 size and are not covered by the MIT License.
* The beep sound in assets/sounds/beep.wav was generated for this project.
* App code is a class project, and no open source license is offered for it.

## Known Issues

* I asked Gym visual for permission to use the GIFs and I am waiting for a reply. If a GIF is removed, the card shows a plain tile instead.
* The beep is very short and I could not hear it on my emulator, even though the logs show it played.
* Vibration has not been checked on a real phone.
* The Music setting controls the beep only, because the app has no music track.
* The reduce-motion setting does not stop the exercise GIFs.
* Large text and landscape have not been fully checked.
* Estimated minutes always use a 20 second rest, not the rest time in Settings.
* Pressing Not Now only hides a suggestion until the app restarts.

## Future Improvements

* Better animations for card flip.
* Add background music.

