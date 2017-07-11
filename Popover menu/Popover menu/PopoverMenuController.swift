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
        self.layer.shadowColor = UIColor.clear.cgColor
        self.arrowView = TriangleView(frame: CGRect(x: 0, y: 0, width: arrow.base, height: arrow.height))
        self.addSubview(arrowView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var arrowOffset: CGFloat {
        get { return arrow.offset }
        set {
            arrow.offset = newValue
            setNeedsLayout()
        }
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get { return arrow.direction.popoverDirection }
        set {
            guard let direction = Direction.transform(from: newValue) else { return }
            arrow.direction = direction
            setNeedsLayout()
        }
    }
    
    override class var wantsDefaultContentAppearance: Bool {
        return false
    }
    
    override static func arrowBase() -> CGFloat {
        return PROTOTYPE_ARROW.base
    }
    
    override static func arrowHeight() -> CGFloat {
        return PROTOTYPE_ARROW.height
    }
    
    override static func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        arrowView?.frame = arrow.frame(container: self.bounds)
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

struct PopoverOption {
    var font: UIFont = UIFont.boldSystemFont(ofSize: 12.0)
    var fontColor: UIColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1.0)
    var rowHeight: CGFloat = 47.0
    var cornerRadius: CGFloat = 5.0
}

class PopoverMenuController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    private(set) var actions = [MenuAction]()
    
    var rowHeight: CGFloat = 47.0
    //customizable: rowHeight tableViewInsets arrow? shadow cornerRadius
    //customizable-color: seperator default/destructive-text
    
    convenience init(with menus: [MenuAction]) {
        self.init()
        self.actions = menus
    }
    
    func pop(on barButtonItem: UIBarButtonItem, in viewController: UIViewController) {
        let height = Int(rowHeight) * actions.count
        
        self.modalPresentationStyle = .popover
        self.preferredContentSize = CGSize(width: 150, height: height)
        
        self.popoverPresentationController?.delegate = self
        self.popoverPresentationController?.barButtonItem = barButtonItem
        self.popoverPresentationController?.sourceView = self.tableView
        self.popoverPresentationController?.permittedArrowDirections = .any
        self.popoverPresentationController?.popoverBackgroundViewClass = PopoverBackgroundView.self

        viewController.present(self, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let containerView = self.view.superview {
            containerView.layer.cornerRadius = 5.0
            //note:- workaround to add custom shadow for popover
            if let popoverView = containerView.superview {
                popoverView.layer.shadowColor = UIColor.black.cgColor
                popoverView.layer.shadowOpacity = 0.1
                popoverView.layer.shadowRadius = 8.0
            }
        }
        //note:- workaround to remove unwanted shadow generated by ios
        if let topSubviews = UIApplication.shared.keyWindow?.subviews.last?.subviews {
            for subview in topSubviews {
                if subview.isKind(of: NSClassFromString("_UIMirrorNinePatchView")!) {
                    subview.subviews.forEach { ($0 as? UIImageView)?.image = nil }
                }
            }
        }
    }
    
    private func setupView() {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.15) //todo:- change
        tableView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: -10, y: 0)
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            cell?.textLabel?.textColor = UIColor.darkGray
            cell?.backgroundColor = .clear
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

