# Tap Frenzy

SwiftUI games for BSCCOMP25.1P. The app opens on a Home screen with two modes.

## Run it

1. Open `TapFrenzy.xcodeproj` on a Mac with Xcode 16 or newer.
2. Pick an iPhone simulator.
3. Press ⌘R.

## Tutorial 1: Tap Frenzy

- **Base game:** score, a 10-second countdown, and three phases (idle → playing → over)
- **High score:** saved with `@AppStorage`, so it's still there after you restart the app
- **C1 Combo:** two taps within 300 ms give x2, then x3 points
- **C3 Moving target:** the button jumps to a random spot after every tap
- **C4 Shrinking button:** the button gets a little smaller with every tap
- **Extras:** haptic tap, animated score, a timer bar that goes green → amber → red, and a layout that works in landscape

## Tutorial 2: Light It Up

- **Home screen:** a `NavigationStack` with a button for each mode, showing each mode's best score
- **Game:** cards light up one at a time; tap the lit card before it goes dark
- **Levels:** a 60-second round with four levels

  | Level | Time | Cards | Lit window |
  |---|---|---|---|
  | 1 | 0–15 s | 3 | 1.5 s |
  | 2 | 15–30 s | 4 (2×2) | 1.2 s |
  | 3 | 30–45 s | 6 (2×3) | 1.0 s |
  | 4 | 45 s+ | 9 (3×3), two lit at once | 0.8 s |

- **High score:** saved per mode with `@AppStorage`
- **Stretch goals:** 3 lives (wrong tap or missed card loses one), a colour per level, and a "Level 2!" flash on level-up

## Files

- `HomeView.swift`: Home screen
- `TapFrenzyView.swift`: Tap Frenzy
- `LightItUpView.swift`: Light It Up
- `Shared.swift`: game phases, colours and the button style both games use
