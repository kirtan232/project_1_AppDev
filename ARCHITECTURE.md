# Architecture

HomeFit Quest is a small app built by one person, so I kept the structure simple. Everything runs on the phone.

## Folders

* lib/screens: full pages, such as Home and History.
* lib/widgets: reusable pieces, such as PlanCard and RepStepper.
* lib/models: plain classes for the data, such as WorkoutPlan and TrainingLog.
* lib/data: everything that reads stored data, mainly DatabaseHelper.
* lib/logic: rules and settings, such as PlanRules, FocusMatch, and AppSettings.

## How the Parts Connect

```
screens and widgets
      |
      v
logic and data
      |
      v
models, SQLite, SharedPreferences
```

Screens never write SQL. They call DatabaseHelper, which turns rows into model objects. Rules that need no screen, like Focus Match, are plain Dart with no widgets.

## Example: Saving a Set

1. The user taps Done in WorkoutPlayerScreen.
2. The screen builds a TrainingLog with the workout's session key.
3. DatabaseHelper.insertLog saves it using placeholders.
4. The screen updates with setState and moves on.

If widgets did all of this themselves, the same SQL and rules would be copied across screens.

## State

* Each screen keeps its own state with setState, such as _loading, _index, and _repsDone.
* AppSettings is one small ChangeNotifier. Screens listen to it, which is how dark mode changes right away.
* Text controllers, page controllers, and timers belong to the widget that made them and are cleaned up in dispose.
* After an await, screens check mounted before updating.

## Storage

* SQLite holds plans and logged sets because they are related records that need queries.
* SharedPreferences holds settings because they are single values.
* exercises.json is a read-only list bundled with the app, so it is not a third table.
* A plan's exercises are stored as JSON text in one column. This keeps it to two tables.

## Important Rules

* Sets are not sessions. Every set in a workout shares a session_key. The weekly count uses "COUNT(DISTINCT session_key)" on finished sets.
* Stats are not stored. They are worked out from the saved sets each time, so an edit cannot leave them wrong.
* Deleting a plan removes its sets too. The foreign key has "ON DELETE CASCADE", and the delete runs in one transaction.
* Duplicates are blocked. A saving flag ignores repeat taps, and the player remembers which cards were saved.

## Trade-offs

* One shared DatabaseHelper: It is simple, but screens depend on it directly, so it would be harder to swap out for automated tests.
* JSON for exercises: It avoids a third table, but you cannot query inside it with SQL.

## Alternative Considered

I could have made a separate table for a plan's exercises. That is a cleaner database design, but the project asks for two entities and the app never needs to search inside a plan.
