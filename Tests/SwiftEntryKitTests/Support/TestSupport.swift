//
//  TestSupport.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

/// Shared helpers for driving the presentation engine in tests.
@MainActor
enum TestSupport {
    /// Drains blocks enqueued on the main queue (e.g. `SwiftEntryKit`'s async dispatch).
    static func flushMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    /// Spins the main run loop so `UIView` animation completions can fire.
    static func spinRunLoop(for interval: TimeInterval = 0.05) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                continuation.resume()
            }
        }
    }

    /// A plain content view with a non-zero frame.
    static func contentView(width: CGFloat = 200, height: CGFloat = 80) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        return view
    }

    /// Builds an entry view backed by a plain view.
    static func entryView(attributes: EKAttributes = .init(), view: UIView? = nil) -> EKEntryView {
        EKEntryView(newEntry: .init(view: view ?? contentView(), attributes: attributes))
    }

    /// Deterministic attributes: no animation, no auto-dismiss, prompt pop.
    static func staticAttributes(
        position: EKAttributes.Position = .top,
        displayDuration: EKAttributes.DisplayDuration = .infinity
    ) -> EKAttributes {
        var attributes = EKAttributes()
        attributes.position = position
        attributes.displayDuration = displayDuration
        attributes.entranceAnimation = .none
        attributes.exitAnimation = .none
        attributes.popBehavior = .overridden
        attributes.hapticFeedbackType = .none
        return attributes
    }

    /// Removes every entry and tears the provider's window down.
    static func resetEntryKit() async {
        let provider = EKWindowProvider.shared
        provider.dismiss(.all)
        await flushMainQueue()
        await spinRunLoop()
        if provider.entryWindow != nil {
            provider.displayRollbackWindow()
        }
        await flushMainQueue()
    }

    private static var retainedPresenters: [TestEntryPresenterDelegate] = []
    private static var retainedContentDelegates: [TestEntryContentViewDelegate] = []
    private static var retainedViews: [UIView] = []

    /// `EKRootViewController` holds its delegate `unowned`; keep test spies alive.
    static func retain(_ delegate: TestEntryPresenterDelegate) {
        retainedPresenters.append(delegate)
    }

    /// `EKContentView` holds its delegate `weak`; delayed dismissal work items outlive tests.
    static func retain(_ delegate: TestEntryContentViewDelegate) {
        retainedContentDelegates.append(delegate)
    }

    /// A view's `superview` is weak; keep test hosts alive.
    static func retain(_ view: UIView) {
        retainedViews.append(view)
    }
}

/// Records calls made by the presentation engine.
@MainActor
final class TestEntryPresenterDelegate: EntryPresenterDelegate {
    var isResponsiveToTouches = false
    private(set) var displayPendingCount = 0
    private(set) var lastDismissCompletion: (() -> Void)?

    func displayPendingEntryOrRollbackWindow(dismissCompletionHandler: (() -> Void)?) {
        displayPendingCount += 1
        lastDismissCompletion = dismissCompletionHandler
    }
}

/// Records calls made by `EKContentView`.
@MainActor
final class TestEntryContentViewDelegate: EntryContentViewDelegate {
    private(set) var changeToActiveCount = 0
    private(set) var changeToInactiveCount = 0
    private(set) var lastPushOut: Bool?
    private(set) var didFinishCount = 0
    private(set) var lastKeepWindowActive: Bool?
    private(set) var lastDismissCompletion: (() -> Void)?

    func changeToActive(withAttributes _: EKAttributes) {
        changeToActiveCount += 1
    }

    func changeToInactive(withAttributes _: EKAttributes, pushOut: Bool) {
        changeToInactiveCount += 1
        lastPushOut = pushOut
    }

    func didFinishDisplaying(entry _: EKEntryView, keepWindowActive: Bool, dismissCompletionHandler: (() -> Void)?) {
        didFinishCount += 1
        lastKeepWindowActive = keepWindowActive
        lastDismissCompletion = dismissCompletionHandler
    }
}
