//
//  Extensions.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

public enum TimeIntervalUnit {
    case seconds, minutes, hours, days, months, years
    
    func dateComponents(_ interval: Int) -> DateComponents {
        var components:DateComponents = DateComponents()
        
        switch (self) {
        case .seconds:
            components.second = interval
        case .minutes:
            components.minute = interval
        case .days:
            components.day = interval
        case .months:
            components.month = interval
        case .years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

public struct CalTimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

// FYI: http://stackoverflow.com/questions/24116271/whats-the-cleanest-way-of-applying-map-to-a-dictionary-in-swift

public extension Int {
    var days: CalTimeInterval {
        return CalTimeInterval(interval: self, unit: TimeIntervalUnit.days);
    }
    
    var months: CalTimeInterval {
        return CalTimeInterval(interval: self, unit: TimeIntervalUnit.months);
    }
}

public func - (left:Date, right:CalTimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(-right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

public func + (left:Date, right:CalTimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

public extension DateComponents {
    init(_ day: Int, _ month:Int, _ year: Int) {
        self.init()
        
        self.day = day
        self.month = month
        self.year = year
    }
    
    init(date: Date) {
        self.init()
        
        let calendar = Calendar.current
        let dateComponents = (calendar as NSCalendar).components([.day, .month, .year, .weekday], from: date)
        
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
        self.weekday = dateComponents.weekday
    }
    
    func toDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: self)!
    }
}

public extension Date {
    init(_ day: Int, _ month:Int, _ year: Int) {
        self.init(timeInterval: 0, since: DateComponents(day, month, year).toDate())
    }
    
    var day: Int {
        get { return DateComponents(date: self).day! }
    }
    
    var weekday: Int {
        get { return DateComponents(date: self).weekday! }
    }
    
    var month: Int {
        get { return DateComponents(date: self).month! }
    }
    
    var year: Int {
        get { return DateComponents(date: self).year! }
    }
}

public func + (str: String, date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    
    return formatter.string(from: date)
}

public func + (arg1: NSMutableAttributedString?, arg2: NSMutableAttributedString?) -> NSMutableAttributedString? {
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.append(rightArg)
            return result
            
        } else {
            return arg2
        }
        
    } else {
        return arg1
    }
}

public func + (arg1: NSMutableAttributedString?, arg2: String?) -> NSMutableAttributedString? {
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.append(NSMutableAttributedString(string: rightArg))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg)
        }
        
    } else {
        return arg1
    }
}

public func + (arg1: NSMutableAttributedString?, arg2: (String?, UIColor)) -> NSMutableAttributedString? {
    if let rightArg = arg2.0 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.append(NSMutableAttributedString(string: rightArg, attributes: [NSAttributedString.Key.foregroundColor: arg2.1]))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg, attributes: [NSAttributedString.Key.foregroundColor: arg2.1])
        }
        
    } else {
        return arg1
    }
}

public func += <K,V> (left: inout Dictionary<K, [V]>, right: Dictionary<K, [V]>) {
    for (k, v) in right {
        if let leftValue = left[k] {
            left.updateValue(v + leftValue, forKey: k)
        } else {
            left.updateValue(v, forKey: k)
        }
    }
}

public func +=<K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right { left[k] = v }
}

public struct DateRange : Sequence {
    var startDate: Date
    var endDate: Date
    
    public init (_ arg1: Date, _ arg2: Date){
        startDate = arg1-1.days
        endDate = arg2
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(range: self)
    }
    
    public struct Iterator: IteratorProtocol {
        var range: DateRange
        
        public mutating func next() -> Date? {
            let nextDate = range.startDate + 1.days
            
            if range.endDate < nextDate {
                return nil
            }
            else {
                range.startDate = nextDate
                return nextDate
            }
        }
    }
}

public func >> (left: Date, right: Date) -> Int {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components(.day, from: left, to: right, options: [])
    return components.day!
}

// http://stackoverflow.com/a/29218836/995049
public extension UIColor {
    convenience init(hex: String) {
        if hex == "" {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            
        } else {
            let alpha: Float = 100
            
            // Establishing the rgb color
            var rgb: UInt32 = 0
            let s: Scanner = Scanner(string: hex)
            // Setting the scan location to ignore the leading `#`
            s.scanLocation = 1
            // Scanning the int into the rgb colors
            s.scanHexInt32(&rgb)
            
            // Creating the UIColor from hex int
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: CGFloat(alpha / 100)
            )
        }
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

public extension UIImage {
    func maskWithColor(_ color: UIColor) -> UIImage {
        let maskImage = self.cgImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        bitmapContext?.clip(to: bounds, mask: maskImage!)
        bitmapContext?.setFillColor(color.cgColor)
        bitmapContext?.fill(bounds)
        
        let cImage = bitmapContext?.makeImage()
        let coloredImage = UIImage(cgImage: cImage!)
        
        return coloredImage
    }
    
    func resize(_ sizeChange:CGSize)-> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}

public extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

public extension UIFont {
    func withTraits(_ traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(.traitBold, .traitItalic)
    }
}

public extension UIDevice {
    static var modelName: String {
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let DEVICE_IS_SIMULATOR = true
        #else
            let DEVICE_IS_SIMULATOR = false
        #endif
        
        var machineString = String()
        
        if DEVICE_IS_SIMULATOR == true
        {
            if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                machineString = dir
            }
        }
        else {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            machineString = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        }
        
