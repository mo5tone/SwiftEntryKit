//
//  PlaygroundViewController.swift
//  SwiftEntryKit_Example
//
//  Created by Daniel Huri on 4/21/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import SwiftEntryKit
import UIKit

final class PlaygroundViewController: UIViewController {
    // MARK: - Types

    enum Cells {
        static let sectionTitles = ["Display",
                                    "Theme & Style",
                                    "Interaction",
                                    "Size & Position",
                                    "Animation"]
        static let header = SelectionHeaderView.self
        static let cells = [[PositionSelectionTableViewCell.self,
                             WindowLevelSelectionTableViewCell.self,
                             DisplayDurationSelectionTableViewCell.self,
                             PrioritySelectionTableViewCell.self],

                            [ShadowSelectionTableViewCell.self,
                             RoundCornersSelectionTableViewCell.self,
                             BorderSelectionTableViewCell.self,
                             BackgroundStyleSelectionTableViewCell.self,
                             BackgroundStyleSelectionTableViewCell.self],

                            [UserInteractionSelectionTableViewCell.self,
                             UserInteractionSelectionTableViewCell.self,
                             ScrollSelectionTableViewCell.self,
                             HapticFeedbackSelectionTableViewCell.self],

                            [WidthSelectionTableViewCell.self,
                             HeightSelectionTableViewCell.self,
                             MaxWidthSelectionTableViewCell.self,
                             SafeAreaSelectionTableViewCell.self],

                            [AnimationSelectionTableViewCell.self,
                             AnimationSelectionTableViewCell.self,
                             AnimationSelectionTableViewCell.self]]
    }

    // MARK: - Properties

    private let tableView = UITableView()

    private lazy var attributesWrapper: EntryAttributeWrapper = {
        var attributes = EKAttributes()
        attributes.positionConstraints = .fullWidth
        attributes.hapticFeedbackType = .success
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
        attributes.entryBackground = .visualEffect(style: .standard)
        return EntryAttributeWrapper(with: attributes)
    }()

    // MARK: - Lifecycle & Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInterfaceStyle()
    }

    override func traitCollectionDidChange(_: UITraitCollection?) {
        setupInterfaceStyle()
    }

    private func setupInterfaceStyle() {
        tableView.backgroundColor = EKColor.standardBackground.color(
            for: traitCollection,
            mode: PresetsDataSource.displayMode
        )
        tableView.reloadData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.register(Cells.header,
                           forHeaderFooterViewReuseIdentifier: Cells.header.className)
        for cells in Cells.cells {
            for cell in cells {
                tableView.register(cell, forCellReuseIdentifier: cell.className)
            }
        }
        tableView.fillSuperview()
    }

    // MARK: Actions

    @IBAction private func play() {
        let title = EKProperty.LabelContent(
            text: "Hi there!",
            style: EKProperty.LabelStyle(
                font: MainFont.bold.with(size: 16),
                color: .black
            )
        )
        let description = EKProperty.LabelContent(
            text: "Are you ready for some testing?",
            style: EKProperty.LabelStyle(
                font: MainFont.light.with(size: 14),
                color: .black
            )
        )
        let image = EKProperty.ImageContent(
            image: UIImage(named: "ic_info_outline")!,
            size: CGSize(width: 30, height: 30)
        )
        let simpleMessage = EKSimpleMessage(
            image: image,
            title: title,
            description: description
        )
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributesWrapper.attributes)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PlaygroundViewController: UITableViewDelegate, UITableViewDataSource {
    private func selectionCell(by id: String,
                               and indexPath: IndexPath) -> SelectionBaseCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: id,
                                                       for: indexPath) as? SelectionBaseCell
        else {
            fatalError("Failed to dequeue \(id) as SelectionBaseCell")
        }
        return cell
    }

    func tableView(_: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: SelectionBaseCell
        cell = selectionCell(by: Cells.cells[indexPath.section][indexPath.row].className,
                             and: indexPath)

        switch (indexPath.section, indexPath.row) {
        case (0, 0 ... 3):
            cell.configure(attributesWrapper: attributesWrapper)

        case (1, 0 ... 2):
            cell.configure(attributesWrapper: attributesWrapper)

        case (1, 3):
            guard let backgroundCell = cell as? BackgroundStyleSelectionTableViewCell else {
                fatalError("Expected BackgroundStyleSelectionTableViewCell")
            }
            backgroundCell.configure(attributesWrapper: attributesWrapper, focus: .screen)

        case (1, 4):
            guard let backgroundCell = cell as? BackgroundStyleSelectionTableViewCell else {
                fatalError("Expected BackgroundStyleSelectionTableViewCell")
            }
            backgroundCell.configure(attributesWrapper: attributesWrapper, focus: .entry)

        case (2, 0):
            guard let interactionCell = cell as? UserInteractionSelectionTableViewCell else {
                fatalError("Expected UserInteractionSelectionTableViewCell")
            }
            interactionCell.configure(attributesWrapper: attributesWrapper, focus: .screen)

        case (2, 1):
            guard let interactionCell = cell as? UserInteractionSelectionTableViewCell else {
                fatalError("Expected UserInteractionSelectionTableViewCell")
            }
            interactionCell.configure(attributesWrapper: attributesWrapper, focus: .entry)

        case (2, 2 ... 4):
            cell.configure(attributesWrapper: attributesWrapper)

        case (3, 0 ... 3):
            cell.configure(attributesWrapper: attributesWrapper)

        case (4, 0):
            guard let animationCell = cell as? AnimationSelectionTableViewCell else {
                fatalError("Expected AnimationSelectionTableViewCell")
            }
            animationCell.configure(attributesWrapper: attributesWrapper, action: .entrance)

        case (4, 1):
            guard let animationCell = cell as? AnimationSelectionTableViewCell else {
                fatalError("Expected AnimationSelectionTableViewCell")
            }
            animationCell.configure(attributesWrapper: attributesWrapper, action: .exit)

        case (4, 2):
            guard let animationCell = cell as? AnimationSelectionTableViewCell else {
                fatalError("Expected AnimationSelectionTableViewCell")
            }
            animationCell.configure(attributesWrapper: attributesWrapper, action: .pop)

        default:
            fatalError("Unhandled cell configuration")
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView?
    {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Cells.header.className) as? SelectionHeaderView else {
            return nil
        }
        header.text = Cells.sectionTitles[section]
        return header
    }

    func numberOfSections(in _: UITableView) -> Int {
        Cells.cells.count
    }

    func tableView(_: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        Cells.cells[section].count
    }

    /// iOS 9, 10 support
    func tableView(_: UITableView,
                   estimatedHeightForRowAt _: IndexPath) -> CGFloat
    {
        80
    }

    func tableView(_: UITableView,
                   estimatedHeightForHeaderInSection _: Int) -> CGFloat
    {
        50
    }
}
