//
//  BackgroundAndUtilityViewTests.swift
//  SwiftEntryKitTests
//

@testable import SwiftEntryKit
import Testing
import UIKit

@MainActor
struct BackgroundAndUtilityViewTests {
    private func image() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
    }

    // MARK: - EKBackgroundView

    @Test func backgroundViewAppliesEveryStyle() {
        let backgroundView = EKBackgroundView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        backgroundView.style = .init(background: .color(color: .white), displayMode: .light)
        #expect(backgroundView.layer.backgroundColor == UIColor.white.cgColor)

        backgroundView.style = .init(
            background: .gradient(gradient: .init(colors: [.white, .black], startPoint: .zero, endPoint: .init(x: 1, y: 1))),
            displayMode: .light
        )
        backgroundView.traitCollectionDidChange(nil)

        backgroundView.style = .init(background: .image(image: image()), displayMode: .inferred)
        backgroundView.traitCollectionDidChange(nil)

        backgroundView.style = .init(background: .visualEffect(style: .standard), displayMode: .dark)
        backgroundView.traitCollectionDidChange(nil)

        backgroundView.style = .init(background: .clear, displayMode: .inferred)
        backgroundView.traitCollectionDidChange(nil)
    }

    // MARK: - GradientView

    @Test func gradientView() {
        let gradientView = GradientView()
        gradientView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        let gradient = EKAttributes.BackgroundStyle.Gradient(colors: [.white, .black], startPoint: .zero, endPoint: .init(x: 1, y: 1))
        gradientView.style = GradientView.Style(gradient: gradient, displayMode: .light)
        gradientView.layoutIfNeeded()
        gradientView.traitCollectionDidChange(nil)

        gradientView.style = nil
        gradientView.traitCollectionDidChange(nil)

        #expect(GradientView.Style(gradient: nil, displayMode: .light) == nil)
    }

    // MARK: - EKStyleView

    @Test func styleViewAppliesCornersAndBorder() {
        let styleView = EKStyleView()
        styleView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        styleView.applyFrameStyle(roundCorners: .all(radius: 12), border: .value(color: .red, width: 2))
        #expect(styleView.layer.mask != nil)
        #expect(styleView.layer.sublayers?.contains { $0 is CAShapeLayer } == true)

        styleView.applyFrameStyle(roundCorners: .none, border: .none)
        styleView.layoutSubviews()
    }

    // MARK: - EKWrapperView

    @Test func wrapperViewHitTesting() {
        let wrapper = EKWrapperView()
        wrapper.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let child = UIView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        wrapper.addSubview(child)

        wrapper.isAbleToReceiveTouches = true
        #expect(wrapper.hitTest(CGPoint(x: 15, y: 15), with: nil) === child)

        wrapper.isAbleToReceiveTouches = false
        #expect(wrapper.hitTest(CGPoint(x: 15, y: 15), with: nil) === child)
        #expect(wrapper.hitTest(CGPoint(x: 500, y: 500), with: nil) == nil)
    }

    // MARK: - EKWindow

    @Test func windowHitTesting() {
        let window = EKWindow(with: UIViewController())
        window.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        window.isAbleToReceiveTouches = true
        _ = window.hitTest(CGPoint(x: 5, y: 5), with: nil)

        window.isAbleToReceiveTouches = false
        _ = window.hitTest(CGPoint(x: 5, y: 5), with: nil)
    }

    // MARK: - Shadow

    @Test func dropShadowRoundTrip() {
        let view = UIView()
        view.applyDropShadow(withOffset: .init(width: 2, height: 2), opacity: 0.4, radius: 3, color: .red)
        #expect(view.layer.shadowOpacity == 0.4)
        #expect(view.layer.shadowRadius == 3)
        #expect(view.layer.shouldRasterize)

        view.removeDropShadow()
        #expect(view.layer.shadowOpacity == 0)
        #expect(!view.layer.shouldRasterize)
    }

    // MARK: - UIColor

    @Test func colorFromRGB() {
        #expect(UIColor(rgb: 0xFF0000) == UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        #expect(UIColor(red: 0, green: 255, blue: 0) == UIColor(red: 0, green: 1, blue: 0, alpha: 1))
    }

    // MARK: - UIView+Responder

    @Test func containsFirstResponder() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        container.addSubview(textField)
        #expect(!container.containsFirstResponder)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let rootVC = UIViewController()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        rootVC.view.addSubview(textField)
        if textField.becomeFirstResponder() {
            #expect(rootVC.view.containsFirstResponder)
        }
    }

    // MARK: - UIEdgeInsets

    @Test func verticalInsets() {
        #expect(!UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5).hasVerticalInsets)
        #expect(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0).hasVerticalInsets)
        #expect(UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0).hasVerticalInsets)
    }

    // MARK: - EKXStatusBarMessageView

    @Test func xStatusBarMessageView() {
        let leading = EKProperty.LabelContent(text: "9:41", style: .init(font: .systemFont(ofSize: 12), color: .white))
        let trailing = EKProperty.LabelContent(text: "100%", style: .init(font: .systemFont(ofSize: 12), color: .white))
        let view = EKXStatusBarMessageView(leading: leading, trailing: trailing)
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 44)
        view.layoutIfNeeded()
        #expect(view.subviews.count == 2)
    }
}
