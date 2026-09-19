//
//  UIApplication+EKAppearance.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 5/25/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

extension UIApplication {
    /// The app's current key window across all scenes.
    var ekKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }

    /// The active `UIWindowScene` — the key window's scene, falling back to the first foreground scene.
    var ekActiveScene: UIWindowScene? {
        if let scene = ekKeyWindow?.windowScene {
            return scene
        }
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}
