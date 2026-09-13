//
//  EKAttributes+HapticFeedback.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 5/1/18.
//

import UIKit

public extension EKAttributes {
    /** Notification haptic feedback type. Adds an additional sensuous layer. Read more at UINotificationFeedbackType. Available from iOS 10, but you are not required to check the iOS version before using it. It's automatically handled by the kit.
     */
    enum NotificationHapticFeedback {
        case success
        case warning
        case error
        case none

        var value: UINotificationFeedbackGenerator.FeedbackType? {
            switch self {
            case .success:
                .success

            case .warning:
                .warning

            case .error:
                .error

            case .none:
                nil
            }
        }

        var isValid: Bool {
            self != .none
        }
    }
}
