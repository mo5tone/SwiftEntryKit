//
//  AttributesPresetsTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct AttributesPresetsTests {
    @Test func toastPreset() {
        let attributes = EKAttributes.toast
        #expect(attributes.windowLevel.value == .statusBar)
        #expect(attributes.position.isTop)
        guard case .empty(fillSafeArea: true) = attributes.positionConstraints.safeArea else {
            Issue.record("toast safeArea should be .empty(fillSafeArea: true)")
            return
        }
        guard case .edgeCrossingDisabled(swipeable: true) = attributes.scroll else {
            Issue.record("toast scroll should be .edgeCrossingDisabled(swipeable: true)")
            return
        }
    }

    @Test func floatPreset() {
        let attributes = EKAttributes.float
        #expect(attributes.windowLevel.value == .statusBar)
        #expect(attributes.position.isTop)
        guard case .all(radius: 10) = attributes.roundCorners else {
            Issue.record("float roundCorners should be .all(radius: 10)")
            return
        }
        guard case .empty(fillSafeArea: false) = attributes.positionConstraints.safeArea else {
            Issue.record("float safeArea should be .empty(fillSafeArea: false)")
            return
        }
    }

    @Test func floatPositions() {
        #expect(EKAttributes.topFloat.position.isTop)
        #expect(EKAttributes.bottomFloat.position.isBottom)
        #expect(EKAttributes.centerFloat.position.isCenter)
    }

    @Test func toastPositions() {
        #expect(EKAttributes.topToast.position.isTop)
        #expect(EKAttributes.bottomToast.position.isBottom)
    }

    @Test func notePresets() {
        let top = EKAttributes.topNote
        #expect(top.windowLevel.value == .normal)
        #expect(top.position.isTop)
        guard case .disabled = top.scroll else {
            Issue.record("topNote scroll should be .disabled")
            return
        }
        guard case .absorbTouches = top.entryInteraction.defaultAction else {
            Issue.record("topNote entryInteraction should be .absorbTouches")
            return
        }

        #expect(EKAttributes.bottomNote.position.isBottom)
    }

    @Test func statusBarPreset() {
        let attributes = EKAttributes.statusBar
        #expect(attributes.windowLevel.value == .statusBar)
        guard case .absorbTouches = attributes.entryInteraction.defaultAction else {
            Issue.record("statusBar entryInteraction should be .absorbTouches")
            return
        }
        guard case .overridden = attributes.positionConstraints.safeArea else {
            Issue.record("statusBar safeArea should be .overridden")
            return
        }
    }
}
