# SwiftEntryKit Architecture

SwiftEntryKit is a single-module iOS library for presenting entries (toasts, notes, popups, alerts, status bars, forms, ratings) in a dedicated `UIWindow` above the app, with queueing, priority, and rich animation. No external dependencies — the only bundled third-party code is `QuickLayout`, a lightweight Auto Layout DSL.

## Layered overview

```
┌─────────────────────────────────────────────────────────────────────┐
│ Public API                                                          │
│   SwiftEntryKit  (stateless, thread-safe facade)                    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ dispatch to main queue
┌───────────────────────────────▼─────────────────────────────────────┐
│ Model                                                               │
│   EKAttributes (+ presets)  ·  EKProperty  ·  message structs        │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ passed by value (structs)
┌───────────────────────────────▼─────────────────────────────────────┐
│ Infra — presentation engine                                         │
│   EKWindowProvider → EKWindow → EKRootViewController                 │
│     → EKContentView → EKEntryView → EKBackgroundView / EKStyleView   │
│   EntryCachingHeuristic (queue)                                     │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ hosts
┌───────────────────────────────▼─────────────────────────────────────┐
│ Message views (pre-built UI)                                        │
│   EKSimpleMessageView · EKNotificationMessageView · EKAlertMessageView│
│   EKPopUpMessageView · EKRatingMessageView · EKFormMessageView        │
│   Notes: EKNote / ImageNote / ProcessingNote / AccessoryNote / XStatus│
└─────────────────────────────────────────────────────────────────────┘
        Extensions/Utils: QuickLayout · UIView+Shadow · GradientView
                          HapticFeedbackGenerator · UIColor+Utils …
```

## Public API — `Source/SwiftEntryKit.swift`

`SwiftEntryKit` is a `final class` with only `class` methods and no state. Every entry point (`display`, `dismiss`, `transform`, `layoutIfNeeded`) is thread-safe: it hops onto the main queue and forwards to the `EKWindowProvider.shared` singleton. The dismissal/query descriptors (`EntryDismissalDescriptor`, `RollbackWindow`) also live here.

## Model layer — `Source/Model`

- **`EKAttributes`** is the single configuration struct. It is declared in `EntryAttributes/EKAttributes.swift` and split across one extension file per concern (Animation, BackgroundStyle, Duration, Position, Precedence, Scroll, Shadow, StatusBar, UserInteraction, …). Notable fields:
  - `name` — optional identifier for querying/dismissing a specific entry.
  - `position` / `positionConstraints` — where and how big (offset/ratio/constant/intrinsic, max size, safe-area override, keyboard relation, rotation).
  - `precedence` — `.override(priority:dropEnqueuedEntries:)` or `.enqueue(priority:)`.
  - `displayDuration`, `entranceAnimation`, `exitAnimation`, `popBehavior` — timing/animation.
  - `screenInteraction` / `entryInteraction` — touch forwarding vs. absorb/dismiss.
  - `entryBackground` / `screenBackground` / `shadow` / `roundCorners` / `border` / `statusBar` — theming.
- **`EKAttributes+Presets.swift`** builds common configs (`toast`, `float`, `topFloat`, `bottomFloat`, `centerFloat`, `topToast`, `bottomToast`, `topNote`, `bottomNote`, `statusBar`) as conveniences.
- **`EKProperty`** holds reusable content descriptors: `LabelContent`, `LabelStyle`, `ButtonContent`, `ImageContent`, `TextFieldContent`, `ButtonBarContent`, `RatingItemContent`.
- **Message structs** (`EKSimpleMessage`, `EKNotificationMessage`, `EKPopUpMessage`, `EKAlertMessage`, `EKRatingMessage`, `EKFormMessage`) are value types describing what a pre-built message view should render.

## Infra — presentation engine — `Source/Infra`

### `EKWindowProvider`
Singleton coordinator. Owns:
- `entryWindow` (`EKWindow`) and its `rootVC` (`EKRootViewController`).
- `entryQueue` — an `EntryCachingHeuristic`.
- `rollbackWindow` + `mainRollbackWindow` — the window restored after the last entry dismisses.

Responsible for the display/dismiss/queue decision logic:
- `display(entryView:using:…)` switches on `precedence`: `.override` (optionally clears the queue, then `show`) vs `.enqueue` (queue if something is displayed, else `show`).
- `show` → `prepare(for:)` creates the window/root VC on first use, enforces priority via `canDisplay(attributes:)`, sets `windowLevel`, makes key window if requested.
- `dismiss(_:with:)` handles all `EntryDismissalDescriptor` cases against both the live entry and the queue.
- `displayPendingEntryOrRollbackWindow` dequeues the next entry or restores the rollback window after a dismissal completes.

### `EKWindow`
`UIWindow` subclass. Custom `hitTest` forwards touches to the entry only when `isAbleToReceiveTouches` is set; otherwise returns the underlying entry view or `nil`, letting touches pass through to the app window. Patches in a `UIWindowScene` for SwiftUI host apps.

### `EKRootViewController`
Hosts entries as subviews of its `view` (`EKWrapperView`). Manages:
- Status-bar style/hidden overrides while an entry is present.
- Screen background transitions (`changeToActive` / `changeToInactive` → `EKBackgroundView.Style`).
- Orientation/rotation support.
- Pop behavior: when a higher-priority entry arrives, animates out the previous entry.
- Screen touch handling (`touchesEnded`) for dismiss/tap actions.
Conforms to `EntryPresenterDelegate` to notify `EKWindowProvider` when display finishes.

