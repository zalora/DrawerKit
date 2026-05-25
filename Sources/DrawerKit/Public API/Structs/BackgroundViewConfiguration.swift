import UIKit

public struct BackgroundViewConfiguration {
    
    public var backgroundColor: UIColor
    public var isBlurEnabled: Bool
    
    public init(backgroundColor: UIColor = .clear,
                isBlurEnabled: Bool = false) {
        self.backgroundColor = backgroundColor
        self.isBlurEnabled = isBlurEnabled
    }
    
}

extension BackgroundViewConfiguration: Equatable {
    public static func ==(lhs: BackgroundViewConfiguration, rhs: BackgroundViewConfiguration) -> Bool {
        return lhs.backgroundColor == rhs.backgroundColor
            && lhs.isBlurEnabled == rhs.isBlurEnabled
    }
}
