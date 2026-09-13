//
//  SnapshotFixtures.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import UIKit

enum SnapshotFixtures {
    static func label(_ text: String, font: UIFont = .systemFont(ofSize: 15), color: UIColor = .black) -> EKProperty.LabelContent {
        EKProperty.LabelContent(text: text, style: .init(font: font, color: EKColor(color)))
    }

    static func title(_ text: String = "Title") -> EKProperty.LabelContent {
        EKProperty.LabelContent(text: text, style: .init(font: .boldSystemFont(ofSize: 18), color: EKColor(.black)))
    }

    static func thumb(size: CGSize = CGSize(width: 40, height: 40), color: UIColor = .systemBlue) -> EKProperty.ImageContent {
        let image = UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return EKProperty.ImageContent(image: image, size: size, contentMode: .scaleAspectFill, makesRound: true)
    }

    static func button(_ text: String) -> EKProperty.ButtonContent {
        EKProperty.ButtonContent(
            label: label(text, color: .white),
            backgroundColor: EKColor(.systemBlue),
            highlightedBackgroundColor: EKColor(.systemBlue.withAlphaComponent(0.8))
        )
    }

    static func buttonBar(count: Int) -> EKProperty.ButtonBarContent {
        let buttons = (1 ... count).map { button("Button \($0)") }
        return EKProperty.ButtonBarContent(with: buttons, separatorColor: EKColor(.lightGray), expandAnimatedly: false)
    }

    static func simpleMessage(withImage: Bool = false) -> EKSimpleMessage {
        EKSimpleMessage(
            image: withImage ? thumb() : nil,
            title: title(),
            description: label("A short description of the entry.")
        )
    }

    static func ratingItems(count: Int = 5) -> [EKProperty.EKRatingItemContent] {
        let unselected = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { context in
            UIColor.lightGray.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 30, height: 30))
        }
        let selected = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { context in
            UIColor.systemOrange.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 30, height: 30))
        }
        return (1 ... count).map { index in
            EKProperty.EKRatingItemContent(
                title: label("Item \(index)"),
                description: label("Description \(index)"),
                unselectedImage: EKProperty.ImageContent(image: unselected),
                selectedImage: EKProperty.ImageContent(image: selected),
                size: CGSize(width: 30, height: 30)
            )
        }
    }

    static func textField(placeholder: String) -> EKProperty.TextFieldContent {
        EKProperty.TextFieldContent(
            placeholder: label(placeholder),
            textStyle: .init(font: .systemFont(ofSize: 15), color: EKColor(.black))
        )
    }
}