### `EKWrapperView`
Root view whose `hitTest` passes touches through unless enabled — the entry window never blocks the app unless configured to.

### `EKContentView`
The per-entry container. The most complex class. Handles:
- **Positioning via constraint priority trick** — entry holds `inConstraint`, `entranceOutConstraint`, `exitOutConstraint`, `popOutConstraint`, `swipeUp/DownOutConstraint` at different Auto Layout priorities; animating in/out just reprioritizes them.
- Entrance / exit / pop / swipe animations (translate, fade, scale, spring).
- `UIPanGestureRecognizer` for swipe-to-dismiss, rubber-band stretch with logarithmic offset, and pull-back.
- Keyboard binding (observes keyboard notifications, animates the entry above the keyboard).
- Lifecycle events (`willAppear`, `didAppear`, `willDisappear`, `didDisappear`) and scheduled auto-dismiss via `DispatchWorkItem`.
- Haptic feedback generation.
On removal, calls `EntryContentViewDelegate.didFinishDisplaying` → the provider dequeues the next entry or rolls back the window.

### `EKEntryView`
Stylized wrapper (`EKStyleView`) around the actual content (a `UIView` or a `UIViewController`'s view). Applies shadow, rounded corners, border, and entry background; handles the safe-area-filled vs. floating background layout; supports `transform(to:)` for in-place content replacement.

### `EKStyleView`
Base `UIView` that applies rounded corners (via `CAShapeLayer` mask) and border (stroke layer), re-applied on `layoutSubviews`.

### `EKBackgroundView`
Renders a background style — color, gradient (`GradientView`), image, or visual-effect blur — resolving light/dark variants via `traitCollection`. Used for both the entry background and the full-screen background.

### `EntryCachingHeuristic`
Queue abstraction (`protocol` with `entries`, `dequeue`, `enqueue`, and filtered `remove*`) with two implementations:
- `EKEntryChronologicalQueue` — FIFO.
- `EKEntryPriorityQueue` — ordered by `Precedence.Priority`.
The active heuristic is a global (`EKAttributes.Precedence.QueueingHeuristic.value`), default `.priority`.

## Message views — `Source/MessageViews`

Pre-built entry UIs composed from `EKProperty` descriptors:
- `EKSimpleMessageView` — thumbnail + title + description (base for several others).
- `EKNotificationMessageView` — simple message + auxiliary label.
- `EKAlertMessageView` — simple message + button bar (conforms to `EntryAppearanceDescriptor` to match corner radius).
- `EKPopUpMessageView` — image, title, description, action button.
- `EKRatingMessageView` — rating symbols.
- `EKFormMessageView` — title + text fields + button bar.
- `Notes/` — `EKNoteMessageView` (+ `ImageNote`, `ProcessingNote`, `AccessoryNote`) and `EKXStatusBarMessageView`.
- `MessagesUtils/` — `EKButtonBarView`, `EKButtonView`, `EKRatingSymbol(s)View`, `EKTextField`, `EntryAppearanceDescriptor`.

All resolve light/dark colors by overriding `traitCollectionDidChange`.

## Extensions & Utils

- `Extensions/QuickLayout` — bundled Auto Layout DSL (`layoutToSuperview`, `layout(_:to:of:)`, `set(_:of:)`, `fillSuperview`, `forceContentWrap`).
- `Extensions/` — `UIApplication+EKAppearance` (status bar), `UIColor+Utils`, `UIEdgeInsets+Utils`, `UIRectCorner+Short`, `UIView+Shadow`, `UIView+Utils`.
- `Utils/` — `GradientView`, `HapticFeedbackGenerator`, `UIView+Responder`.

## Core flow

**Display**
1. `SwiftEntryKit.display(view:using:)` → main queue → `EKWindowProvider.display(view:using:)`.
2. View wrapped in `EKEntryView` (content + attributes).
3. Precedence switch: `.override` → clear queue if requested → `show`; `.enqueue` → queue if displaying, else `show`.
4. `show` → `prepare` creates `EKWindow` + `EKRootViewController` on first use, checks priority, sets window level / key window.
5. `EKRootViewController.configure(entryView:)` → adds child VC if needed, pops the previous entry, creates an `EKContentView`, calls `setup(with:)`.
6. `EKContentView.setup` → `willAppear`, position + size constraints, `animateIn`, tap gesture, haptic, keyboard binding, `scheduleAnimateOut`.

**Dismiss**
1. Timer, tap, swipe, or `SwiftEntryKit.dismiss` triggers `EKContentView.animateOut`.
2. On removal, `removeFromSuperview(keepWindow:)` fires `didDisappear` and calls `EntryContentViewDelegate.didFinishDisplaying`.
3. `EKWindowProvider.displayPendingEntryOrRollbackWindow` dequeues the next entry or restores the rollback window and invokes the completion handler.

**Touch routing** — `EKWindow.hitTest` / `EKWrapperView.hitTest` only return the entry's views when the entry is configured to absorb touches; otherwise touches fall through to the underlying app window.
