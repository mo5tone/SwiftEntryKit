//
//  SnapshotTests.swift
//  SwiftEntryKitTests
//

import SnapshotTesting
@testable import SwiftEntryKit
import Testing
import UIKit

@Suite(.snapshots(record: .missing))
@MainActor
struct SnapshotTests {
    private func prepared(_ view: UIView, height: CGFloat, width: CGFloat = 320) -> UIView {
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        view.layoutIfNeeded()
        return view
    }

    @Test func alertTop() {
        let message = EKAlertMessage(
            simpleMessage: SnapshotFixtures.simpleMessage(withImage: true),
            imagePosition: .top,
            buttonBarContent: SnapshotFixtures.buttonBar(count: 2)
        )
        assertSnapshot(of: prepared(EKAlertMessageView(with: message), height: 280), as: .image)
    }

    @Test func alertLeft() {
        let message = EKAlertMessage(
            simpleMessage: SnapshotFixtures.simpleMessage(withImage: true),
            imagePosition: .left,
            buttonBarContent: SnapshotFixtures.buttonBar(count: 2)
        )
        assertSnapshot(of: prepared(EKAlertMessageView(with: message), height: 150), as: .image)
    }

    @Test func notification() {
        let message = EKNotificationMessage(
            simpleMessage: SnapshotFixtures.simpleMessage(withImage: true),
            auxiliary: SnapshotFixtures.label("now")
        )
        assertSnapshot(of: prepared(EKNotificationMessageView(with: message), height: 90), as: .image)
    }

    @Test func popup() {
        let message = EKPopUpMessage(
            themeImage: .init(image: SnapshotFixtures.thumb(size: CGSize(width: 60, height: 60))),
            title: SnapshotFixtures.title(),
            description: SnapshotFixtures.label("A popup description."),
            button: SnapshotFixtures.button("Continue"),
            action: {}
        )
        assertSnapshot(of: prepared(EKPopUpMessageView(with: message), height: 320), as: .image)
    }

    @Test func rating() {
        let message = EKRatingMessage(
            initialTitle: SnapshotFixtures.title("Rate us"),
            initialDescription: SnapshotFixtures.label("How was your experience?"),
            ratingItems: SnapshotFixtures.ratingItems(),
            buttonBarContent: SnapshotFixtures.buttonBar(count: 1)
        )
        assertSnapshot(of: prepared(EKRatingMessageView(with: message), height: 280), as: .image)
    }

    @Test func form() {
        let view = EKFormMessageView(
            with: SnapshotFixtures.title("Sign in"),
            textFieldsContent: [
                SnapshotFixtures.textField(placeholder: "Email"),
                SnapshotFixtures.textField(placeholder: "Password"),
            ],
            buttonContent: SnapshotFixtures.button("Submit")
        )
        assertSnapshot(of: prepared(view, height: 300), as: .image)
    }

    @Test func note() {
        assertSnapshot(of: prepared(EKNoteMessageView(with: SnapshotFixtures.label("A simple note.")), height: 40), as: .image)
    }

    @Test func imageNote() {
        let view = EKImageNoteMessageView(
            with: SnapshotFixtures.label("A note with image"),
            imageContent: SnapshotFixtures.thumb(size: CGSize(width: 20, height: 20))
        )
        assertSnapshot(of: prepared(view, height: 40), as: .image)
    }

    @Test func processingNote() {
        let view = EKProcessingNoteMessageView(with: SnapshotFixtures.label("Loading..."), activityIndicator: .medium)
        assertSnapshot(of: prepared(view, height: 40), as: .image)
    }
}
