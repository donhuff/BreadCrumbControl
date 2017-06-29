//
//  Copyright 2015 Philippe Kersalé
//

import UIKit

let kStartButtonWidth:CGFloat = 44
let kBreadcrumbHeight:CGFloat = 44
let kBreadcrumbCover:CGFloat = 15


enum OperatorItem {
    case addItem
    case removeItem
}

enum StyleBreadCrumb {
    case defaultFlatStyle
    case gradientFlatStyle
}

class ItemEvolution {
    var itemLabel: String = ""
    var operationItem: OperatorItem = OperatorItem.addItem
    var offsetX: CGFloat = 0.0
    init(itemLabel: String, operationItem: OperatorItem, offsetX: CGFloat) {
        self.itemLabel = itemLabel
        self.operationItem = operationItem
        self.offsetX = offsetX
    }
}

class EventItem {
    var itemsEvolution: [ItemEvolution]!
}



@IBDesignable class CBreadcrumbControl: UIControl{
    
    
    var _items: [String] = []
    var _itemViews: [UIButton] = []

    var containerView: UIView!
    var startButton: UIButton!
    
    var color: UIColor = UIColor.blue
    fileprivate var _animating: Bool = false
   
    fileprivate var animationInProgress: Bool = false
    
    // used if you send a new itemsBreadCrumb when "animationInProgress == true"
    fileprivate var itemsBCInWaiting: Bool = false

    // item selected
    var itemClicked: String!
    var itemPositionClicked: Int = -1

