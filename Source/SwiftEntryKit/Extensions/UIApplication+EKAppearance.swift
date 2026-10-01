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

    /// The scene an entry window should attach to.
    ///
    /// Unlike ``ekActiveScene`` this accepts *any* connected scene, because a `UIWindow` whose
    /// `windowScene` is `nil` never appears on screen — a window attached to an inactive scene
    /// still shows as soon as that scene activates, whereas a scene-less one never will.
    var ekEntryScene: UIWindowScene? {
        ekActiveScene ?? connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    /// `true` when the app uses the `UIWindowScene` lifecycle, i.e. it declares a scene manifest,
    /// as opposed to the legacy `UIApplicationDelegate` window lifecycle.
    var ekUsesScenes: Bool {
        Bundle.main.object(forInfoDictionaryKey: "UIApplicationSceneManifest") != nil
    }

    /// `true` once an entry window can be created and displayed.
    ///
    /// A scene-based app must wait for a scene to connect before creating its entry window —
    /// see ``ekEntryScene``. Legacy apps have no scenes at all and are always ready, since
    /// `UIWindow(frame:)` is the correct initializer for them.
    var ekCanHostEntryWindow: Bool {
        !ekUsesScenes || ekEntryScene != nil
    }
}
