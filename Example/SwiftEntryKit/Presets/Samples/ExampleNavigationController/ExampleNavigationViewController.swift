//
//  ExampleNavigationViewController.swift
//  SwiftEntryKitDemo
//
//  Created by Daniel Huri on 3/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftEntryKit
import UIKit

class ExampleNavigationViewController: UINavigationController {
    override func traitCollectionDidChange(_: UITraitCollection?) {
        navigationBar.tintColor = EKColor.navigationItemColor.color(for: traitCollection, mode: .inferred)
    }
}
