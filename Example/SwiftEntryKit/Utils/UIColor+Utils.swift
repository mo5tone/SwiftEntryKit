//
//  UIColor+Utils.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/20/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import SwiftEntryKit
import UIKit

extension UIColor {
    static func by(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor {
        let maxComponent = CGFloat(255)
        return UIColor(red: CGFloat(red) / maxComponent, green: CGFloat(green) / maxComponent, blue: CGFloat(blue) / maxComponent, alpha: alpha)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    var ekColor: EKColor {
        EKColor(self)
    }

    static let dimmedLightBackground = UIColor(white: 100.0 / 255.0, alpha: 0.3)
    static let dimmedDarkBackground = UIColor(white: 50.0 / 255.0, alpha: 0.3)
    static let dimmedDarkestBackground = UIColor(white: 0, alpha: 0.5)

    static let pinky = UIColor(rgb: 0xE91E63)
    static let amber = UIColor(rgb: 0xFFC107)
    static let satCyan = UIColor(rgb: 0x00BCD4)
    static let redish = UIColor(rgb: 0xFF5252)
    static let greenGrass = UIColor(rgb: 0x4CAF50)

    static let chatMessageLightMode = UIColor(red: 48, green: 47, blue: 48)
    static let chatMessageDarkMode = UIColor(red: 207, green: 208, blue: 207)

    static let textLightMode = UIColor(red: 33, green: 33, blue: 33)
    static let textDarkMode = UIColor(red: 222, green: 222, blue: 222)

    static let subTextLightMode = UIColor(red: 117, green: 117, blue: 117)
    static let subTextDarkMode = UIColor(red: 138, green: 138, blue: 138)

    static let musicBackgroundDark = UIColor(red: 36, green: 39, blue: 42)
    static let musicRedish = UIColor(red: 219, green: 58, blue: 94)

    static let lightNavigationBarBackground = UIColor(red: 251, green: 251, blue: 253)

    static let darkHeaderBackground = UIColor(red: 25, green: 26, blue: 25)

    static let darkSegmentedControl = UIColor(red: 55, green: 71, blue: 79)
}

extension EKColor {
    static var segmentedControlTint: EKColor {
        EKColor(.gray)
    }

    static var navigationItemColor: EKColor {
        EKColor(light: .gray,
                dark: .musicRedish)
    }

    static var navigationBackgroundColor: EKColor {
        EKColor(light: .lightNavigationBarBackground,
                dark: .black)
    }

    static var headerBackground: EKColor {
        EKColor(light: Color.BlueGray.c50.with(alpha: 0.95).light,
                dark: .darkHeaderBackground)
    }

    static var headerText: EKColor {
        EKColor(.white).with(alpha: 0.95)
    }

    static var satCyan: EKColor {
        EKColor(.satCyan)
    }

    static var amber: EKColor {
        EKColor(.amber)
    }

    static var pinky: EKColor {
        EKColor(.pinky)
    }

    static var greenGrass: EKColor {
        EKColor(.greenGrass)
    }

    static var redish: EKColor {
        EKColor(.redish)
    }

    static var ratingStar: EKColor {
        EKColor(light: .amber,
                dark: .musicRedish)
    }

    static var musicBackground: EKColor {
        EKColor(light: .white,
                dark: .musicBackgroundDark)
    }

    static var musicText: EKColor {
        EKColor(light: .black,
                dark: .musicRedish)
    }

    static var selectedBackground: EKColor {
        EKColor(light: UIColor(white: 0.9, alpha: 1),
                dark: UIColor(white: 0.1, alpha: 1))
    }

    static var dimmedDarkBackground: EKColor {
        EKColor(light: .dimmedDarkBackground,
                dark: .dimmedDarkestBackground)
    }

    static var dimmedLightBackground: EKColor {
        EKColor(light: .dimmedLightBackground,
                dark: .dimmedDarkestBackground)
    }

    static var chatMessage: EKColor {
        EKColor(light: .chatMessageLightMode,
                dark: .chatMessageLightMode)
    }

    static var text: EKColor {
        EKColor(light: .textLightMode,
                dark: .textDarkMode)
    }

    static var subText: EKColor {
        EKColor(light: .subTextLightMode,
                dark: .subTextDarkMode)
    }
}

enum Color {
    enum BlueGray {
        static let c50 = EKColor(rgb: 0xECEFF1)
        static let c100 = EKColor(rgb: 0xCFD8DC)
        static let c300 = EKColor(rgb: 0x90A4AE)
        static let c400 = EKColor(rgb: 0x78909C)
        static let c700 = EKColor(rgb: 0x455A64)
        static let c800 = EKColor(rgb: 0x37474F)
        static let c900 = EKColor(rgb: 0x263238)
    }

    enum Netflix {
        static let light = EKColor(rgb: 0x485563)
        static let dark = EKColor(rgb: 0x29323C)
    }

    enum Gray {
        static let a800 = EKColor(rgb: 0x424242)
        static let mid = EKColor(rgb: 0x616161)
        static let light = EKColor(red: 230, green: 230, blue: 230)
    }

    enum Purple {
        static let a300 = EKColor(rgb: 0xBA68C8)
        static let a400 = EKColor(rgb: 0xAB47BC)
        static let a700 = EKColor(rgb: 0xAA00FF)
        static let deep = EKColor(rgb: 0x673AB7)
    }

    enum BlueGradient {
        static let light = EKColor(red: 100, green: 172, blue: 196)
        static let dark = EKColor(red: 27, green: 47, blue: 144)
    }

    enum Yellow {
        static let a700 = EKColor(rgb: 0xFFD600)
    }

    enum Teal {
        static let a700 = EKColor(rgb: 0x00BFA5)
        static let a600 = EKColor(rgb: 0x00897B)
    }

    enum Orange {
        static let a50 = EKColor(rgb: 0xFFF3E0)
    }

    enum LightBlue {
        static let a700 = EKColor(rgb: 0x0091EA)
    }

    enum LightPink {
        static let first = EKColor(rgb: 0xFF9A9E)
        static let last = EKColor(rgb: 0xFAD0C4)
    }
}
