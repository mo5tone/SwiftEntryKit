//
//  HapticFeedbackGenerator.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/20/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

struct HapticFeedbackGenerator {
    @MainActor
    static func notification(type: EKAttributes.NotificationHapticFeedback) {
        guard let value = type.value else {
            return
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(value)
    }
}
