//
//  EKAttributes+Validations.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 5/18/18.
//

import Foundation

extension EKAttributes {
    private static var minDisplayDuration: DisplayDuration {
        0
    }

    var validateDisplayDuration: Bool {
        guard displayDuration >= Self.minDisplayDuration else {
            return false
        }
        return true
    }

    var validateWindowLevel: Bool {
        windowLevel.value >= .normal
    }

    var isValid: Bool {
        validateDisplayDuration && validateWindowLevel
    }
}
