//
//  DescriptionViewController.swift
//  SwiftEntryKitDemo
//
//  Created by Daniel Huri on 3/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftEntryKit
import UIKit

class DescriptionViewController: UIViewController {
    private let screenTitle: String
    @IBOutlet private var label: UILabel!

    init(screenTitle: String) {
        self.screenTitle = screenTitle
        super.init(nibName: Self.className, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = screenTitle
        setupInterfaceStyle()
    }

    override func traitCollectionDidChange(_: UITraitCollection?) {
        setupInterfaceStyle()
    }

    private func setupInterfaceStyle() {
        view.backgroundColor = EKColor.standardBackground.color(
            for: traitCollection,
            mode: .inferred
        )
        label.textColor = EKColor.standardContent.color(
            for: traitCollection,
            mode: .inferred
        )
    }
}
