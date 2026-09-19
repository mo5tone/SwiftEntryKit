//
//  AttributeEnumTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct AttributeEnumTests {
    // MARK: - BackgroundStyle

    @Test func blurStylePresets() {
        #expect(EKAttributes.BackgroundStyle.BlurStyle.extra == .init(light: .extraLight, dark: .dark))
        #expect(EKAttributes.BackgroundStyle.BlurStyle.standard == .init(light: .light, dark: .dark))
        #expect(EKAttributes.BackgroundStyle.BlurStyle.prominent == .init(light: .prominent, dark: .prominent))
        #expect(EKAttributes.BackgroundStyle.BlurStyle.dark == .init(light: .dark, dark: .dark))
        #expect(EKAttributes.BackgroundStyle.BlurStyle(style: .regular) == .init(light: .regular, dark: .regular))
    }

    @Test func blurStyleResolvesByModeAndTraits() {
        let style = EKAttributes.BackgroundStyle.BlurStyle(light: .light, dark: .dark)
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        #expect(style.blurStyle(for: lightTraits, mode: .inferred) == .light)
        #expect(style.blurStyle(for: darkTraits, mode: .inferred) == .dark)
        #expect(style.blurStyle(for: darkTraits, mode: .light) == .light)
        #expect(style.blurStyle(for: lightTraits, mode: .dark) == .dark)
        _ = style.blurEffect(for: lightTraits, mode: .light)
    }

    @Test func backgroundStyleEquality() {
        #expect(EKAttributes.BackgroundStyle.clear == .clear)
        #expect(EKAttributes.BackgroundStyle.color(color: .white) == .color(color: .white))
        #expect(EKAttributes.BackgroundStyle.color(color: .white) != .color(color: .black))
        #expect(EKAttributes.BackgroundStyle.visualEffect(style: .standard) == .visualEffect(style: .standard))
        #expect(EKAttributes.BackgroundStyle.visualEffect(style: .standard) != .visualEffect(style: .dark))

        let image = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { _ in }
        #expect(EKAttributes.BackgroundStyle.image(image: image) == .image(image: image))
        #expect(EKAttributes.BackgroundStyle.image(image: image) != .clear)

        let gradient = EKAttributes.BackgroundStyle.Gradient(colors: [.white, .black], startPoint: .zero, endPoint: .init(x: 1, y: 1))
        let sameGradient = EKAttributes.BackgroundStyle.Gradient(colors: [.white, .black], startPoint: .zero, endPoint: .init(x: 1, y: 1))
        let otherGradient = EKAttributes.BackgroundStyle.Gradient(colors: [.white, .clear], startPoint: .zero, endPoint: .init(x: 1, y: 1))
        #expect(EKAttributes.BackgroundStyle.gradient(gradient: gradient) == .gradient(gradient: sameGradient))
        #expect(EKAttributes.BackgroundStyle.gradient(gradient: gradient) != .gradient(gradient: otherGradient))
        #expect(EKAttributes.BackgroundStyle.gradient(gradient: gradient) != .color(color: .white))
    }

    // MARK: - StatusBar

    @Test func statusBarAppearance() {
        #expect(EKAttributes.StatusBar.dark.appearance.visible)
        #expect(EKAttributes.StatusBar.dark.appearance.style == .darkContent)
        #expect(EKAttributes.StatusBar.light.appearance.style == .lightContent)
        #expect(!EKAttributes.StatusBar.hidden.appearance.visible)
        #expect(EKAttributes.StatusBar.inferred.appearance.style == EKAttributes.StatusBar.currentAppearance.style)
    }

    @Test func statusBarFromAppearance() {
        #expect(EKAttributes.StatusBar.statusBar(by: (visible: false, style: .default)) == .hidden)
        #expect(EKAttributes.StatusBar.statusBar(by: (visible: true, style: .lightContent)) == .light)
        #expect(EKAttributes.StatusBar.statusBar(by: (visible: true, style: .default)) == .dark)
    }

    @Test func currentStatusBar() {
        _ = EKAttributes.StatusBar.currentStatusBar
        _ = EKAttributes.StatusBar.currentAppearance
    }

    // MARK: - FrameStyle

    @Test func roundCorners() {
        #expect(!EKAttributes.RoundCorners.none.hasRoundCorners)
        #expect(EKAttributes.RoundCorners.all(radius: 8).hasRoundCorners)
        #expect(EKAttributes.RoundCorners.top(radius: 8).hasRoundCorners)
        #expect(EKAttributes.RoundCorners.bottom(radius: 8).hasRoundCorners)

        #expect(EKAttributes.RoundCorners.none.cornerValues == nil)
        #expect(EKAttributes.RoundCorners.all(radius: 8).cornerValues?.value == .allCorners)
        #expect(EKAttributes.RoundCorners.all(radius: 8).cornerValues?.radius == 8)
        #expect(EKAttributes.RoundCorners.top(radius: 4).cornerValues?.value == .top)
        #expect(EKAttributes.RoundCorners.bottom(radius: 4).cornerValues?.value == .bottom)
    }

    @Test func border() {
        #expect(!EKAttributes.Border.none.hasBorder)
        #expect(EKAttributes.Border.value(color: .red, width: 2).hasBorder)
        #expect(EKAttributes.Border.none.borderValues == nil)
        #expect(EKAttributes.Border.value(color: .red, width: 2).borderValues?.color == .red)
        #expect(EKAttributes.Border.value(color: .red, width: 2).borderValues?.width == 2)
    }

    // MARK: - Animation

    @Test func animationComposition() {
        let translate = EKAttributes.Animation.Translate(duration: 0.3, anchorPosition: .top, delay: 0.1)
        let fade = EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.2, delay: 0.05)
        let scale = EKAttributes.Animation.RangeAnimation(from: 0.5, to: 1, duration: 0.4, delay: 0.2, spring: .init(damping: 0.8, initialVelocity: 2))

        let animation = EKAttributes.Animation(translate: translate, scale: scale, fade: fade)
        #expect(animation.containsTranslation)
        #expect(animation.containsScale)
        #expect(animation.containsFade)
        #expect(animation.containsAnimation)
        #expect(animation.maxDelay == 0.2)
        #expect(animation.maxDuration == 0.4)
        #expect(abs(animation.totalDuration - 0.6) < 0.0001)

        #expect(!EKAttributes.Animation.none.containsAnimation)
        #expect(EKAttributes.Animation.translation.containsTranslation)
    }

    @Test func translateAnchorPositions() {
        #expect(EKAttributes.Animation.Translate(duration: 0.1).anchorPosition == .automatic)
        #expect(EKAttributes.Animation.Translate(duration: 0.1, anchorPosition: .bottom).anchorPosition == .bottom)
        #expect(EKAttributes.Animation.Translate(duration: 0.1, spring: .init(damping: 1, initialVelocity: 0)).spring != nil)
    }

    // MARK: - Scroll

    @Test func scrollFlags() {
        #expect(!EKAttributes.Scroll.disabled.isEnabled)
        #expect(!EKAttributes.Scroll.disabled.isSwipeable)
        #expect(EKAttributes.Scroll.disabled.isEdgeCrossingEnabled)

        #expect(EKAttributes.Scroll.edgeCrossingDisabled(swipeable: true).isEnabled)
        #expect(EKAttributes.Scroll.edgeCrossingDisabled(swipeable: true).isSwipeable)
        #expect(!EKAttributes.Scroll.edgeCrossingDisabled(swipeable: true).isEdgeCrossingEnabled)
        #expect(!EKAttributes.Scroll.edgeCrossingDisabled(swipeable: false).isSwipeable)

        let enabled = EKAttributes.Scroll.enabled(swipeable: true, pullbackAnimation: .jolt)
        #expect(enabled.isEnabled)
        #expect(enabled.isSwipeable)
        #expect(enabled.isEdgeCrossingEnabled)
    }

    @Test func pullbackAnimationPresets() {
        #expect(EKAttributes.Scroll.PullbackAnimation.jolt.duration == 0.5)
        #expect(EKAttributes.Scroll.PullbackAnimation.jolt.damping == 0.3)
        #expect(EKAttributes.Scroll.PullbackAnimation.easeOut.duration == 0.3)
        #expect(EKAttributes.Scroll.PullbackAnimation.easeOut.initialSpringVelocity == 10)
    }

    // MARK: - UserInteraction

    @Test func userInteractionFlags() {
        #expect(!EKAttributes.UserInteraction.forward.isResponsive)
        #expect(EKAttributes.UserInteraction.absorbTouches.isResponsive)
        #expect(EKAttributes.UserInteraction.dismiss.isResponsive)
        #expect(EKAttributes.UserInteraction.delayExit(by: 1).isResponsive)
        #expect(EKAttributes.UserInteraction.delayExit(by: 1).isDelayExit)
        #expect(!EKAttributes.UserInteraction.dismiss.isDelayExit)
    }

    // MARK: - PopBehavior

    @Test func popBehavior() {
        #expect(EKAttributes.PopBehavior.overridden.isOverriden)
        #expect(!EKAttributes.PopBehavior.animated(animation: .translation).isOverriden)
        #expect(EKAttributes.PopBehavior.animated(animation: .translation).animation != nil)
        #expect(EKAttributes.PopBehavior.overridden.animation == nil)
        EKAttributes.PopBehavior.animated(animation: .none).validate()
    }

    // MARK: - PositionConstraints

    @Test func safeArea() {
        #expect(EKAttributes.PositionConstraints.SafeArea.overridden.isOverridden)
        #expect(!EKAttributes.PositionConstraints.SafeArea.empty(fillSafeArea: true).isOverridden)
    }

    @Test func edgeAndSizePresets() {
        if case let .offset(value) = EKAttributes.PositionConstraints.Edge.fill {
            #expect(value == 0)
        } else {
            Issue.record("fill should be .offset(0)")
        }
        guard case .intrinsic = EKAttributes.PositionConstraints.Size.intrinsic.width,
              case .intrinsic = EKAttributes.PositionConstraints.Size.intrinsic.height
        else {
            Issue.record("intrinsic size should use intrinsic edges")
            return
        }
        guard case .offset(value: 0) = EKAttributes.PositionConstraints.Size.screen.width,
              case .offset(value: 0) = EKAttributes.PositionConstraints.Size.screen.height
        else {
            Issue.record("screen size should use fill edges")
            return
        }
        guard case .offset(value: 0) = EKAttributes.PositionConstraints.Size.sizeToWidth.width,
              case .intrinsic = EKAttributes.PositionConstraints.Size.sizeToWidth.height
        else {
            Issue.record("sizeToWidth should be offset width and intrinsic height")
            return
        }
    }

    @Test func keyboardRelation() {
        #expect(EKAttributes.PositionConstraints.KeyboardRelation.unbind.isBound == false)
        #expect(EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: .none).isBound)
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        #expect(offset.bottom == 10)
        #expect(offset.screenEdgeResistance == 20)
        #expect(EKAttributes.PositionConstraints.KeyboardRelation.Offset.none.bottom == 0)
    }

    @Test func positionConstraintsPresets() {
        #expect(EKAttributes.PositionConstraints.float.verticalOffset == 10)
        #expect(!EKAttributes.PositionConstraints.fullWidth.hasVerticalOffset)
        #expect(EKAttributes.PositionConstraints.float.hasVerticalOffset)
        guard case .offset(value: 0) = EKAttributes.PositionConstraints.fullScreen.size.height else {
            Issue.record("fullScreen should fill height")
            return
        }

        var constraints = EKAttributes.PositionConstraints()
        constraints.rotation.isEnabled = false
        constraints.keyboardRelation = .bind(offset: .none)
        constraints.safeArea = .overridden
        #expect(!constraints.rotation.isEnabled)
        #expect(constraints.keyboardRelation.isBound)
        #expect(constraints.safeArea.isOverridden)
    }

    // MARK: - Shadow & Haptic

    @Test func shadowValue() {
        let value = EKAttributes.Shadow.Value(color: EKColor(.red), opacity: 0.5, radius: 4, offset: .init(width: 1, height: 2))
        #expect(value.radius == 4)
        #expect(value.opacity == 0.5)
        #expect(value.offset == .init(width: 1, height: 2))
        _ = EKAttributes.Shadow.none
    }

    @Test func hapticFeedbackValues() {
        #expect(EKAttributes.NotificationHapticFeedback.success.value == .success)
        #expect(EKAttributes.NotificationHapticFeedback.warning.value == .warning)
        #expect(EKAttributes.NotificationHapticFeedback.error.value == .error)
        #expect(EKAttributes.NotificationHapticFeedback.none.value == nil)
        #expect(EKAttributes.NotificationHapticFeedback.success.isValid)
        #expect(!EKAttributes.NotificationHapticFeedback.none.isValid)
    }
}
