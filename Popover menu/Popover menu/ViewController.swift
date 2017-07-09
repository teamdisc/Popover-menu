//
//  ViewController.swift
//  Popover menu
//
//  Created by Pirush Prechathavanich on 7/8/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pop!",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(pop))
    }
    
    func pop() {
        guard let rightButton = self.navigationItem.rightBarButtonItem else { return }
        _ = PopoverMenuController.show(on: rightButton, viewController: self)
    }
    
}

