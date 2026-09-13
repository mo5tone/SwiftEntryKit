//
//  ContactsViewController.swift
//  SwiftEntryKitDemo
//
//  Created by Daniel Huri on 3/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let dataSource = ["John", "Gregory", "David", "Jack", "Tony", "Torvi", "Walter", "Dexter", "Ramsay"]

    init() {
        super.init(nibName: Self.className, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenericCell")
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenericCell")!
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DescriptionViewController(screenTitle: dataSource[indexPath.row])
        navigationController!.pushViewController(vc, animated: true)
    }
}
