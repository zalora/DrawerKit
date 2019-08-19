import UIKit

extension PresentationController {
    func setupPresentationContainerView() {
        guard self.presentationContainerView == nil else { return }

        let presentationContainerView = PresentationContainerView()
        presentationContainerView.touchDelegate = self
        presentationContainerView.backgroundColor = .clear
        presentationContainerView.frame = containerView?.superview?.frame ?? .zero
        presentationContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let containerView = containerView {
            containerView.superview?.addSubview(presentationContainerView)
            presentationContainerView.addSubview(containerView)
        }

        self.presentationContainerView = presentationContainerView
    }

    func removePresentationContainerView() {
        // the containerView is removed by UIKit when dismissal ends
        // so it's not necessary to restore it in its original superview
        presentationContainerView.removeFromSuperview()
    }
}

extension PresentationController {
    func setupDrawerFullExpansionTapRecogniser() {
        guard drawerFullExpansionTapGR == nil else { return }
        let isFullyPresentable = isFullyPresentableByDrawerTaps
        let numTapsRequired = numberOfTapsForFullDrawerPresentation
        guard isFullyPresentable && numTapsRequired > 0 else { return }
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleDrawerFullExpansionTap))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = numTapsRequired
        tapGesture.cancelsTouchesInView = false
        tapGesture.delaysTouchesBegan = false
        tapGesture.delaysTouchesEnded = false
        tapGesture.delegate = self
        presentedView?.addGestureRecognizer(tapGesture)
        drawerFullExpansionTapGR = tapGesture
    }

    func removeDrawerFullExpansionTapRecogniser() {
        guard let tapGesture = drawerFullExpansionTapGR else { return }
        presentedView?.removeGestureRecognizer(tapGesture)
        drawerFullExpansionTapGR = nil
    }

    func enableDrawerFullExpansionTapRecogniser(enabled: Bool) {
        drawerFullExpansionTapGR?.isEnabled = enabled
    }
}

extension PresentationController {
    func setupDrawerDismissalTapRecogniser() {
        guard drawerDismissalTapGR == nil else { return }
        let isDismissable = isDismissableByOutsideDrawerTaps
        let numTapsRequired = numberOfTapsForOutsideDrawerDismissal
        guard isDismissable && numTapsRequired > 0 else { return }
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDismissalTap))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = numTapsRequired
        tapGesture.cancelsTouchesInView = false
        tapGesture.delaysTouchesBegan = false
        tapGesture.delaysTouchesEnded = false
        tapGesture.delegate = self
        containerView?.addGestureRecognizer(tapGesture)
        drawerDismissalTapGR = tapGesture
    }

    func removeDrawerDismissalTapRecogniser() {
        guard let tapGesture = drawerDismissalTapGR else { return }
        containerView?.removeGestureRecognizer(tapGesture)
        drawerDismissalTapGR = nil
    }
    
    func enableDrawerDismissalTapRecogniser(enabled: Bool) {
        drawerDismissalTapGR?.isEnabled = enabled
    }
}

extension PresentationController {
    func setupDrawerDismissalHandleViewTapRecogniser() {
        guard drawerDismissalHandleViewTapGR == nil else { return }
        let isDismissable = isDismissableByHandleViewTapsForFullDrawerPresentation
        let numTapsRequired = numberOfTapsForHandleViewDismissal
        guard isDismissable && numTapsRequired > 0 else { return }
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDismissalHandleViewTap))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = numTapsRequired
        tapGesture.cancelsTouchesInView = false
        tapGesture.delaysTouchesBegan = false
        tapGesture.delaysTouchesEnded = false
        tapGesture.delegate = self
        handleView?.addGestureRecognizer(tapGesture)
        drawerDismissalHandleViewTapGR = tapGesture
    }
    
    func removeDrawerDismissalHandleViewTapRecogniser() {
        guard let tapGesture = drawerDismissalHandleViewTapGR else { return }
        handleView?.removeGestureRecognizer(tapGesture)
        drawerDismissalHandleViewTapGR = nil
    }
    
    func enableDrawerDismissalHandleViewTapRecogniser(enabled: Bool) {
        drawerDismissalHandleViewTapGR?.isEnabled = enabled
    }
}

