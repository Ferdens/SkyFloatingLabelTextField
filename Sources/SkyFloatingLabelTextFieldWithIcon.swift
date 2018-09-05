//  Copyright 2016-2017 Skyscanner Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
//  compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is
//  distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and limitations under the License.

import UIKit

/**
 Identify the type of icon.
 - font: Set your icon by setting the font of iconLabel
 - image: Set your icon by setting the image of leftIconImageView
 */
public enum IconType: Int {
    case font
    case image
    case button
}

/**
 A beautiful and flexible textfield implementation with support for icon, title label, error message and placeholder.
 */
open class SkyFloatingLabelTextFieldWithIcon: SkyFloatingLabelTextField {
    
    open var rightButtonActionHandler: (() -> Void)?
    open var leftButtonActionHandler: (() -> Void)?
    
    @IBInspectable
    var leftIconTypeValue: Int {
        get {
            return self.leftIconType.rawValue
        }
        
        set(iconIndex) {
            self.leftIconType = IconType(rawValue: iconIndex) ?? .font
        }
    }
    
    open var leftIconType: IconType = .font {
        didSet {
            updateLeftIconViewHiddenState()
        }
    }
    
    @IBInspectable
    var rigthIconTypeValue: Int {
        get {
            return self.rightIconType.rawValue
        }
        
        set(iconIndex) {
            self.rightIconType = IconType(rawValue: iconIndex) ?? .font
        }
    }
    
    open var rightIconType: IconType = .font {
        didSet {
            updateRightIconViewHiddenState()
        }
    }
    
    /// A UIImageView value that identifies the view used to display the icon
    open var leftIconImageView  : UIImageView!
    open var rightIconImageView : UIImageView!
    
    open var leftIconButtonView : UIButton!
    open var rightIconButtonView: UIButton!
    
    /// A UIImage value that determines the image that the icon is using
    @IBInspectable
    dynamic open var leftIconImage: UIImage? {
        didSet {
            // Show a warning if setting an image while the iconType is IconType.font
            if self.leftIconType == .font { NSLog("WARNING - Did set iconImage when the iconType is set to IconType.font. The image will not be displayed.") } // swiftlint:disable:this line_length
            leftIconImageView?.image = leftIconImage
            leftIconButtonView?.setImage(leftIconImage, for: .normal)
        }
    }
    
    @IBInspectable
    dynamic open var rightIconImage: UIImage? {
        didSet {
            // Show a warning if setting an image while the iconType is IconType.font
            if self.rightIconType == .font { NSLog("WARNING - Did set iconImage when the iconType is set to IconType.font. The image will not be displayed.") } // swiftlint:disable:this line_length
            rightIconImageView?.image = rightIconImage
            rightIconButtonView?.setImage(rightIconImage, for: .normal)
        }
    }
    
    /// A UILabel value that identifies the label used to display the icon
    open var iconLabel: UILabel!
    
    /// A UIFont value that determines the font that the icon is using
    @objc dynamic open var iconFont: UIFont? {
        didSet {
            iconLabel?.font = iconFont
        }
    }
    
    /// A String value that determines the text used when displaying the icon
    @IBInspectable
    open var iconText: String? {
        didSet {
            // Show a warning if setting an icon text while the iconType is IconType.image
            if self.leftIconType == .image { NSLog("WARNING - Did set iconText when the iconType is set to IconType.image. The icon with the specified text will not be displayed.") } // swiftlint:disable:this line_length
            iconLabel?.text = iconText
        }
    }
    
    /// A UIColor value that determines the color of the icon in the normal state
    @IBInspectable
    dynamic open var iconColor: UIColor = UIColor.gray {
        didSet {
            updateIconLabelColor()
        }
    }
    
    /// A UIColor value that determines the color of the icon when the control is selected
    @IBInspectable
    dynamic open var selectedIconColor: UIColor = UIColor.gray {
        didSet {
            updateIconLabelColor()
        }
    }
    
    /// A float value that determines the width of the icon
    @IBInspectable
    dynamic open var iconWidth: CGFloat = 20 {
        didSet {
            updateFrame()
        }
    }
    
    /**
     A float value that determines the left margin of the icon.
     Use this value to position the icon more precisely horizontally.
     */
    @IBInspectable
    dynamic open var iconMarginLeft: CGFloat = 4 {
        didSet {
            updateFrame()
        }
    }
    
    /**
     A float value that determines the bottom margin of the icon.
     Use this value to position the icon more precisely vertically.
     */
    @IBInspectable
    dynamic open var iconMarginBottom: CGFloat = 4 {
        didSet {
            updateFrame()
        }
    }
    
