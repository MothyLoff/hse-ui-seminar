import UIKit


final class OptionFadeView: UIView {
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    override func updateProperties() {
        super.updateProperties()
        
        let gradient = layer as! CAGradientLayer
        let color = UIColor.secondarySystemBackground.resolvedColor(
            with: traitCollection
        )
        
        gradient.colors = [
            color.withAlphaComponent(0).cgColor,
            color.cgColor
        ]
    }
    
}