        switch machineString {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return machineString
        }
    }
}

public extension UIAlertController {
    convenience init(title: String, message: String, view: UIViewController, handler: @escaping (UIAlertAction) -> ()) {
        self.init(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in handler(action) });
        addAction(defaultAction)
        view.present(self, animated: true, completion: {})
    }
}

public extension UserDefaults {
    func color(forKey defaultName: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: defaultName) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func set(_ value: UIColor?, forKey defaultName: String) {
        var colorData: NSData?
        if let color = value {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: defaultName)
    }
}

public extension UIImage {
    convenience init(background: String , inView view: UIView, bundle: Bundle?=nil) {
        let image = UIImage(named: background, in: bundle, compatibleWith: nil)
        UIGraphicsBeginImageContext(view.frame.size)
        image!.draw(in: view.bounds)
        let bgImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: (bgImage.cgImage)!)
    }
}

public let imageLoadedNotification = "IMAGE_WAS_LOADED"

extension UIImageView{
    func frameForImageInImageViewAspectFit() -> CGRect
    {
        if  let img = self.image {
            let imageRatio = img.size.width / img.size.height;
            let viewRatio = self.frame.size.width / self.frame.size.height;
            
            if(imageRatio < viewRatio)
            {
                let scale = self.frame.size.height / img.size.height;
                let width = scale * img.size.width;
                let topLeftX = (self.frame.size.width - width) * 0.5;
                
                return CGRect(x: topLeftX, y: 0, width: width, height: self.frame.size.height)
            }
            else
            {
                let scale = self.frame.size.width / img.size.width;
                let height = scale * img.size.height;
                let topLeftY = (self.frame.size.height - height) * 0.5;
                
                return CGRect(x: 0, y: topLeftY, width: self.frame.size.width, height: height)
            }
        }
        
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    func resizeToFit(_ cell: UIView) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: imageLoadedNotification), object: nil, userInfo: nil)

        if let imageCell = cell as? ImageCell {
            let rect = self.frameForImageInImageViewAspectFit()
            
            imageCell.icon!.constraints.forEach { con in
                if con.identifier == "icon-width" {
                    con.constant = rect.width
                } else if con.identifier == "icon-height" {
                    con.constant = rect.height
                }
            }
        }
        
    }
}

public extension UIImageView {
    func downloadedFrom(link:String, contentMode mode: UIView.ContentMode, cell: UIView) {
        guard let url = URL(string: link) else { return }
        
        contentMode = mode
        image = nil
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory:URL = urls.first else { return }
        
        if let bundleURL = Bundle.main.url(forResource: url.lastPathComponent, withExtension: "") {
            // print("found in bundle \(link)")
            let data = try! Data(contentsOf: bundleURL)
            image = UIImage(data: data)
            resizeToFit(cell)

            return
        }
        
        let localURL = documentDirectory.appendingPathComponent(url.lastPathComponent)
        
        if (localURL as NSURL).checkResourceIsReachableAndReturnError(nil) {
            let data = try! Data(contentsOf: localURL)
            image = UIImage(data: data)
            resizeToFit(cell)
            return
        }
        
        print("loading \(link)")
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            try? data.write(to: localURL, options: .withoutOverwriting)
            try? (localURL as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            
            DispatchQueue.main.async { () -> Void in
                self.image = image
                self.resizeToFit(cell)
                
                cell.setNeedsLayout()
                cell.setNeedsUpdateConstraints()
                cell.setNeedsDisplay()
            }
        }).resume()
    }
}

public extension UIImageView {
    convenience init(btnImage: UIImage, target: AnyObject, btnHandler: Selector) {
        self.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        image = btnImage
        contentMode = .center
        tintColor = UINavigationBar.appearance().tintColor

        let tap = UITapGestureRecognizer(target: target, action: btnHandler)
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }
}

public extension UIViewController {
    static func named(_ name: String, bundle : Bundle? = nil) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: name)
    }
}

public extension UINavigationController {
    func makeTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear
    }
}

public extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}

public func findIndex<S: Sequence>(_ sequence: S, predicate: (S.Iterator.Element) -> Bool) -> Int? {
    for (index, element) in sequence.enumerated() {
        if predicate(element) {
            return index
        }
    }
    return nil
}

public extension Collection  {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension UIViewController {
    static var popup: PopupController!
    
    func showPopup(_ vc: UIViewController, onClose handler: @escaping (PopupController) -> Void = {_ in }) {
        UIViewController.popup = PopupController
            .create(self.navigationController!)
            .customize(
                [
                    .animation(.fadeIn),
                    .layout(.center),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ]
            ).didCloseHandler(handler)
        
        UIViewController.popup.show(vc)
    }
    
    func fullScreen(view forView: UIView) {
        forView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        forView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        forView.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.frame.height ?? 0.0) + UIApplication.shared.statusBarFrame.height).isActive = true
        forView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarController?.tabBar.frame.size.height ?? 0.0)).isActive = true
    }
}

public protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

public extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        register(T.self)
        return dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as! T
    }
    
}

public extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        register(T.self)
        return dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: ReusableView {
        register(T.self)
        return dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier) as! T
    }
}
