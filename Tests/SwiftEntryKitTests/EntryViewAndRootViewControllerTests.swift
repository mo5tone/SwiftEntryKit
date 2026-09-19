//
//  EntryViewAndRootViewControllerTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct EntryViewAndRootViewControllerTests {
    private final class TestAppearanceView: UIView, EntryAppearanceDescriptor {
        var bottomCornerRadius: CGFloat = 0
    }

    // MARK: - EKEntryView

    @Test func entryViewFromPlainView() {
        var attributes = TestSupport.staticAttributes()
        attributes.roundCorners = .all(radius: 10)
        attributes.border = .value(color: .red, width: 1)
        let entryView = TestSupport.entryView(attributes: attributes)
        entryView.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        entryView.layoutIfNeeded()
        entryView.layoutSubviews()
        entryView.traitCollectionDidChange(nil)
        #expect(entryView.attributes.name == attributes.name)
    }

    @Test func entryViewFromViewController() {
        let viewController = UIViewController()
        let entryView = EKEntryView(newEntry: .init(viewController: viewController, attributes: TestSupport.staticAttributes()))
        entryView.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        #expect(entryView.content.viewController === viewController)
    }

    @Test func entryViewAdjustsInnerAppearance() {
        let appearanceView = TestAppearanceView()
        var attributes = TestSupport.staticAttributes()
        attributes.roundCorners = .bottom(radius: 16)
        _ = EKEntryView(newEntry: .init(view: appearanceView, attributes: attributes))
        #expect(appearanceView.bottomCornerRadius == 16)
    }

    @Test func entryViewShadow() {
        var attributes = TestSupport.staticAttributes()
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 4, offset: .init(width: 1, height: 1)))
        let entryView = TestSupport.entryView(attributes: attributes)
        #expect(entryView.layer.shadowOpacity == 0.5)

        attributes.shadow = .none
        let plain = TestSupport.entryView(attributes: attributes)
        #expect(plain.layer.shadowOpacity == 0)
    }

    @Test func entryViewFilledSafeAreaBackgrounds() {
        for position in [EKAttributes.Position.top, .bottom, .center] {
            var attributes = TestSupport.staticAttributes(position: position)
            attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
            _ = TestSupport.entryView(attributes: attributes)
        }
    }

    @Test func entryViewTransform() async {
        let entryView = TestSupport.entryView()
        let next = TestSupport.contentView(width: 150, height: 60)
        entryView.transform(to: next)
        await TestSupport.spinRunLoop(for: 0.5)
        #expect(entryView.content.view === next)
    }

    // MARK: - EKRootViewController

    private func makeRootVC() -> (EKRootViewController, TestEntryPresenterDelegate) {
        let delegate = TestEntryPresenterDelegate()
        TestSupport.retain(delegate)
        let rootVC = EKRootViewController(with: delegate)
        _ = rootVC.view
        return (rootVC, delegate)
    }

    @Test func rootViewLoads() {
        let (rootVC, _) = makeRootVC()
        #expect(rootVC.view.subviews.count == 1)
    }

    @Test func configureWithViewAndViewController() {
        let (rootVC, _) = makeRootVC()
        var attributes = TestSupport.staticAttributes()
        attributes.screenInteraction = .absorbTouches
        rootVC.configure(entryView: TestSupport.entryView(attributes: attributes))
        #expect(rootVC.canDisplay(attributes: attributes))

        let viewController = UIViewController()
        let entryView = EKEntryView(newEntry: .init(viewController: viewController, attributes: attributes))
        rootVC.configure(entryView: entryView)
        #expect(viewController.parent === rootVC)
    }

    @Test func canDisplayRespectsPriority() {
        let (rootVC, _) = makeRootVC()
        var low = TestSupport.staticAttributes()
        low.precedence = .override(priority: .low, dropEnqueuedEntries: false)
        rootVC.configure(entryView: TestSupport.entryView(attributes: low))

        var high = TestSupport.staticAttributes()
        high.precedence = .override(priority: .high, dropEnqueuedEntries: false)
        #expect(rootVC.canDisplay(attributes: high))

        var lower = TestSupport.staticAttributes()
        lower.precedence = .override(priority: .min, dropEnqueuedEntries: false)
        #expect(!rootVC.canDisplay(attributes: lower))
    }

    @Test func configureRemovesPreviousEntry() {
        let (rootVC, _) = makeRootVC()

        var overridden = TestSupport.staticAttributes()
        overridden.popBehavior = .overridden
        rootVC.configure(entryView: TestSupport.entryView(attributes: overridden))

        var animated = TestSupport.staticAttributes()
        animated.popBehavior = .animated(animation: .translation)
        rootVC.configure(entryView: TestSupport.entryView(attributes: animated))
    }

    @Test func animateOutAndPopLastEntry() async {
        let (rootVC, _) = makeRootVC()
        rootVC.configure(entryView: TestSupport.entryView(attributes: TestSupport.staticAttributes()))

        rootVC.animateOutLastEntry()
        await TestSupport.spinRunLoop()
        #expect(!rootVC.view.subviews.contains { $0 is EKContentView })
    }

    @Test func popLastEntry() {
        let (rootVC, _) = makeRootVC()
        rootVC.configure(entryView: TestSupport.entryView(attributes: TestSupport.staticAttributes()))
        rootVC.popLastEntry()
    }

    @Test func touchesEndedDismissAndCustomActions() {
        let (rootVC, _) = makeRootVC()
        var attributes = TestSupport.staticAttributes()
        attributes.screenInteraction = .dismiss
        var customTapped = false
        attributes.screenInteraction.customTapActions = [{ customTapped = true }]
        rootVC.configure(entryView: TestSupport.entryView(attributes: attributes))

        rootVC.touchesEnded([], with: nil)
        #expect(customTapped)
    }

    @Test func didFinishDisplayingNotifiesDelegate() {
        let (rootVC, delegate) = makeRootVC()
        let entryView = TestSupport.entryView(attributes: TestSupport.staticAttributes())

        rootVC.didFinishDisplaying(entry: entryView, keepWindowActive: true, dismissCompletionHandler: nil)
        #expect(delegate.displayPendingCount == 0)

        rootVC.didFinishDisplaying(entry: entryView, keepWindowActive: false, dismissCompletionHandler: nil)
        #expect(delegate.displayPendingCount == 1)
    }

    @Test func didFinishDisplayingWhileDisplayingIsIgnored() {
        let (rootVC, delegate) = makeRootVC()
        rootVC.configure(entryView: TestSupport.entryView(attributes: TestSupport.staticAttributes()))
        rootVC.didFinishDisplaying(entry: TestSupport.entryView(), keepWindowActive: false, dismissCompletionHandler: nil)
        #expect(delegate.displayPendingCount == 0)
    }

    @Test func backgroundTransitions() {
        let (rootVC, _) = makeRootVC()
        var attributes = TestSupport.staticAttributes()
        attributes.screenBackground = .color(color: .black)

        rootVC.changeToActive(withAttributes: attributes)

        rootVC.changeToInactive(withAttributes: attributes, pushOut: false)
        rootVC.changeToInactive(withAttributes: attributes, pushOut: true)

        rootVC.configure(entryView: TestSupport.entryView(attributes: attributes))
        rootVC.changeToInactive(withAttributes: attributes, pushOut: true)

        var different = attributes
        different.screenBackground = .color(color: .white)
        rootVC.changeToInactive(withAttributes: different, pushOut: true)

        rootVC.view.addSubview(UIView())
        rootVC.changeToInactive(withAttributes: different, pushOut: true)
    }

    @Test func statusBarOverrides() {
        let (rootVC, _) = makeRootVC()

        var dark = TestSupport.staticAttributes()
        dark.statusBar = .dark
        rootVC.setStatusBarStyle(for: dark)
        #expect(rootVC.preferredStatusBarStyle == .darkContent)
        #expect(!rootVC.prefersStatusBarHidden)

        var light = dark
        light.statusBar = .light
        rootVC.setStatusBarStyle(for: light)
        #expect(rootVC.preferredStatusBarStyle == .lightContent)

        var hidden = dark
        hidden.statusBar = .hidden
        rootVC.setStatusBarStyle(for: hidden)
        #expect(rootVC.prefersStatusBarHidden)

        var ignored = dark
        ignored.statusBar = .ignored
        rootVC.setStatusBarStyle(for: ignored)
        _ = rootVC.preferredStatusBarStyle
        _ = rootVC.prefersStatusBarHidden

        rootVC.viewWillDisappear(false)
    }

    @Test func rotationOptions() {
        let (rootVC, _) = makeRootVC()
        #expect(rootVC.shouldAutorotate)
        _ = rootVC.supportedInterfaceOrientations

        var disabled = TestSupport.staticAttributes()
        disabled.positionConstraints.rotation.isEnabled = false
        disabled.positionConstraints.rotation.supportedInterfaceOrientations = .all
        rootVC.configure(entryView: TestSupport.entryView(attributes: disabled))
        #expect(!rootVC.shouldAutorotate)
        #expect(rootVC.supportedInterfaceOrientations == .all)
    }
}
