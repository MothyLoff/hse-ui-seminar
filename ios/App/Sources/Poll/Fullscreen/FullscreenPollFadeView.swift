import UIKit


final class FullscreenPollFadeView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    override func updateProperties() {
        super.updateProperties()
        let color = UIColor.systemBackground.resolvedColor(with: traitCollection)
        let gradient = layer as! CAGradientLayer
        gradient.colors = [color.withAlphaComponent(0).cgColor, color.cgColor]
    }

}
