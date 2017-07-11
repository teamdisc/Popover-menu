//
//  PopoverMenuController.swift
//  Popover menu
//
//  Created by Pirush Prechathavanich on 7/9/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit
import CoreGraphics

typealias ActionHandler = (UITableViewCell?) -> Void

struct MenuAction {
    var title: String?
    var style: UIAlertActionStyle
    var handler: ActionHandler?
    
    init(title: String?, style: UIAlertActionStyle = .default, handler: ActionHandler? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

struct Arrow {
    let base: CGFloat = 8.0
    let height: CGFloat = 4.0
    var offset: CGFloat = 0.0
    var direction: Direction = .up
    
    func frame(container: CGRect) -> CGRect {
        let halfBase = base/2.0
        let size = frameSize()
        let x: CGFloat
        let y: CGFloat
        switch direction {
        case .up:
            x = container.midX + offset - halfBase
            y = 0.0
        case .down:
            x = container.midX + offset - halfBase
            y = container.height - height
        case .left:
            x = 0.0
            y = container.midY + offset - halfBase
        case .right:
            x = container.width + height
            y = container.midY + offset - halfBase
        }
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    private func frameSize() -> CGSize {
        switch direction {
        case .up, .down:
            return CGSize(width: base, height: height)
        case .left, .right:
            return CGSize(width: height, height: base)
        }
    }
    
}

enum Direction {
    case up
    case down
    case left
    case right
    
    var popoverDirection: UIPopoverArrowDirection {
        switch self {
        case .up:       return UIPopoverArrowDirection.up
        case .down:     return UIPopoverArrowDirection.down
        case .left:     return UIPopoverArrowDirection.left
        case .right:    return UIPopoverArrowDirection.right
        }
    }
    
    static func transform(from popoverDirection: UIPopoverArrowDirection) -> Direction? {
        switch popoverDirection {
        case UIPopoverArrowDirection.up:    return .up
        case UIPopoverArrowDirection.down:  return .down
        case UIPopoverArrowDirection.left:  return .left
        case UIPopoverArrowDirection.right: return .right
        default:                            return nil
        }
    }
    
}

class PopoverBackgroundView: UIPopoverBackgroundView {
    
    static let PROTOTYPE_ARROW = Arrow()
    private var arrow = Arrow()
    private var arrowView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 3.0
        self.layer.shadowRadius = 18.0
        self.layer.shadowColor = UIColor.red.withAlphaComponent(0.5).cgColor
        self.arrowView = TriangleView(frame: CGRect(x: 0, y: 0, width: arrow.base, height: arrow.height))
        self.addSubview(arrowView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var arrowOffset: CGFloat {
        get { return arrow.offset }
        set {
            arrow.offset = arrowOffset
            setNeedsLayout()
        }
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get { return arrow.direction.popoverDirection }
        set {
            guard let direction = Direction.transform(from: arrowDirection) else { return }
            arrow.direction = direction
            setNeedsLayout()
        }
    }
    
    override class var wantsDefaultContentAppearance: Bool {
        return true
    }
    
    override static func arrowBase() -> CGFloat {
        return PROTOTYPE_ARROW.base
    }
    
    override static func arrowHeight() -> CGFloat {
        return PROTOTYPE_ARROW.height
    }
    
    override static func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    override func layoutSubviews() {
        let arrowFrame = arrow.frame(container: self.bounds)
        var backgroundFrame = self.bounds
        switch arrow.direction {
        case .up:
            backgroundFrame.origin.y += arrowFrame.height
            backgroundFrame.size.height -= arrowFrame.height
        case .down:
            backgroundFrame.size.height -= arrowFrame.height
        case .left:
            backgroundFrame.origin.x += arrowFrame.width
            backgroundFrame.size.width -= arrowFrame.width
        case .right:
            backgroundFrame.size.width -= arrowFrame.width
        }
        arrowView?.frame = arrowFrame
    }
}

class TriangleView : UIView {
    
    private var color: UIColor = .white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

class PopoverMenuController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    private(set) var actions = [MenuAction]()
    private(set) var barButtonItem: UIBarButtonItem?
    var rowHeight: CGFloat = 47.0
    
    static func show(on barButtonItem: UIBarButtonItem, viewController: UIViewController) -> PopoverMenuController {
        let controller = PopoverMenuController()
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 150, height: 190)
        
        controller.popoverPresentationController?.delegate = controller
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.popoverPresentationController?.sourceView = controller.tableView
        controller.popoverPresentationController?.permittedArrowDirections = .any
        controller.popoverPresentationController?.popoverBackgroundViewClass = PopoverBackgroundView.self
        
        viewController.present(controller, animated: true, completion: nil)
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mockData()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let containerView = self.view.superview {
            containerView.layer.cornerRadius = 5
        }
    }
    
    private func setupView() {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.15)
    }
    
    private func mockData() {
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
        addAction(dateAction)
        addAction(roomAction)
        addAction(guestAction)
        addAction(cancelAction)
    }
    
    func addAction(_ action: MenuAction) {
        actions.append(action);
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "test")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "test")
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            cell?.textLabel?.textColor = UIColor.darkGray
        }
        cell?.textLabel?.text = actions[indexPath.row].title
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        action.handler?(nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}

