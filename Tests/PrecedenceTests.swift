//
//  PrecedenceTests.swift
//  SwiftEntryKitTests
//

import Testing
import UIKit
@testable import SwiftEntryKit

@MainActor
struct PrecedenceTests {

    @Test func priorityOrdering() {
        let min = EKAttributes.Precedence.Priority.min
        let low = EKAttributes.Precedence.Priority.low
        let normal = EKAttributes.Precedence.Priority.normal
        let high = EKAttributes.Precedence.Priority.high
        let max = EKAttributes.Precedence.Priority.max

        #expect(min.rawValue == EKAttributes.Precedence.Priority.minRawValue)
        #expect(max.rawValue == EKAttributes.Precedence.Priority.maxRawValue)
        #expect(min < low)
        #expect(low < normal)
        #expect(normal < high)
        #expect(high < max)
    }

    @Test func enqueuePrioritySetter() {
        var precedence = EKAttributes.Precedence.enqueue(priority: .normal)
        #expect(precedence.isEnqueue)
        #expect(precedence.priority == .normal)

        precedence.priority = .max
        #expect(precedence.priority == .max)
    }

    @Test func overridePrioritySetter() {
        var precedence = EKAttributes.Precedence.override(priority: .normal, dropEnqueuedEntries: false)
        #expect(!precedence.isEnqueue)
        #expect(precedence.priority == .normal)

        precedence.priority = .high
        #expect(precedence.priority == .high)
    }

    @Test func queueingHeuristicDefault() {
        #expect(EKAttributes.Precedence.QueueingHeuristic.value == .priority)
    }
}