    /**
     A float value that determines the rotation in degrees of the icon.
     Use this value to rotate the icon in either direction.
     */
    @IBInspectable
    open var iconRotationDegrees: Double = 0 {
        didSet {
            iconLabel.transform = CGAffineTransform(rotationAngle: CGFloat(iconRotationDegrees * .pi / 180.0))
            leftIconImageView.transform = CGAffineTransform(rotationAngle: CGFloat(iconRotationDegrees * .pi / 180.0))
        }
    }
    
    // MARK: Initializers
    
    /**
     Initializes the control
     - parameter type the type of icon
     */
    convenience public init(frame: CGRect, iconType: IconType) {
        self.init(frame: frame)
        self.leftIconType = iconType
        updateLeftIconViewHiddenState()
    }
    
    /**
     Initializes the control
     - parameter frame the frame of the control
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createIcon()
        updateLeftIconViewHiddenState()
    }
    
    /**
     Intialzies the control by deserializing it
     - parameter coder the object to deserialize the control from
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createIcon()
        updateLeftIconViewHiddenState()
    }
    
    // MARK: Creating the icon
    
    /// Creates the both icon label and icon image view
    fileprivate func createIcon() {
        createIconLabel()
        createleftIconImageView()
        createLeftButtonView()
        createRightIconImageView()
        createRightButtonView()
    }
    
    // MARK: Creating the icon label
    
    /// Creates the icon label
    fileprivate func createIconLabel() {
        let iconLabel = UILabel()
        iconLabel.backgroundColor = UIColor.clear
        iconLabel.textAlignment = .center
        iconLabel.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.iconLabel = iconLabel
        addSubview(iconLabel)
        updateIconLabelColor()
    }
    
    // MARK: Creating the icon image view
    
    /// Creates the icon image view
    fileprivate func createleftIconImageView() {
        let leftIconImageView = UIImageView()
        leftIconImageView.backgroundColor = .clear
        leftIconImageView.contentMode = .scaleAspectFit
        leftIconImageView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.leftIconImageView = leftIconImageView
        addSubview(leftIconImageView)
    }
    
    fileprivate func createRightIconImageView() {
        let rightIconImageView = UIImageView()
        rightIconImageView.backgroundColor = .clear
        rightIconImageView.contentMode = .scaleAspectFit
        rightIconImageView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.rightIconImageView = rightIconImageView
        addSubview(rightIconImageView)
    }
    
    fileprivate func createLeftButtonView() {
        let leftButtonView = UIButton()
        leftButtonView.backgroundColor = .clear
        leftButtonView.contentMode = .scaleAspectFit
        leftButtonView.imageView?.contentMode = .scaleAspectFit
        leftButtonView.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
        leftButtonView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.leftIconButtonView = leftButtonView
        addSubview(leftButtonView)
    }
    
    @objc func rightButtonAction() {
        if let rightButtonHandler = self.rightButtonActionHandler {
            rightButtonHandler()
        }
    }
    
    @objc func leftButtonAction() {
        if let leftButtonHandler = self.leftButtonActionHandler {
            leftButtonHandler()
        }
    }
    
    fileprivate func createRightButtonView() {
        let rightButtonView = UIButton()
        rightButtonView.backgroundColor = .clear
        rightButtonView.contentMode = .scaleAspectFit
        rightButtonView.imageView?.contentMode = .scaleAspectFit
        rightButtonView.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        rightButtonView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.rightIconButtonView = rightButtonView
        addSubview(rightButtonView)
    }
    
    // MARK: Set icon hidden property
    
    /// Shows the corresponding icon depending on iconType property
    fileprivate func updateLeftIconViewHiddenState() {
        switch leftIconType {
        case .font:
            self.iconLabel.isHidden = true
            self.leftIconImageView.isHidden = true
            self.leftIconButtonView.isHidden = true
        case .image:
            self.iconLabel.isHidden = true
            self.leftIconImageView.isHidden = false
            self.leftIconButtonView.isHidden = true
        case .button:
            self.iconLabel.isHidden = true
            self.leftIconImageView.isHidden = true
            self.leftIconButtonView.isHidden = false
        }
    }
    
    fileprivate func updateRightIconViewHiddenState() {
        switch rightIconType {
        case .font:
            self.iconLabel.isHidden = true
            self.rightIconImageView.isHidden = true
            self.rightIconButtonView.isHidden = true
        case .image:
            self.iconLabel.isHidden = true
            self.rightIconImageView.isHidden = false
            self.rightIconButtonView.isHidden = true
        case .button:
            self.iconLabel.isHidden = true
            self.rightIconImageView.isHidden = true
            self.rightIconButtonView.isHidden = false
        }
    }
    
    // MARK: Handling the icon color
    
    /// Update the colors for the control. Override to customize colors.
    override open func updateColors() {
        super.updateColors()
        updateIconLabelColor()
    }
    
    fileprivate func updateIconLabelColor() {
        if !isEnabled {
            iconLabel?.textColor = disabledColor
        } else if hasErrorMessage {
            iconLabel?.textColor = errorColor
        } else {
            iconLabel?.textColor = editingOrSelected ? selectedIconColor : iconColor
        }
    }
    
    // MARK: Custom layout overrides
    
    /**
     Calculate the bounds for the textfield component of the control.
     Override to create a custom size textbox in the control.
     - parameter bounds: The current bounds of the textfield component
     - returns: The rectangle that the textfield component should render in
     */
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        if isLTRLanguage {
            if leftIconType == .font {
                rect.origin.x = 0
                if rightIconType != .font {
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            if leftIconType != .font {
                rect.origin.x += CGFloat(iconWidth + iconMarginLeft)
                if rightIconType != .font {
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            
        } else {
            if leftIconType == .font {
                if rightIconType != .font {
                    rect.origin.x = CGFloat(iconWidth + iconMarginLeft)
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            if leftIconType != .font {
                rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                if rightIconType != .font {
                    rect.origin.x += CGFloat(iconWidth + iconMarginLeft)
                }
            }
        }
        return rect
    }
    
    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        
        if isLTRLanguage {
            if leftIconType == .font {
                rect.origin.x = 0
                if rightIconType != .font {
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            if leftIconType != .font {
                rect.origin.x += CGFloat(iconWidth + iconMarginLeft)
                if rightIconType != .font {
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            
        } else {
            if leftIconType == .font {
                if rightIconType != .font {
                    rect.origin.x = CGFloat(iconWidth + iconMarginLeft)
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            if leftIconType != .font {
                rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                if rightIconType != .font {
                    rect.origin.x += CGFloat(iconWidth + iconMarginLeft)
                }
            }
        }
        return rect
    }
    
    /**
     Calculates the bounds for the placeholder component of the control.
     Override to create a custom size textbox in the control.
     - parameter bounds: The current bounds of the placeholder component
     - returns: The rectangle that the placeholder component should render in
     */
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)
        
        //        if isLTRLanguage {
        //            rect.origin.x += CGFloat(iconWidth + iconMarginLeft)
        //        } else {
        //            // don't change the editing field X position for RTL languages
        //        }
        //        rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
        if isLTRLanguage {
            if leftIconType == .font {
                rect.origin.x = 0
                if rightIconType != .font {
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            if leftIconType != .font {
                rect.origin.x += CGFloat(iconWidth + iconMarginLeft)
                if rightIconType != .font {
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            
        } else {
            if leftIconType == .font {
                if rightIconType != .font {
                    rect.origin.x = CGFloat(iconWidth + iconMarginLeft)
                    rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                }
            }
            if leftIconType != .font {
                rect.size.width -= CGFloat(iconWidth + iconMarginLeft)
                if rightIconType != .font {
                    rect.origin.x += CGFloat(iconWidth + iconMarginLeft)
                }
            }
            // don't change the editing field X position for RTL languages
        }
        return rect
    }
    
    /// Invoked by layoutIfNeeded automatically
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
    
    fileprivate func updateFrame() {
        let textWidth: CGFloat = bounds.size.width
        if isLTRLanguage {
            iconLabel.frame = CGRect(
                x: 0,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            leftIconImageView.frame = CGRect(
                x: 0,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            leftIconButtonView.frame = CGRect(
                x: 0,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            rightIconImageView.frame = CGRect(
                x: textWidth - iconWidth,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            rightIconButtonView.frame = CGRect(
                x: textWidth - iconWidth,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
        } else {
            iconLabel.frame = CGRect(
                x: textWidth - iconWidth,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            leftIconImageView.frame = CGRect(
                x: textWidth - iconWidth,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            leftIconButtonView.frame = CGRect(
                x: textWidth - iconWidth,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            rightIconImageView.frame = CGRect(
                x: 0,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
            rightIconButtonView.frame = CGRect(
                x: 0,
                y: bounds.size.height - textHeight() - iconMarginBottom,
                width: iconWidth,
                height: textHeight()
            )
        }
    }
    
}
