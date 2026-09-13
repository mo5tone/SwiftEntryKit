//
//  EKPropertyDefaultsTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct EKPropertyDefaultsTests {
    @Test func labelStyleDefaults() {
        let style = EKProperty.LabelStyle(font: .systemFont(ofSize: 14), color: .white)
        #expect(style.alignment == .left)
        #expect(style.numberOfLines == 0)
    }

    @Test func buttonContentDefaults() {
        let content = EKProperty.ButtonContent(
            label: .init(text: "OK", style: .init(font: .systemFont(ofSize: 14), color: .white)),
            backgroundColor: .white,
            highlightedBackgroundColor: .black
        )
        #expect(content.contentEdgeInset == 5)
        #expect(content.action != nil)
    }

    @Test func buttonBarContentDefaults() {
        let button = EKProperty.ButtonContent(
            label: .init(text: "OK", style: .init(font: .systemFont(ofSize: 14), color: .white)),
            backgroundColor: .white,
            highlightedBackgroundColor: .black
        )
        let bar = EKProperty.ButtonBarContent(with: [button], separatorColor: .clear, expandAnimatedly: false)
        #expect(bar.horizontalDistributionThreshold == 2)
        #expect(bar.buttonHeight == 50)
    }

    @Test func notificationInsetsDefaults() {
        let insets = EKNotificationMessage.Insets.default
        #expect(insets.contentInsets == UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        #expect(insets.titleToDescription == 5)
    }
}
