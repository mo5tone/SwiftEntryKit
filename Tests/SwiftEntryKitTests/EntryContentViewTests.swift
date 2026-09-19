//
//  EntryContentViewTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct EntryContentViewTests {
    private final class MockPanGestureRecognizer: UIPanGestureRecognizer {
        var mockTranslation: CGPoint = .zero
        var mockVelocity: CGPoint = .zero
        private var mockState: UIGestureRecognizer.State = .possible

        override var state: UIGestureRecognizer.State {
            get { mockState }
            set { mockState = newValue }
        }

        override func translation(in _: UIView?) -> CGPoint {
            mockTranslation
        }

        override func velocity(in _: UIView?) -> CGPoint {
            mockVelocity
        }
    }

    @discardableResult
    private func makeContent(_ attributes: EKAttributes) -> (EKContentView, TestEntryContentViewDelegate) {
        let delegate = TestEntryContentViewDelegate()
        TestSupport.retain(delegate)
        let content = EKContentView(withEntryDelegate: delegate)
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        TestSupport.retain(host)
        host.addSubview(content)
        content.setup(with: TestSupport.entryView(attributes: attributes))
        return (content, delegate)
    }

    // MARK: - Setup matrix

    @Test func setupEveryPosition() {
        for position in [EKAttributes.Position.top, .bottom, .center] {
            var attributes = TestSupport.staticAttributes(position: position)
            attributes.positionConstraints.verticalOffset = 10
            let (_, delegate) = makeContent(attributes)
            #expect(delegate.changeToActiveCount == 1)
        }
    }

    @Test func setupEverySizeEdge() {
        let sizes: [EKAttributes.PositionConstraints.Size] = [
            .init(width: .offset(value: 10), height: .offset(value: 10)),
            .init(width: .ratio(value: 0.5), height: .ratio(value: 0.5)),
            .init(width: .constant(value: 100), height: .constant(value: 100)),
            .intrinsic,
        ]
        for size in sizes {
            var attributes = TestSupport.staticAttributes()
            attributes.positionConstraints.size = size
            makeContent(attributes)
        }
    }

    @Test func setupEveryMaxSizeEdge() {
        let sizes: [EKAttributes.PositionConstraints.Size] = [
            .init(width: .offset(value: 10), height: .offset(value: 10)),
            .init(width: .ratio(value: 0.9), height: .ratio(value: 0.9)),
            .init(width: .constant(value: 300), height: .constant(value: 300)),
            .intrinsic,
        ]
        for size in sizes {
            var attributes = TestSupport.staticAttributes()
            attributes.positionConstraints.maxSize = size
            makeContent(attributes)
        }
    }

    @Test func setupSafeAreaVariants() {
        var attributes = TestSupport.staticAttributes()
        attributes.positionConstraints.safeArea = .overridden
        makeContent(attributes)

        attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
        makeContent(attributes)
    }

    @Test func setupKeyboardBindings() {
        var attributes = TestSupport.staticAttributes()
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 5, screenEdgeResistance: 10))
        makeContent(attributes)

        attributes.positionConstraints.keyboardRelation = .bind(offset: .none)
        makeContent(attributes)
    }

    @Test func setupTapGestureIsSkippedWhenForwarding() {
        var attributes = TestSupport.staticAttributes()
        attributes.entryInteraction = .forward
        makeContent(attributes)
    }

    @Test func setupHapticFeedback() {
        var attributes = TestSupport.staticAttributes()
        attributes.hapticFeedbackType = .success
        makeContent(attributes)
    }

    // MARK: - Animations

    @Test func animateInAndOutWithAllAnimations() async {
        var attributes = TestSupport.staticAttributes()
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0, anchorPosition: .top),
            scale: .init(from: 0.5, to: 1, duration: 0),
            fade: .init(from: 0, to: 1, duration: 0)
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0, anchorPosition: .bottom, spring: .init(damping: 0.8, initialVelocity: 1)),
            scale: .init(from: 1, to: 0.5, duration: 0),
            fade: .init(from: 1, to: 0, duration: 0)
        )
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0)))

        let (content, delegate) = makeContent(attributes)
        content.animateOut(pushOut: true)
        await TestSupport.spinRunLoop()
        #expect(delegate.changeToInactiveCount == 1)
        #expect(delegate.lastPushOut == true)
    }

    @Test func animateOutAutomaticAnchorAndExit() async {
        var attributes = TestSupport.staticAttributes(position: .bottom)
        attributes.entranceAnimation = .init(translate: .init(duration: 0, anchorPosition: .automatic))
        attributes.exitAnimation = .init(translate: .init(duration: 0, anchorPosition: .automatic))

        let (content, delegate) = makeContent(attributes)
        content.animateOut(pushOut: false)
        await TestSupport.spinRunLoop()
        #expect(delegate.changeToInactiveCount == 1)
    }

    @Test func removePromptlyAndRemoveFromSuperview() {
        var attributes = TestSupport.staticAttributes()
        attributes.lifecycleEvents.willAppear = {}
        attributes.lifecycleEvents.didAppear = {}
        attributes.lifecycleEvents.willDisappear = {}
        attributes.lifecycleEvents.didDisappear = {}

        let (content, delegate) = makeContent(attributes)
        content.removePromptly(keepWindow: true)
        #expect(delegate.changeToInactiveCount == 1)
        #expect(delegate.didFinishCount == 1)
        #expect(delegate.lastKeepWindowActive == true)

        content.removeFromSuperview(keepWindow: false)
        #expect(delegate.didFinishCount == 1)
    }

    // MARK: - Tap and touches

    @Test func tapDismissesEntry() {
        var attributes = TestSupport.staticAttributes()
        attributes.entryInteraction = .dismiss
        let (content, delegate) = makeContent(attributes)
        content.tapGestureRecognized()
        #expect(delegate.changeToInactiveCount == 1)
    }

    @Test func tapDelayExitAndCustomActions() {
        var attributes = TestSupport.staticAttributes(displayDuration: 2)
        attributes.entryInteraction = .delayExit(by: 1)
        var customTapCount = 0
        attributes.entryInteraction.customTapActions = [{ customTapCount += 1 }]
        let (content, _) = makeContent(attributes)
        content.tapGestureRecognized()
        #expect(customTapCount == 1)
    }

    @Test func tapAbsorbDoesNothing() {
        var attributes = TestSupport.staticAttributes()
        attributes.entryInteraction = .absorbTouches
        let (content, delegate) = makeContent(attributes)
        content.tapGestureRecognized()
        #expect(delegate.changeToInactiveCount == 0)
    }

    @Test func touchesDelayExit() {
        var attributes = TestSupport.staticAttributes(displayDuration: 2)
        attributes.entryInteraction = .delayExit(by: 1)
        let (content, _) = makeContent(attributes)
        content.touchesBegan([], with: nil)
        content.touchesEnded([], with: nil)
        content.touchesCancelled([], with: nil)
    }

    // MARK: - Pan / swipe

    @Test func panStretchBranches() {
        var attributes = TestSupport.staticAttributes(position: .top)
        attributes.positionConstraints.verticalOffset = 10
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        let (content, _) = makeContent(attributes)

        let pan = MockPanGestureRecognizer()

        pan.mockTranslation = .init(x: 0, y: 20)
        pan.state = .changed
        content.panGestureRecognized(gestureRecognizer: pan)

        pan.state = .ended
        content.panGestureRecognized(gestureRecognizer: pan)
    }

    @Test func panBottomStretchAndLogarithmicOffset() {
        var attributes = TestSupport.staticAttributes(position: .bottom)
        attributes.positionConstraints.verticalOffset = 10
        let (content, _) = makeContent(attributes)

        let pan = MockPanGestureRecognizer()

        pan.mockTranslation = .init(x: 0, y: -30)
        pan.state = .changed
        content.panGestureRecognized(gestureRecognizer: pan)

        pan.mockTranslation = .init(x: 0, y: -1)
        content.panGestureRecognized(gestureRecognizer: pan)
    }

    @Test func panSwipeOutAndPullback() async {
        var attributes = TestSupport.staticAttributes(position: .top)
        attributes.positionConstraints.verticalOffset = 10
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        let (content, delegate) = makeContent(attributes)

        let pan = MockPanGestureRecognizer()

        pan.mockTranslation = .init(x: 0, y: -20)
        pan.state = .changed
        content.panGestureRecognized(gestureRecognizer: pan)

        pan.mockTranslation = .zero
        pan.mockVelocity = .init(x: 0, y: -100)
        pan.state = .ended
        content.panGestureRecognized(gestureRecognizer: pan)
        await TestSupport.spinRunLoop()
        #expect(delegate.changeToInactiveCount == 1)
    }

    @Test func panNotSwipeablePullsBack() {
        var attributes = TestSupport.staticAttributes(position: .bottom)
        attributes.positionConstraints.verticalOffset = 10
        attributes.scroll = .edgeCrossingDisabled(swipeable: false)
        let (content, _) = makeContent(attributes)

        let pan = MockPanGestureRecognizer()

        pan.mockTranslation = .init(x: 0, y: 20)
        pan.state = .ended
        content.panGestureRecognized(gestureRecognizer: pan)
    }

    @Test func panExitDelay() {
        var attributes = TestSupport.staticAttributes(displayDuration: 2)
        attributes.entryInteraction = .delayExit(by: 1)
        let (content, _) = makeContent(attributes)

        let pan = MockPanGestureRecognizer()

        pan.state = .began
        content.panGestureRecognized(gestureRecognizer: pan)
        pan.state = .ended
        content.panGestureRecognized(gestureRecognizer: pan)
    }

    // MARK: - Keyboard

    private func keyboardNotification(name: Notification.Name, valid: Bool = true) -> Notification {
        guard valid else {
            return Notification(name: name, object: nil, userInfo: nil)
        }
        let userInfo: [AnyHashable: Any] = [
            UIResponder.keyboardAnimationDurationUserInfoKey: 0.25,
            UIResponder.keyboardAnimationCurveUserInfoKey: UInt(7),
            UIResponder.keyboardFrameBeginUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 400, width: 320, height: 80)),
            UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 300, width: 320, height: 180)),
        ]
        return Notification(name: name, object: nil, userInfo: userInfo)
    }

    @Test func keyboardHideAndChangeWithoutResponder() {
        var attributes = TestSupport.staticAttributes()
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 5, screenEdgeResistance: 10))
        let (content, _) = makeContent(attributes)

        content.keyboardWillHide(keyboardNotification(name: UIResponder.keyboardWillHideNotification))
        content.keyboardWillHide(keyboardNotification(name: UIResponder.keyboardWillHideNotification, valid: false))
        content.keyboardDidHide(keyboardNotification(name: UIResponder.keyboardDidHideNotification))
        content.keyboardWillShow(keyboardNotification(name: UIResponder.keyboardWillShowNotification))
        content.keyboardWillChangeFrame(keyboardNotification(name: UIResponder.keyboardWillChangeFrameNotification))
    }

    @Test func keyboardShowWithFirstResponder() {
        var attributes = TestSupport.staticAttributes()
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 5, screenEdgeResistance: 10))

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let rootVC = UIViewController()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        let delegate = TestEntryContentViewDelegate()
        let content = EKContentView(withEntryDelegate: delegate)
        rootVC.view.addSubview(content)
        content.frame = rootVC.view.bounds

        let entryView = TestSupport.entryView(attributes: attributes)
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        entryView.addSubview(textField)
        content.setup(with: entryView)

        if textField.becomeFirstResponder() {
            content.keyboardWillShow(keyboardNotification(name: UIResponder.keyboardWillShowNotification))
            content.keyboardWillChangeFrame(keyboardNotification(name: UIResponder.keyboardWillChangeFrameNotification))
        }
    }
}