    func register() {
        NotificationCenter.default.addObserver(self, selector: #selector(CBreadcrumbControl.receivedUINotificationNewItems(_:)), name:NSNotification.Name(rawValue: "NotificationNewItems"), object: nil)
    }
    
    
    @IBInspectable var style: StyleBreadCrumb = .gradientFlatStyle {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var visibleRootButton: Bool = true {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var textBCColor: UIColor = UIColor.black {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var backgroundRootButtonColor: UIColor = UIColor.white {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var backgroundBCColor: UIColor = UIColor.clear {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var itemPrimaryColor: UIColor = UIColor.gray {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var offsetLastPrimaryColor: CGFloat = 16.0 {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var animationSpeed: Double = 0.2 {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var arrowColor: UIColor = UIColor.blue {
        didSet{
            //drawRect( self.frame)
            initialSetup( true)
        }
    }

    
    @IBInspectable var itemsBreadCrumb: [String] = [] {
        didSet{
            if (!self.animationInProgress) {
                self.itemClicked = ""
                self.itemPositionClicked = -1
                initialSetup( false)
            } else {
                itemsBCInWaiting = true
            }
        }
    }
    
    @IBInspectable var iconSize: CGSize = CGSize(width: 20, height: 20){
        didSet{
            //setNeedsDisplay()
            initialSetup( true)
        }
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register()
        initialSetup( true)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup( true)
    }

    
    func initialSetup( _ refresh: Bool) {
        
        var changeRoot: Int = 0
        if ((visibleRootButton) && (self.startButton == nil)) {
            self.startButton = self.startRootButton()
            changeRoot = 1
        } else if ((visibleRootButton == false) && (self.startButton != nil)){
            changeRoot = 2
        }
        if (self.containerView == nil ) {
            let rectContainerView: CGRect = CGRect( x: kStartButtonWidth+1, y: 0, width: self.bounds.size.width - (kStartButtonWidth+1), height: kBreadcrumbHeight)
            self.containerView = UIView(frame:rectContainerView)
            self.containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview( self.containerView)
        }

        self.containerView.backgroundColor = backgroundBCColor  //UIColor.whiteColor()
        self.containerView.clipsToBounds = true
        if ((visibleRootButton) && (self.startButton != nil)) {
            self.startButton.backgroundColor = backgroundRootButtonColor
        }
        
        if (changeRoot == 1) {
            self.addSubview( self.startButton)
            let rectContainerView: CGRect = CGRect( x: kStartButtonWidth+1, y: 0, width: self.bounds.size.width - (kStartButtonWidth+1), height: kBreadcrumbHeight)
            self.containerView.frame = rectContainerView
        } else if (changeRoot == 2) {
            self.startButton.removeFromSuperview()
            self.startButton = nil
            let rectContainerView: CGRect = CGRect( x: 0, y: 0, width: self.bounds.size.width, height: kBreadcrumbHeight)
            self.containerView.frame = rectContainerView
        }
        
        self.setItems( self.itemsBreadCrumb, refresh: refresh, containerView: self.containerView)
            
    }


    func startRootButton() -> UIButton
    {
        let button: UIButton = UIButton(type: UIButtonType.custom) as UIButton
        button.backgroundColor = backgroundRootButtonColor
        let bgImage : UIImage = UIImage( named: "button_start.png")!
        button.setBackgroundImage( bgImage, for: UIControlState())
        button.frame = CGRect(x: 0, y: 0, width: kStartButtonWidth+1, height: kBreadcrumbHeight)
        button.addTarget(self, action: #selector(CBreadcrumbControl.pressed(_:)), for: .touchUpInside)

        return button
    }
    
    func itemButton( _ item: String, position: Int) -> MyCustomButton
    {
        let button: MyCustomButton = MyCustomButton() as MyCustomButton
        if (self.style == .gradientFlatStyle) {
            button.styleButton = .extendButton
            let rgbValueTmp = self.itemPrimaryColor.cgColor.components
            let red = rgbValueTmp?[0]
            let green = rgbValueTmp?[1]
            let blue = rgbValueTmp?[2]
            //var rgbValue: Double = Double(rgbValueTmp)
            //var rgbValue = 0x777777
            //let rPrimary:CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
            //let gPrimary:CGFloat = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
            //let bPrimary:CGFloat = CGFloat((rgbValue & 0xFF))/255.0
            let rPrimary:CGFloat = CGFloat(red! * 255.0)
            let gPrimary:CGFloat = CGFloat(green! * 255.0)
            let bPrimary:CGFloat = CGFloat(blue! * 255.0)

            
            let levelRedPrimaryColor: CGFloat = rPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let levelGreenPrimaryColor: CGFloat = gPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let levelBluePrimaryColor: CGFloat = bPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let r = levelRedPrimaryColor/255.0
            let g = levelGreenPrimaryColor/255.0
            let b = levelBluePrimaryColor/255.0
            button.backgroundCustomColor =  UIColor(red:CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        } else {
            button.styleButton = .simpleButton
            button.backgroundCustomColor = self.backgroundBCColor  //self.backgroundItemColor
            button.arrowColor = self.arrowColor
        }
        button.contentMode = UIViewContentMode.center
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitle(item, for:UIControlState())
        button.setTitleColor( textBCColor, for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        button.sizeToFit()
        let rectButton:CGRect = button.frame
        let widthButton: CGFloat = (position > 0) ? rectButton.width + 32 + kBreadcrumbCover : rectButton.width + 32
        button.frame = CGRect(x: 0, y: 0, width: widthButton , height: kBreadcrumbHeight)
        button.titleEdgeInsets = (position > 0) ? UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0) : UIEdgeInsets(top: 0.0, left: -kBreadcrumbCover, bottom: 0.0, right: 0.0)
        button.addTarget(self, action: #selector(CBreadcrumbControl.pressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    
    
    func pressed(_ sender: UIButton!) {
        let titleSelected = sender.titleLabel?.text
        if ((self.startButton != nil) && (self.startButton == sender)) {
            self.itemClicked = ""
            self.itemPositionClicked = 0
        } else {
            self.itemClicked = titleSelected
            (0 ..< _items.count).forEach { idx in
                if (titleSelected == _items[idx]) {
                    self.itemPositionClicked = idx + 1
                }
            }
        }
        self.sendActions( for: UIControlEvents.touchUpInside)
        
        /*
        let alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = "title";
        alertView.message = "message";
        alertView.show();
        */
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        var cx: CGFloat = 0  //kStartButtonWidth
        _itemViews.forEach { view in
            let s: CGSize = view.bounds.size
            view.frame = CGRect(x: cx, y: 0, width: s.width, height: s.height)
            cx += s.width
        }
        initialSetup( true)
    }
    
    
    func singleLayoutSubviews( _ view: UIView, offsetX: CGFloat) {
        super.layoutSubviews()
        
        let s: CGSize = view.bounds.size
        view.frame = CGRect(x: offsetX, y: 0, width: s.width, height: s.height)
    }
    
    
    func setItems(_ items: [String], refresh: Bool, containerView: UIView) {
        self.animationInProgress = true

        if (self._animating) {
            return
        }
        if (!refresh)
        {
            var itemsEvolution: [ItemEvolution] = [ItemEvolution]()
            // comparer with old items search the difference
            var endPosition: CGFloat = 0.0
            var idxToChange: Int = 0
            (0 ..< _items.count).forEach { idx in
                if ((idx < items.count) && (_items[idx] == items[idx])) {
                    idxToChange += 1
                    endPosition += _itemViews[idx].frame.width
                } else {
                    endPosition -= _itemViews[idx].frame.width
                    if (itemsEvolution.count > idx) {
                        itemsEvolution.insert( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.removeItem, offsetX: endPosition), at: idxToChange)
                    } else {
                        itemsEvolution.append(ItemEvolution( itemLabel: _items[idx], operationItem: OperatorItem.removeItem, offsetX: endPosition))
                    }
                }
            }
            (idxToChange ..< items.count).forEach { idx in
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.addItem, offsetX: endPosition))
            }
            
            processItem( itemsEvolution, refresh: false)
        } else {
            self.animationInProgress = false
 
            var itemsEvolution: [ItemEvolution] = [ItemEvolution]()
            // comparer with old items search the difference
            let endPosition: CGFloat = 0.0
            (0 ..< _items.count).forEach { idx in
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.removeItem, offsetX: endPosition))
            }
            (0 ..< items.count).forEach { idx in
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.addItem, offsetX: endPosition))
            }
            processItem( itemsEvolution, refresh: true)
        }
    }
    
    
    func processItem( _ itemsEvolution: [ItemEvolution], refresh: Bool) {
        //    _itemViews
        if (itemsEvolution.count > 0) {
            var itemsEvolutionToSend: [ItemEvolution] = [ItemEvolution]()
            (1 ..< itemsEvolution.count).forEach { idx in
                itemsEvolutionToSend.append( ItemEvolution( itemLabel: itemsEvolution[idx].itemLabel, operationItem: itemsEvolution[idx].operationItem, offsetX: itemsEvolution[idx].offsetX))
            }
            
            if (itemsEvolution[0].operationItem == OperatorItem.addItem) {
                //create a new UIButton
                var startPosition: CGFloat = 0
                var endPosition: CGFloat = 0
                if (_itemViews.count > 0) {
                    let indexTmp = _itemViews.count - 1
                    let lastViewShowing: UIView = _itemViews[indexTmp]
                    let rectLastViewShowing: CGRect = lastViewShowing.frame
                    endPosition = rectLastViewShowing.origin.x + rectLastViewShowing.size.width - kBreadcrumbCover
                }
                let label = itemsEvolution[0].itemLabel
                let itemButton: UIButton = self.itemButton( label, position: _itemViews.count)
                let widthButton: CGFloat = itemButton.frame.size.width
                startPosition = (_itemViews.count > 0) ? endPosition - widthButton - kBreadcrumbCover : endPosition - widthButton
                var rectUIButton = itemButton.frame
                rectUIButton.origin.x = startPosition;
                itemButton.frame = rectUIButton
                containerView.insertSubview( itemButton, at: 0)
                _itemViews.append(itemButton)
                _items.append( label)

                if (!refresh) {
                    UIView.animate( withDuration: self.animationSpeed, delay: 0, options:UIViewAnimationOptions(), animations: {
                        self.sizeToFit()
                        self.singleLayoutSubviews( itemButton, offsetX: endPosition)
                        } , completion: { finished in
                            self._animating = false
                            
                            if (itemsEvolution.count > 0) {
                                let eventItem: EventItem = EventItem()
                                eventItem.itemsEvolution = itemsEvolutionToSend
                                
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationNewItems"), object: eventItem)
                            } else {
                                self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                            }
                    })
                } else {
                    self.sizeToFit()
                    self.singleLayoutSubviews( itemButton, offsetX: endPosition)
                    if (itemsEvolution.count > 0) {
                        processItem( itemsEvolutionToSend, refresh: true)
                    } else {
                        self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                    }
                }
            } else {
                
                //create a new UIButton
                var startPosition: CGFloat = 0
                var endPosition: CGFloat = 0
                if (_itemViews.count == 0) {
                    return
                }
                
                let indexTmp = _itemViews.count - 1
                let lastViewShowing: UIView = _itemViews[indexTmp]
                let rectLastViewShowing: CGRect = lastViewShowing.frame
                startPosition = rectLastViewShowing.origin.x
                let widthButton: CGFloat = lastViewShowing.frame.size.width
                endPosition = startPosition - widthButton
                var rectUIButton = lastViewShowing.frame
                rectUIButton.origin.x = startPosition;
                lastViewShowing.frame = rectUIButton
                
                
                if (!refresh) {
                    UIView.animate( withDuration: self.animationSpeed, delay: 0, options:UIViewAnimationOptions(), animations: {
                        self.sizeToFit()
                        self.singleLayoutSubviews( lastViewShowing, offsetX: endPosition)
                        } , completion: { finished in
                            self._animating = false
                            
                            lastViewShowing.removeFromSuperview()
                            self._itemViews.removeLast()
                            self._items.removeLast()

                            
                            if (itemsEvolution.count > 0) {
                                let eventItem: EventItem = EventItem()
                                eventItem.itemsEvolution = itemsEvolutionToSend
                                
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationNewItems"), object: eventItem)
                            } else {
                                self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                            }
                    })
                } else {
                    self.sizeToFit()
                    self.singleLayoutSubviews( lastViewShowing, offsetX: endPosition)
                    lastViewShowing.removeFromSuperview()
                    self._itemViews.removeLast()
                    self._items.removeLast()
                    if (itemsEvolution.count > 0) {
                        processItem( itemsEvolutionToSend, refresh: true)
                    } else {
                        self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                    }
                }

            }
        } else {
            self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
        }
    }
    
    func receivedUINotificationNewItems(_ notification: Notification){
        let event: AnyObject? = notification.object as AnyObject
        if let eventItems = event as? EventItem {
            processItem( eventItems.itemsEvolution, refresh: false)
        }
    }

    func processIfItemsBreadCrumbInWaiting() {
        self.animationInProgress = false
        if (itemsBCInWaiting == true) {
            itemsBCInWaiting = false
            self.itemClicked = ""
            initialSetup( false)
        }
    }

    
}
