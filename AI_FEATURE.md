# Focus Match

## What It Is

Focus Match is a "rule-based smart helper". It is not a trained model and it is not generative AI. It is a few rules I wrote in one Dart file, `lib/logic/focus_match.dart`.

It shows one card on the Home screen and suggests a plan to try next.

## Why It Helps

After a while you have a few plans and it is easy to keep repeating the same one. Focus Match saves you from deciding what to do next by bringing back a plan you have not done lately.

My goal was modest: the suggestion should be a plan in the area you asked for, and not the one you just did.

## Inputs

* Preferred focus from Settings (Full Body, Upper, Lower, Core, or Cardio). This is a choice, with no units.
* Each plan's focus area and id.
* The date each plan was last finished, from `training_logs`.

I left out effort and reps on purpose. A preference says what someone wants to do, not what they are able to do. The app should not guess about ability or fitness.

Not finished sessions do not count, because the plan was not really completed.

## How It Decides

1. Keep plans in the preferred focus. If there is no preference, or no plan matches, keep all plans.
2. Pick the plan finished longest ago. A plan never done counts as the oldest.
3. If two plans tie, pick the lower plan id.

## Alternative I Did Not Use

The topic brief suggests Gear Match, which gives points for equipment. Every workout in my app uses no equipment, so that input would not change anything. Focus area was more useful.

## Baseline

The baseline keeps plans in the preferred focus and picks the lowest id. It has no idea what you did recently.

## Test Cases

Plans used: A = id 1, Lower, finished 2 days ago. B = id 2, Lower, never done. C = id 3, Upper, finished 6 days ago.

I ran these through the real `suggest` and `baseline` functions on October 30, 2026.

| ID | Type | Input | Expected | Helper actual | Baseline actual | Pass or fail |
|---|---|---|---|---|---|---|
| C1 | Normal | Preference Lower | B | B | A | Pass |
| C2 | No data | No plans | "Add a plan first." | "Add a plan first." | No plan | Pass |
| C3 | Invalid | Saved preference "Legs" | B, plus "Set your focus in Settings." | B, plus "Set your focus in Settings." | A | Pass |
| C4 | Tie | No preference, no history | A | A | A | Pass |
| C5 | Counterexample | Preference Lower, user keeps pressing Not Now on B | Still B | B | A | Pass, but see below |

## Results

* Metric: matches out of valid cases. I used C1, C4, and C5.
* Helper: 3 out of 3. Baseline: 1 out of 3.
* This is a very small sample that I made up. I also chose the expected answers from my own rules, so it shows the rules work as designed. It does not prove the helper is better for real users.

## Counterexample

C5 is where the helper is not very helpful. If you keep saying Not Now to plan B, it is still the oldest, so it keeps coming back after the app restarts. The helper ignores that you said no.

## Limitation I Kept

Not Now hides the suggestion only until a different plan is suggested or the app restarts. I kept this because saving every Not Now would add more data and more rules, and the goal was to keep the helper simple.

Also, case C2 cannot show up in the real app, because the pre-built plans can never be deleted. It is still handled in the code.

## User Control

* The card shows the reason, for example "Lower plan, not done in 5 days, matches your focus."
* View Plan only shows the exercises. The workout starts only if you press Start Workout.
* Not Now hides the card.
* Settings can turn suggestions off.
* It never changes a plan and it never gives health or exercise advice.

## Offline

All of the inputs are stored on the phone and the helper makes no network calls. The result is worked out again when plans, history, or settings change.

Airplane mode and restart check: [ADD RESULT AFTER TESTING]
