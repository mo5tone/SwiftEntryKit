//
//  EKAttributes+FrameStyle.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/28/18.
//

import CoreGraphics
import Foundation
import UIKit

public extension EKAttributes {
    /** Corner radius of the entry - Specifies the corners */
    enum RoundCorners {
        /** *None* of the corners will be round */
        case none

        /** *All* of the corners will be round */
        case all(radius: CGFloat)

        /** Only the *top* left and right corners will be round */
        case top(radius: CGFloat)

        /** Only the *bottom* left and right corners will be round */
        case bottom(radius: CGFloat)

        var hasRoundCorners: Bool {
            switch self {
            case .none:
                false

            default:
                true
            }
        }

        var cornerValues: (value: UIRectCorner, radius: CGFloat)? {
            switch self {
            case let .all(radius: radius):
                (value: .allCorners, radius: radius)

            case let .top(radius: radius):
                (value: .top, radius: radius)

            case let .bottom(radius: radius):
                (value: .bottom, radius: radius)

            case .none:
                nil
            }
        }
    }

    /** The border around the entry */
    enum Border {
        /** No border */
        case none

        /** Border wirh color and width */
        case value(color: UIColor, width: CGFloat)

        var hasBorder: Bool {
            switch self {
            case .none:
                false

            default:
                true
            }
        }

        var borderValues: (color: UIColor, width: CGFloat)? {
            switch self {
            case let .value(color: color, width: width):
                (color: color, width: width)

            case .none:
                nil
            }
        }
    }
}
