# Tap Frenzy

Tutorial 1 for BSCCOMP25.1P: a 10-second tapping game built with SwiftUI.

## Run it

1. Open `TapFrenzy.xcodeproj` on a Mac with Xcode 16 or newer.
2. Pick an iPhone simulator.
3. Press ⌘R.

## What's in it

- **Base game:** score, a 10-second countdown, and three phases (idle → playing → over)
- **High score:** saved with `@AppStorage`, so it's still there after you restart the app
- **C1 Combo:** two taps within 300 ms give x2, then x3 points
- **C3 Moving target:** the button jumps to a random spot every second
- **C4 Shrinking button:** the button gets a little smaller with every tap
- **Extras:** haptic tap, animated score, a timer bar that goes green → amber → red, and a layout that works in landscape

All the game code is in `TapFrenzy/ContentView.swift`.
