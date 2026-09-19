//
//  WindowProviderAndPublicAPITests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@Suite(.serialized)
@MainActor
struct WindowProviderAndPublicAPITests {
    private func named(_ name: String, precedence: EKAttributes.Precedence = .override(priority: .normal, dropEnqueuedEntries: false)) -> EKAttributes {
        var attributes = TestSupport.staticAttributes()
        attributes.name = name
        attributes.precedence = precedence
        return attributes
    }

    private func display(_ name: String, precedence: EKAttributes.Precedence = .override(priority: .normal, dropEnqueuedEntries: false)) async {
        SwiftEntryKit.display(entry: TestSupport.contentView(), using: named(name, precedence: precedence))
        await TestSupport.flushMainQueue()
    }

    // MARK: - Display

    @Test func displayAndDismissView() async {
        await TestSupport.resetEntryKit()
        await display("view")

        #expect(SwiftEntryKit.isCurrentlyDisplaying)
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "view"))
        #expect(SwiftEntryKit.window != nil)
        #expect(SwiftEntryKit.isQueueEmpty)
        #expect(!SwiftEntryKit.queueContains(entryNamed: "view"))

        SwiftEntryKit.dismiss(.all)
        await TestSupport.flushMainQueue()
        await TestSupport.spinRunLoop()
        #expect(!SwiftEntryKit.isCurrentlyDisplaying)
        await TestSupport.resetEntryKit()
    }

    @Test func displayViewController() async {
        await TestSupport.resetEntryKit()
        SwiftEntryKit.display(entry: UIViewController(), using: named("vc"))
        await TestSupport.flushMainQueue()
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "vc"))
        await TestSupport.resetEntryKit()
    }

    @Test func displayInsideKeyWindow() async {
        await TestSupport.resetEntryKit()
        SwiftEntryKit.display(entry: TestSupport.contentView(), using: named("key"), presentInsideKeyWindow: true)
        await TestSupport.flushMainQueue()
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "key"))
        await TestSupport.resetEntryKit()
    }

    // MARK: - Queueing

    @Test func enqueueWhileDisplaying() async {
        await TestSupport.resetEntryKit()
        await display("first")
        await display("second", precedence: .enqueue(priority: .normal))

        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "first"))
        #expect(!SwiftEntryKit.isQueueEmpty)
        #expect(SwiftEntryKit.queueContains(entryNamed: "second"))

        SwiftEntryKit.dismiss(.displayed)
        await TestSupport.flushMainQueue()
        await TestSupport.spinRunLoop()

        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "second"))
        await TestSupport.resetEntryKit()
    }

    @Test func enqueueWithNothingDisplayedShowsImmediately() async {
        await TestSupport.resetEntryKit()
        await display("only", precedence: .enqueue(priority: .normal))
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "only"))
        await TestSupport.resetEntryKit()
    }

    @Test func overrideDropsEnqueuedEntries() async {
        await TestSupport.resetEntryKit()
        await display("first")
        await display("queued", precedence: .enqueue(priority: .normal))
        await display("override", precedence: .override(priority: .high, dropEnqueuedEntries: true))

        #expect(!SwiftEntryKit.queueContains(entryNamed: "queued"))
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "override"))
        await TestSupport.resetEntryKit()
    }

    @Test func lowerPriorityOverrideIsRejected() async {
        await TestSupport.resetEntryKit()
        await display("high", precedence: .override(priority: .high, dropEnqueuedEntries: false))
        await display("low", precedence: .override(priority: .low, dropEnqueuedEntries: false))

        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "high"))
        #expect(!SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "low"))
        await TestSupport.resetEntryKit()
    }

    @Test func queueContainsWithoutName() async {
        await TestSupport.resetEntryKit()
        await display("first")
        await display("second", precedence: .enqueue(priority: .normal))
        #expect(SwiftEntryKit.queueContains())
        await TestSupport.resetEntryKit()
    }

    // MARK: - Dismissal descriptors

    @Test func dismissSpecificEntry() async {
        await TestSupport.resetEntryKit()
        await display("first")
        await display("second", precedence: .enqueue(priority: .normal))

        SwiftEntryKit.dismiss(.specific(entryName: "second"))
        await TestSupport.flushMainQueue()
        #expect(!SwiftEntryKit.queueContains(entryNamed: "second"))

        SwiftEntryKit.dismiss(.specific(entryName: "first"))
        await TestSupport.flushMainQueue()
        await TestSupport.spinRunLoop()
        #expect(!SwiftEntryKit.isCurrentlyDisplaying)
        await TestSupport.resetEntryKit()
    }

    @Test func dismissPrioritizedLowerOrEqualTo() async {
        await TestSupport.resetEntryKit()
        await display("first", precedence: .override(priority: .normal, dropEnqueuedEntries: false))
        await display("low", precedence: .enqueue(priority: .low))

        SwiftEntryKit.dismiss(.prioritizedLowerOrEqualTo(priority: .normal))
        await TestSupport.flushMainQueue()
        await TestSupport.spinRunLoop()
        #expect(!SwiftEntryKit.isCurrentlyDisplaying)
        #expect(!SwiftEntryKit.queueContains(entryNamed: "low"))
        await TestSupport.resetEntryKit()
    }

    @Test func dismissEnqueuedOnly() async {
        await TestSupport.resetEntryKit()
        await display("first")
        await display("second", precedence: .enqueue(priority: .normal))

        SwiftEntryKit.dismiss(.enqueued)
        await TestSupport.flushMainQueue()
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "first"))
        #expect(SwiftEntryKit.isQueueEmpty)
        await TestSupport.resetEntryKit()
    }

    // MARK: - Transform & rollback

    @Test func transformCurrentEntry() async {
        await TestSupport.resetEntryKit()
        await display("first")
        SwiftEntryKit.transform(to: TestSupport.contentView(width: 150, height: 50))
        await TestSupport.flushMainQueue()
        await TestSupport.spinRunLoop(for: 0.5)
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "first"))
        await TestSupport.resetEntryKit()
    }

    @Test func rollbackToCustomWindow() async {
        await TestSupport.resetEntryKit()
        let customWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        SwiftEntryKit.display(
            entry: TestSupport.contentView(),
            using: named("custom"),
            rollbackWindow: .custom(window: customWindow)
        )
        await TestSupport.flushMainQueue()
        #expect(SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "custom"))

        SwiftEntryKit.dismiss(.all)
        await TestSupport.flushMainQueue()
        await TestSupport.spinRunLoop()
        #expect(!SwiftEntryKit.isCurrentlyDisplaying)
        await TestSupport.resetEntryKit()
    }

    // MARK: - Provider helpers

    @Test func providerHelpers() async {
        await TestSupport.resetEntryKit()
        let provider = EKWindowProvider.shared
        #expect(provider.entryWindow == nil)
        _ = EKWindowProvider.safeAreaInsets
        provider.layoutIfNeeded()

        await display("helpers")
        #expect(provider.rootVC != nil)
        #expect(provider.isCurrentlyDisplaying())
        #expect(provider.isCurrentlyDisplaying(entryNamed: "helpers"))
        #expect(!provider.isCurrentlyDisplaying(entryNamed: "other"))

        provider.isResponsiveToTouches = true
        #expect(provider.isResponsiveToTouches)
        provider.isResponsiveToTouches = false
        #expect(!provider.isResponsiveToTouches)

        await TestSupport.resetEntryKit()
    }

    // MARK: - Public API facade

    @Test func layoutIfNeededFromBackgroundThread() async {
        await TestSupport.resetEntryKit()
        await display("layout")
        await Task.detached { SwiftEntryKit.layoutIfNeeded() }.value
        await TestSupport.flushMainQueue()
        await TestSupport.resetEntryKit()
    }

    @Test func windowIsNilAfterReset() async {
        await TestSupport.resetEntryKit()
        #expect(SwiftEntryKit.window == nil)
        #expect(!SwiftEntryKit.isCurrentlyDisplaying)
        #expect(SwiftEntryKit.isQueueEmpty)
    }
}
