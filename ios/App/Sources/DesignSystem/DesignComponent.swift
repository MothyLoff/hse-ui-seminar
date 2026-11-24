import UIKit


enum DesignComponent {
    enum DefaultFontSize {
        static let title: CGFloat = 24
        static let body: CGFloat = 18
        static let tag: CGFloat = 16
    }
    
    enum Poll {
        enum Header {
            static let spacing: CGFloat = 8
        }
        
        enum OptionList {
            static let spacing: CGFloat = 4
            static let padding: CGFloat = 8
        }
        
        enum Tag {
            static let spacing: CGFloat = 2
            
            enum Padding {
                enum Inner {
                    static let horizontal: CGFloat = 14
                    static let vertical: CGFloat = 4
                }
            }
            
            static let offset: CGSize = .init(width: 0, height: -6)
            
            static let strokeVisibleWidth: CGFloat = 3
        }
    }
}


extension DesignComponent {

    static func bodySemibold(
        compatibleWith traits: UITraitCollection
    ) -> UIFont {
        let font = UIFont.systemFont(
            ofSize: DefaultFontSize.body,
            weight: .semibold
        )
        return UIFontMetrics(forTextStyle: .body).scaledFont(
            for: font,
            compatibleWith: traits
        )
    }

}


extension DesignComponent.Poll {
    enum Option {
        static let height: CGFloat = 52
        
        enum Bullet {
            static let radius: CGFloat = 8
            static let spacing: CGFloat = 6
        }
    }
}


//MARK: --- computed values

extension DesignComponent.Poll {
    enum Background {
        static let cornerRadius: CGFloat = Option.radius + OptionList.padding
    }
}


extension DesignComponent.Poll.Header {
    enum Padding {
        static let horizontal: CGFloat = DesignComponent.Poll.Option.radius
            + DesignComponent.Poll.OptionList.padding
            - DesignComponent.DefaultFontSize.title / 2
        static let vertical: CGFloat = horizontal - 2
    }
}


extension DesignComponent.Poll.Option {
    static let radius: CGFloat = height / 2
    
    enum Padding {
        static let leading: CGFloat = radius - Bullet.radius
        static let vertical: CGFloat = radius - Bullet.radius
        static let trailing: CGFloat = radius - DesignComponent.DefaultFontSize.body / 2
    }
}


extension DesignComponent.Poll.Option.Bullet {
    static let size: CGSize = .init(width: radius * 2, height: radius * 2)
}


extension DesignComponent.Poll.Tag {
    static let strokeWidth: CGFloat = strokeVisibleWidth * 2
}


extension DesignComponent.Poll.Tag.Padding {
    enum Outer {
        static let horizontal: CGFloat = DesignComponent.Poll.Background.cornerRadius
    }
}

