//
//  PopoverMenuController.swift
//  Popover menu
//
//  Created by Pirush Prechathavanich on 7/9/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

class PopoverMenuController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    private(set) var actions = [UIAlertAction]()
    private(set) var barButtonItem: UIBarButtonItem?
    
    static func show(on barButtonItem: UIBarButtonItem, viewController: UIViewController) -> PopoverMenuController {
        let controller = PopoverMenuController()
        controller.modalPresentationStyle = .popover
        
        controller.popoverPresentationController?.delegate = controller
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.popoverPresentationController?.sourceView = controller.tableView
        controller.popoverPresentationController?.permittedArrowDirections = .any
        
        viewController.present(controller, animated: true, completion: nil)
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mockData()
    }
    
    private func mockData() {
        let dateAction = UIAlertAction(title:"Change dates", style: .default, handler: { _ in
            NSLog("### change dates");
        });
        let roomAction = UIAlertAction(title:"Change room type", style: .default, handler: { _ in
            NSLog("### change room type");
        });
        let cancelAction = UIAlertAction(title:"Cancel booking", style: .destructive, handler: { _ in
            NSLog("### cancel booking");
        });
        addAction(dateAction)
        addAction(roomAction)
        addAction(cancelAction)
    }
    
    func addAction(_ action: UIAlertAction) {
        actions.append(action);
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "test")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "test")
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            cell?.textLabel?.textColor = UIColor.lightGray
        }
        cell?.textLabel?.text = actions[indexPath.row].title
        return cell!
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}

