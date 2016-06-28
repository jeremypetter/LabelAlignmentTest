//
//  TableViewCell.swift
//  LabelAlignmentTest
//
//  Created by Jeremy Petter on 2016-06-24.
//  Copyright © 2016 JeremyPetter. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    var defaultHorizontalConstraints: [NSLayoutConstraint]!
    var additionalHorizontalConstriants: [NSLayoutConstraint]?

    static let defaultReuseIdentifier = "TableViewCellReuseIdentifier"

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    func setUp() {
        addSubview(leftLabel)
        addSubview(rightLabel)

        let verticalConstraints = constraints(["V:|[leftLabel]|": []], metrics: nil)
        toggleActive(true, constraints: verticalConstraints)

        defaultHorizontalConstraints = constraints(["H:|[leftLabel][rightLabel]|": [NSLayoutFormatOptions.AlignAllTop, NSLayoutFormatOptions.AlignAllBottom]], metrics: nil)
        toggleActive(true, constraints: defaultHorizontalConstraints)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addProportionalCroppingConstriants), name: Label.labelTextDidChangeNotification, object: nil)
    }

    // MARK: Notification Hnadlers

    func addProportionalCroppingConstriants() {
        // Remove exsiting constraints from the view's constriants array. Inactive constraints are deallocated unless a local reference to them is maintained.
        if let additionalHorizontalConstriants = additionalHorizontalConstriants {
            toggleActive(false, constraints: additionalHorizontalConstriants)
        }

        // Implicitly deallocates existing constraints
        additionalHorizontalConstriants = [NSLayoutConstraint]()

        let leftString: NSString = leftLabel.text ?? ""
        let rightString: NSString = rightLabel.text ?? ""

        let leftStringSize = leftString.sizeWithAttributes([NSFontAttributeName : UIFont(name: "Courier", size: 6.248983)!])
        let rightStringSize = rightString.sizeWithAttributes([NSFontAttributeName : UIFont(name: "Courier", size: 6.248983)!])

        let contentViewWidth = contentView.bounds.size.width
        let leftStringWidth = ceil(leftStringSize.width)
        let rightStringWidth = ceil(rightStringSize.width)
        print("content view width: \(contentViewWidth)")
        print("left string width: \(leftStringSize)")

        if (leftStringWidth >= (contentViewWidth * 2.0 / 3.0)) {
            additionalHorizontalConstriants?.append(leftLabel.widthAnchor.constraintGreaterThanOrEqualToAnchor(contentView.widthAnchor, multiplier: 2.0 / 3.0))
            leftLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        } else {
            leftLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }

        if (rightStringWidth >= (contentViewWidth * 1.0 / 3.0)) {
            additionalHorizontalConstriants?.append(rightLabel.widthAnchor.constraintGreaterThanOrEqualToAnchor(contentView.widthAnchor, multiplier: 1.0 / 3.0))
            rightLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        } else {
            rightLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }

        toggleActive(true, constraints: additionalHorizontalConstriants!)
    }

    // MARK: Helper Methods

    func constraints(formats: [String: NSLayoutFormatOptions], metrics: [String: AnyObject]?) -> [NSLayoutConstraint] {

        let views = [
            "leftLabel": leftLabel,
            "rightLabel": rightLabel
        ]

        var constraints = [NSLayoutConstraint]()

        for (key, value) in formats {
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(key, options: value, metrics: metrics, views: views))
        }

        return constraints
    }

    func toggleActive(active: Bool, constraints: [NSLayoutConstraint]) {
        _ = constraints.map { $0.active = active }
    }

    //MARK: Lazy Properties

    lazy var leftLabel: Label = {
        let label = Label()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .yellowColor()
        label.font = UIFont(name: "Courier", size: 6.248983)

        return label
    }()

    lazy var rightLabel: Label = {
        let label = Label()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Right
        label.font = UIFont(name: "Courier", size: 6.248983)

        return label
    }()
}