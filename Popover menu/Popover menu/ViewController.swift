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
        guard let rightBarButton = self.navigationItem.rightBarButtonItem else { return }
        
        let dateAction = MenuAction(title:"Change dates", style: .default, handler: { _ in
            print("### change dates")
        })
        let roomAction = MenuAction(title:"Change room type", style: .default, handler: { _ in
            print("### change room type")
        })
        let guestAction = MenuAction(title:"Edit guest details", style: .default, handler: { _ in
            print("### edit guest detail")
        })
        let cancelAction = MenuAction(title:"Cancel booking", style: .destructive, handler: { _ in
            print("### cancel booking")
        })
        let menus = [dateAction, roomAction, guestAction, cancelAction]
        var option = PopoverOption()
        option.menuInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        let controller = PopoverMenuController(with: menus, and: option)
        controller.pop(on: rightBarButton, in: self)
    }
    
}
