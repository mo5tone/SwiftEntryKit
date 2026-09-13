//
//  EKWindow.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/19/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

class EKWindow: UIWindow {
    var isAbleToReceiveTouches = false

    init(with rootVC: UIViewController) {
        if let scene = UIApplication.shared.ekActiveScene {
            super.init(windowScene: scene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        backgroundColor = .clear
        rootViewController = rootVC
        accessibilityViewIsModal = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isAbleToReceiveTouches {
            return super.hitTest(point, with: event)
        }

        guard let rootVC = EKWindowProvider.shared.rootVC else {
            return nil
        }

        if let view = rootVC.view.hitTest(point, with: event) {
            return view
        }

        return nil
    }
}
