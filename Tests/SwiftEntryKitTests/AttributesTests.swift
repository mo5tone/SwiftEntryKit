//
//  AttributesTests.swift
//  SwiftEntryKitTests
//

import Testing
import UIKit
@testable import SwiftEntryKit

@MainActor
struct AttributesTests {

    @Test func displayPriorityInitMax() {
        var attributes = EKAttributes()
        attributes.precedence.priority = .max
        #expect(attributes.precedence.priority == .max)
        #expect(attributes.precedence.priority.rawValue == EKAttributes.Precedence.Priority.maxRawValue)
    }

    @Test func displayPriorityInitHigh() {
        var attributes = EKAttributes()
        attributes.precedence.priority = .high
        #expect(attributes.precedence.priority == .high)
        #expect(attributes.precedence.priority.rawValue == EKAttributes.Precedence.Priority.highRawValue)
    }

    @Test func displayPriorityInitCustom() {
        var attributes = EKAttributes()

        let custom1 = EKAttributes.Precedence.override(priority: .init(999), dropEnqueuedEntries: true)
        attributes.precedence.priority = custom1.priority
        #expect(attributes.precedence.priority == custom1.priority)
        #expect(attributes.precedence.priority.rawValue == 999)

        let custom2 = EKAttributes.Precedence.override(priority: .init(1), dropEnqueuedEntries: true)
        attributes.precedence.priority = custom2.priority
        #expect(attributes.precedence.priority == custom2.priority)
        #expect(attributes.precedence.priority.rawValue == 1)
        #expect(custom2.priority < custom1.priority)
    }

    @Test func position() {
        var attributes = EKAttributes()
        attributes.position = .top
        #expect(attributes.position.isTop)
        attributes.position = .center
        #expect(attributes.position.isCenter)
        attributes.position = .bottom
        #expect(attributes.position.isBottom)
    }

    @Test func displayDurationValidation() {
        var attributes = EKAttributes()
        attributes.displayDuration = .infinity
        #expect(attributes.validateDisplayDuration)
        #expect(attributes.isValid)

        attributes.displayDuration = 1
        #expect(attributes.validateDisplayDuration)
        #expect(attributes.isValid)
    }

    @Test func windowLevelValidation() {
        var attributes = EKAttributes()

        attributes.windowLevel = .normal
        #expect(attributes.windowLevel.value == .normal)
        #expect(attributes.validateWindowLevel)
        #expect(attributes.isValid)

        attributes.windowLevel = .statusBar
        #expect(attributes.windowLevel.value == .statusBar)
        #expect(attributes.validateWindowLevel)

        attributes.windowLevel = .alerts
        #expect(attributes.windowLevel.value == .alert)
        #expect(attributes.validateWindowLevel)

        let level = UIWindow.Level(rawValue: 1)
        attributes.windowLevel = .custom(level: level)
        #expect(attributes.windowLevel.value == level)
        #expect(attributes.validateWindowLevel)

        attributes.windowLevel = .custom(level: .init(rawValue: -1))
        #expect(!attributes.validateWindowLevel)
        #expect(!attributes.isValid)
    }
}
