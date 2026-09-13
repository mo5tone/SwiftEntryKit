//
//  EKAttributes+Precedence.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/29/18.
//

import Foundation

private extension Int {
    var isValidDisplayPriority: Bool {
        self >= EKAttributes.Precedence.Priority.minRawValue && self <= EKAttributes.Precedence.Priority.maxRawValue
    }
}

public extension EKAttributes {
    /**
     Describes the manner on which the entry is pushed and displayed.
     See the various values of more explanation.
     */
    enum Precedence {
        /**
         The display priority of the entry - Determines whether is can be overriden by other entries.
         Must be in range [0...1000]
         */
        public struct Priority: Hashable, Equatable, RawRepresentable, Comparable, @unchecked Sendable {
            public var rawValue: Int

            public func hash(into hasher: inout Hasher) {
                hasher.combine(rawValue)
            }

            public init(_ rawValue: Int) {
                assert(rawValue.isValidDisplayPriority, "Display Priority must be in range [\(Self.minRawValue)...\(Self.maxRawValue)]")
                self.rawValue = rawValue
            }

            public init(rawValue: Int) {
                assert(rawValue.isValidDisplayPriority, "Display Priority must be in range [\(Self.minRawValue)...\(Self.maxRawValue)]")
                self.rawValue = rawValue
            }

            public static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.rawValue < rhs.rawValue
            }
        }

        /**
         Describes the queueing heoristic of entries.
         */
        public enum QueueingHeuristic {
            /** Determines the heuristic which the entry-queue is based on */
            public nonisolated(unsafe) static var value = Self.priority

            /** Chronological - FIFO */
            case chronological

            /** Ordered by priority */
            case priority

            /** Returns the caching heuristics mechanism that determines the priority in queue */
            @MainActor
            var heuristic: EntryCachingHeuristic {
                switch self {
                case .chronological:
                    EKEntryChronologicalQueue()

                case .priority:
                    EKEntryPriorityQueue()
                }
            }
        }

        /**
         Describes an *overriding* behavior for a new entry.
         - In case no previous entry is currently presented, display the new entry.
         - In case there is an entry that is currently presented - override it using the new entry. Also optionally drop all previously enqueued entries.
         */
        case override(priority: Priority, dropEnqueuedEntries: Bool)

        /**
         Describes a FIFO behavior for an entry presentation.
         - In case no previous entry is currently presented, display the new entry.
         - In case there is an entry that is currently presented - enqueue the new entry, an present it just after the previous one is dismissed.
         */
        case enqueue(priority: Priority)

        var isEnqueue: Bool {
            switch self {
            case .enqueue:
                true

            default:
                false
            }
        }

        /** Setter / Getter for the display priority */
        public var priority: Priority {
            set {
                switch self {
                case .enqueue:
                    self = .enqueue(priority: newValue)

                case .override(priority: _, dropEnqueuedEntries: let dropEnqueuedEntries):
                    self = .override(priority: newValue, dropEnqueuedEntries: dropEnqueuedEntries)
                }
            }
            get {
                switch self {
                case let .enqueue(priority: priority):
                    priority

                case .override(priority: let priority, dropEnqueuedEntries: _):
                    priority
                }
            }
        }
    }
}

/** High priority entries can be overriden by other equal or higher priority entries only.
 Entries are ignored as a higher priority entry is being displayed.
 High priority entry overrides any other entry including another equal priority one.
 You can you on of the values (.max, high, normal, low, min) and also set your own values. */
public extension EKAttributes.Precedence.Priority {
    static let maxRawValue = 1000
    static let highRawValue = 750
    static let normalRawValue = 500
    static let lowRawValue = 250
    static let minRawValue = 0

    /** Max - the highest possible priority of an entry. Can override only entries with *max* priority */
    static let max = EKAttributes.Precedence.Priority(rawValue: maxRawValue)
    static let high = EKAttributes.Precedence.Priority(rawValue: highRawValue)
    static let normal = EKAttributes.Precedence.Priority(rawValue: normalRawValue)
    static let low = EKAttributes.Precedence.Priority(rawValue: lowRawValue)
    static let min = EKAttributes.Precedence.Priority(rawValue: minRawValue)
}
