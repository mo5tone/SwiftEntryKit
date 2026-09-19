//
//  EntryCachingHeuristicTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct EntryCachingHeuristicTests {
    private func cachedEntry(name: String? = nil, priority: EKAttributes.Precedence.Priority = .normal) -> CachedEntry {
        var attributes = TestSupport.staticAttributes()
        attributes.name = name
        attributes.precedence = .override(priority: priority, dropEnqueuedEntries: false)
        return CachedEntry(view: TestSupport.entryView(attributes: attributes), presentInsideKeyWindow: false, rollbackWindow: .main)
    }

    @Test func chronologicalQueueIsFIFO() {
        let queue = EKEntryChronologicalQueue()
        #expect(queue.isEmpty)
        #expect(queue.dequeue() == nil)

        let first = cachedEntry(name: "first")
        let second = cachedEntry(name: "second")
        queue.enqueue(entry: first)
        queue.enqueue(entry: second)

        #expect(!queue.isEmpty)
        #expect(queue.entries.count == 2)
        #expect(queue.dequeue()?.view.attributes.name == "first")
        #expect(queue.dequeue()?.view.attributes.name == "second")
        #expect(queue.isEmpty)
    }

    @Test func priorityQueueOrdersByDescendingPriority() {
        let queue = EKEntryPriorityQueue()
        queue.enqueue(entry: cachedEntry(name: "normal", priority: .normal))
        queue.enqueue(entry: cachedEntry(name: "high", priority: .high))
        queue.enqueue(entry: cachedEntry(name: "low", priority: .low))
        queue.enqueue(entry: cachedEntry(name: "max", priority: .max))

        #expect(queue.entries.map(\.view.attributes.name) == ["max", "high", "normal", "low"])
        #expect(queue.dequeue()?.view.attributes.name == "max")
    }

    @Test func containsEntryNamed() {
        let queue = EKEntryChronologicalQueue()
        queue.enqueue(entry: cachedEntry(name: "alpha"))
        #expect(queue.contains(entryNamed: "alpha"))
        #expect(!queue.contains(entryNamed: "beta"))
    }

    @Test func removeEntriesByName() {
        let queue = EKEntryChronologicalQueue()
        queue.enqueue(entry: cachedEntry(name: "alpha"))
        queue.enqueue(entry: cachedEntry(name: "beta"))
        queue.enqueue(entry: cachedEntry(name: "alpha"))
        queue.removeEntries(by: "alpha")
        #expect(queue.entries.count == 1)
        #expect(queue.entries.first?.view.attributes.name == "beta")
    }

    @Test func removeEntriesWithPriorityLowerOrEqualTo() {
        let queue = EKEntryPriorityQueue()
        queue.enqueue(entry: cachedEntry(name: "low", priority: .low))
        queue.enqueue(entry: cachedEntry(name: "normal", priority: .normal))
        queue.enqueue(entry: cachedEntry(name: "high", priority: .high))
        queue.removeEntries(withPriorityLowerOrEqualTo: .normal)
        #expect(queue.entries.count == 1)
        #expect(queue.entries.first?.view.attributes.name == "high")
    }

    @Test func removeAllEntries() {
        let queue = EKEntryChronologicalQueue()
        queue.enqueue(entry: cachedEntry())
        queue.removeAll()
        #expect(queue.isEmpty)
    }
}
