//
//  ModelAndViewUtilsTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct ModelAndViewUtilsTests {
    private func image(_ color: UIColor = .red) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
    }

    private func labelStyle(_ color: EKColor = .white, mode: EKAttributes.DisplayMode = .inferred) -> EKProperty.LabelStyle {
        .init(font: .systemFont(ofSize: 14), color: color, displayMode: mode)
    }

    // MARK: - EKColor

    @Test func colorInitializers() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        #expect(EKColor(rgb: 0x00FF00).color(for: traits, mode: .inferred) == UIColor(red: 0, green: 1, blue: 0, alpha: 1))
        #expect(EKColor(red: 255, green: 0, blue: 0).color(for: traits, mode: .inferred) == .red)
        #expect(EKColor.white.light == .white)
        #expect(EKColor.black.light == .black)
        #expect(EKColor.clear.dark == .clear)
        #expect(EKColor(.red).with(alpha: 0.5).light == UIColor.red.withAlphaComponent(0.5))
    }

    // MARK: - EKProperty color helpers

    @Test func buttonContentColorHelpers() {
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        let button = EKProperty.ButtonContent(
            label: .init(text: "OK", style: labelStyle(.white, mode: .dark)),
            backgroundColor: EKColor(light: .white, dark: .black),
            highlightedBackgroundColor: EKColor(light: .gray, dark: .darkGray),
            displayMode: .dark
        )
        #expect(button.backgroundColor(for: traits) == .black)
        #expect(button.highlightedBackgroundColor(for: traits) == .darkGray)
        #expect(button.highlighedLabelColor(for: traits) == UIColor.white.withAlphaComponent(0.8))
    }

    @Test func labelStyleResolvesColor() {
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        #expect(labelStyle(EKColor(light: .black, dark: .white), mode: .inferred).color(for: traits) == .white)
    }

    @Test func imageContentVariants() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        let single = EKProperty.ImageContent(image: image(), size: CGSize(width: 10, height: 10), tint: EKColor(.blue))
        #expect(single.tintColor(for: traits) == .blue)
        #expect(single.images.count == 1)

        let multiple = EKProperty.ImageContent(images: [image(.red), image(.blue)], imageSequenceAnimationDuration: 2)
        #expect(multiple.images.count == 2)
        #expect(multiple.imageSequenceAnimationDuration == 2)

        let thumb = EKProperty.ImageContent.thumb(with: image(), edgeSize: 24)
        #expect(thumb.size == CGSize(width: 24, height: 24))
        #expect(thumb.makesRound)
    }

    @Test func textFieldContentHelpers() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        var content = EKProperty.TextFieldContent(
            placeholder: .init(text: "Email", style: labelStyle()),
            tintColor: EKColor(.blue),
            textStyle: labelStyle(),
            bottomBorderColor: EKColor(.red)
        )
        #expect(content.tintColor(for: traits) == .blue)
        #expect(content.bottomBorderColor(for: traits) == .red)
        content.textContent = "hello"
        #expect(content.textContent == "hello")
    }

    @Test func buttonBarContentHelpers() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        let button = EKProperty.ButtonContent(
            label: .init(text: "OK", style: labelStyle()),
            backgroundColor: .white,
            highlightedBackgroundColor: .black
        )
        let bar = EKProperty.ButtonBarContent(with: button, separatorColor: EKColor(.red), expandAnimatedly: false)
        #expect(bar.content.count == 1)
        #expect(bar.separatorColor(for: traits) == .red)
    }

    @Test func ratingItemContent() {
        let item = EKProperty.EKRatingItemContent(
            title: .init(text: "Title", style: labelStyle()),
            description: .init(text: "Description", style: labelStyle()),
            unselectedImage: .init(image: image(.gray)),
            selectedImage: .init(image: image(.orange))
        )
        #expect(item.size == CGSize(width: 50, height: 50))
    }

    // MARK: - UIView+Utils

    @Test func labelStyleAndContent() {
        let label = UILabel()
        label.style = .init(font: .boldSystemFont(ofSize: 20), color: .white, alignment: .center, numberOfLines: 2)
        #expect(label.textAlignment == .center)
        #expect(label.numberOfLines == 2)

        label.content = .init(text: "Hello", style: labelStyle(), accessibilityIdentifier: "greeting")
        #expect(label.text == "Hello")
        #expect(label.accessibilityIdentifier == "greeting")
        #expect(label.content.text == "Hello")
    }

    @Test func buttonContentSetter() {
        let button = UIButton(type: .system)
        button.buttonContent = .init(
            label: .init(text: "Tap", style: labelStyle()),
            backgroundColor: .white,
            highlightedBackgroundColor: .black,
            accessibilityIdentifier: "tap"
        )
        #expect(button.title(for: .normal) == "Tap")
        #expect(button.accessibilityIdentifier == "tap")
    }

    @Test func imageViewContentVariants() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.imageContent = .init(image: image(), size: CGSize(width: 20, height: 20), makesRound: true)
        #expect(imageView.layer.cornerRadius == 10)

        imageView.imageContent = .init(image: image())
        #expect(imageView.contentMode == .scaleToFill)

        imageView.imageContent = .init(images: [image(.red), image(.blue)], imageSequenceAnimationDuration: 1)
        #expect(imageView.animationImages?.count == 2)

        imageView.imageContent = .init(
            image: image(),
            animation: .animate(duration: 0.1, options: .curveLinear, transform: .identity),
            size: CGSize(width: 20, height: 20)
        )
        imageView.imageContent = .init(image: image(), makesRound: true)
    }

    @Test func textFieldContentSetter() {
        let textField = UITextField()
        textField.placeholder = .init(text: "Name", style: labelStyle())
        #expect(textField.attributedPlaceholder?.string == "Name")

        textField.textFieldContent = .init(
            keyboardType: .emailAddress,
            placeholder: .init(text: "Email", style: labelStyle()),
            tintColor: EKColor(.blue),
            textStyle: labelStyle(),
            isSecure: true,
            accessibilityIdentifier: "email"
        )
        #expect(textField.keyboardType == .emailAddress)
        #expect(textField.isSecureTextEntry)
        #expect(textField.accessibilityIdentifier == "email")
    }
}
