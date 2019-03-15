import UIKit
import DrawerKit

class PresenterViewController: UIViewController, DrawerCoordinating {
    /* strong */ var drawerDisplayController: DrawerDisplayController?

    @IBAction func presentButtonTapped() {
        doModalPresentation(passthrough: false)
    }

    @IBAction func presentButtonDoubleTapped() {
        doModalPresentation(passthrough: true)
    }

    @IBAction func alertButtonTapped() {
        let alert = UIAlertController(title: "Alert", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        (self.presentedViewController ?? self).present(alert, animated: true, completion: nil)
    }
}

private extension PresenterViewController {
    func doModalPresentation(passthrough: Bool) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "presented")
            as? PresentedNavigationController else { return }

        // you can provide the configuration values in the initialiser...
        var configuration = DrawerConfiguration(/* ..., ..., ..., */)

        // ... or after initialisation. All of these have default values so change only
        // what you need to configure differently. They're all listed here just so you
        // can see what can be configured. The values listed are the default ones,
        // except where indicated otherwise.
//        configuration.initialState = .collapsed
        configuration.totalDurationInSeconds = 0.4
        configuration.durationIsProportionalToDistanceTraveled = false
        // default is UISpringTimingParameters()
        configuration.timingCurveProvider = UISpringTimingParameters(dampingRatio: 0.8)
        configuration.fullExpansionBehaviour = .leavesCustomGap(gap: self.view.bounds.height * 0.05)
        configuration.supportsPartialExpansion = true
        configuration.dismissesInStages = true
        configuration.isDrawerDraggable = true
        configuration.isFullyPresentableByDrawerTaps = true
        configuration.numberOfTapsForFullDrawerPresentation = 1
        configuration.isDismissableByOutsideDrawerTaps = true
        configuration.numberOfTapsForOutsideDrawerDismissal = 1
        configuration.flickSpeedThreshold = 3
        configuration.upperMarkGap = 100 // default is 40
        configuration.lowerMarkGap =  80 // default is 40
        configuration.maximumCornerRadius = 15
        configuration.cornerAnimationOption = .none
        configuration.passthroughTouchesInStates = passthrough ? [.collapsed, .partiallyExpanded] : []

        var handleViewConfiguration = HandleViewConfiguration()
        handleViewConfiguration.autoAnimatesDimming = false
        handleViewConfiguration.backgroundColor = .clear
        handleViewConfiguration.size = CGSize(width: 40, height: 6)
        handleViewConfiguration.top = 8
        handleViewConfiguration.cornerRadius = .automatic
        handleViewConfiguration.openingImage = UIImage(named: "opening-swipe")
        handleViewConfiguration.closingImage = UIImage(named: "closing-swipe")
        configuration.handleViewConfiguration = handleViewConfiguration
        
        var backgroundConfiguration = BackgroundViewConfiguration()
        backgroundConfiguration.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        configuration.backgroundViewConfiguration = backgroundConfiguration

        let borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        let drawerBorderConfiguration = DrawerBorderConfiguration(borderThickness: 0.5,
                                                                  borderColor: borderColor)
//        configuration.drawerBorderConfiguration = drawerBorderConfiguration // default is nil

        // shadow isn't compatible with background at the moment
        let drawerShadowConfiguration = DrawerShadowConfiguration(shadowOpacity: 1.0,
                                                                  shadowRadius: 10,
                                                                  shadowOffset: .zero,
                                                                  shadowColor: .black)
//        configuration.drawerShadowConfiguration = drawerShadowConfiguration // default is nil

        drawerDisplayController = DrawerDisplayController(presentingViewController: self,
                                                          presentedViewController: vc,
                                                          configuration: configuration,
                                                          inDebugMode: true)

        present(vc, animated: true)
    }
}
