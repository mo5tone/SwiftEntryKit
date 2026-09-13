//
//  EKColorTests.swift
//  SwiftEntryKitTests
//

import Testing
import UIKit
@testable import SwiftEntryKit

@MainActor
struct EKColorTests {

    @Test func inferredResolvesByInterfaceStyle() {
        let color = EKColor(light: .white, dark: .black)

        #expect(color.color(for: UITraitCollection(userInterfaceStyle: .light), mode: .inferred) == .white)
        #expect(color.color(for: UITraitCollection(userInterfaceStyle: .dark), mode: .inferred) == .black)
    }

    @Test func explicitModesOverrideStyle() {
        let color = EKColor(light: .white, dark: .black)

        #expect(color.color(for: UITraitCollection(userInterfaceStyle: .dark), mode: .light) == .white)
        #expect(color.color(for: UITraitCollection(userInterfaceStyle: .light), mode: .dark) == .black)
    }

    @Test func invertedSwapsColors() {
        let color = EKColor(light: .white, dark: .black).inverted
        #expect(color.light == .black)
        #expect(color.dark == .white)
    }

    @Test func standardColors() {
        #expect(EKColor.standardBackground.light == .white)
        #expect(EKColor.standardBackground.dark == .black)
        #expect(EKColor.standardContent.light == .black)
        #expect(EKColor.standardContent.dark == .white)
    }
}