extension PresentationController {
    func setupDrawerDragRecogniser() {
        guard drawerDragGR == nil, isDrawerDraggable else { return }
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleDrawerDrag))
        presentedView?.addGestureRecognizer(panGesture)
        drawerDragGR = panGesture
    }

    func removeDrawerDragRecogniser() {
        guard let panGesture = drawerDragGR else { return }
        presentedView?.removeGestureRecognizer(panGesture)
        drawerDragGR = nil
    }
}

extension PresentationController {
    func setupDrawerBorder() {
        if let drawerBorderConfig = configuration.drawerBorderConfiguration {
            presentedView?.layer.borderWidth = drawerBorderConfig.borderThickness
            presentedView?.layer.borderColor = drawerBorderConfig.borderColor?.cgColor
        }
    }

    func setupDrawerShadow() {
        if let drawerShadowConfig = configuration.drawerShadowConfiguration {
            containerView?.layer.shadowColor = drawerShadowConfig.shadowColor?.cgColor
            containerView?.layer.shadowOpacity = Float(drawerShadowConfig.shadowOpacity)
            containerView?.layer.shadowRadius = drawerShadowConfig.shadowRadius
            containerView?.layer.shadowOffset = drawerShadowConfig.shadowOffset
        }
    }
}

extension PresentationController {
    func setupHandleView() {
        guard
            let presentedView = self.presentedView,
            let handleView = self.handleView,
            let handleConfig = configuration.handleViewConfiguration
            else { return }

        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = handleConfig.backgroundColor
        handleView.layer.masksToBounds = true
        handleView.contentMode = .scaleAspectFit

        switch handleConfig.cornerRadius {
        case .automatic:
            handleView.layer.cornerRadius = handleConfig.size.height / 2
        case let .custom(radius):
            handleView.layer.cornerRadius = radius
        }
        
        if handleConfig.hasImages {
            handleView.image = configuration.supportsPartialExpansion ? handleConfig.openingImage : handleConfig.closingImage
        }

        presentedView.addSubview(handleView)

        NSLayoutConstraint.activate([
            handleView.widthAnchor.constraint(equalToConstant: handleConfig.size.width),
            handleView.heightAnchor.constraint(equalToConstant: handleConfig.size.height),
            handleView.centerXAnchor.constraint(equalTo: presentedView.centerXAnchor),
            handleView.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: handleConfig.top)
            ])
    }

    func removeHandleView() {
        self.handleView?.removeFromSuperview()
    }
}

extension PresentationController {
    func setupBackgroundView() {
        guard
            let containerView = self.containerView,
            let backgroundView = self.backgroundView,
            let backgroundconfig = configuration.backgroundViewConfiguration
            else { return }
        
        backgroundView.backgroundColor = backgroundconfig.backgroundColor   
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }
    
    func removeBackgroundView() {
        self.backgroundView?.removeFromSuperview()
    }
}

extension PresentationController {
    func setupDebugHeightMarks() {
        guard inDebugMode && (upperMarkGap > 0 || lowerMarkGap > 0),
            let containerView = containerView else { return }

        if upperMarkGap > 0 {
            let upperMarkYView = UIView()
            upperMarkYView.backgroundColor = .black
            upperMarkYView.frame = CGRect(x: 0, y: upperMarkY,
                                          width: containerView.bounds.size.width, height: 3)
            containerView.addSubview(upperMarkYView)
        }

        if lowerMarkGap > 0 {
            let lowerMarkYView = UIView()
            lowerMarkYView.backgroundColor = .black
            lowerMarkYView.frame = CGRect(x: 0, y: lowerMarkY,
                                          width: containerView.bounds.size.width, height: 3)
            containerView.addSubview(lowerMarkYView)
        }

        let drawerMarkView = UIView()
        drawerMarkView.backgroundColor = .white
        drawerMarkView.frame = CGRect(x: 0, y: drawerPartialY,
                                      width: containerView.bounds.size.width, height: 3)
        containerView.addSubview(drawerMarkView)
    }
}
