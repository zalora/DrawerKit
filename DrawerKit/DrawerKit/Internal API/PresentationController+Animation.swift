import UIKit

extension PresentationController {
    func animateTransition(to endingState: DrawerState, animateAlongside: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let startingState = currentDrawerState

        let maxCornerRadius = maximumCornerRadius
        let endingCornerRadius = cornerRadius(at: endingState)

        let (startingPositionY, endingPositionY) = positionsY(startingState: startingState,
                                                              endingState: endingState)

        let animator = makeAnimator(startingPositionY: startingPositionY,
                                    endingPositionY: endingPositionY)

        let presentingVC = presentingViewController
        let presentedVC = presentedViewController

        let presentedViewFrame = presentedView?.frame ?? .zero

        var startingFrame = presentedViewFrame
        startingFrame.origin.y = startingPositionY

        var endingFrame = presentedViewFrame
        endingFrame.origin.y = endingPositionY

        let geometry = AnimationSupport.makeGeometry(containerBounds: containerViewBounds,
                                                     startingFrame: startingFrame,
                                                     endingFrame: endingFrame,
                                                     presentingVC: presentingVC,
                                                     presentedVC: presentedVC)

        let info = AnimationSupport.makeInfo(startDrawerState: startingState,
                                             targetDrawerState: endingState,
                                             configuration,
                                             geometry,
                                             animator.duration,
                                             endingPositionY < startingPositionY)

        let endingHandleViewAlpha = handleViewAlpha(at: endingState)
        let autoAnimatesDimming = configuration.handleViewConfiguration?.autoAnimatesDimming ?? false
        let handleViewHasImages = handleViewConfiguration?.hasImages ?? false
        if autoAnimatesDimming && !handleViewHasImages { self.handleView?.alpha = handleViewAlpha(at: startingState) }
        if handleViewHasImages { self.handleView?.image = handleViewImage(at: startingState) }
        
        let endBackgroundViewAlpha = backgroundViewAlpha(at: endingState)
        self.backgroundView?.alpha = backgroundViewAlpha(at: startingState)

        let presentingAnimationActions = self.presentingDrawerAnimationActions
        let presentedAnimationActions = self.presentedDrawerAnimationActions

        AnimationSupport.clientPrepareViews(presentingDrawerAnimationActions: presentingAnimationActions,
                                            presentedDrawerAnimationActions: presentedAnimationActions,
                                            info)

        targetDrawerState = endingState

        animator.addAnimations {
            self.currentDrawerY = endingPositionY
            self.backgroundView?.alpha = endBackgroundViewAlpha
            if autoAnimatesDimming && !handleViewHasImages { self.handleView?.alpha = endingHandleViewAlpha }
            if handleViewHasImages { self.handleView?.image = self.handleViewImage(at: endingState) }
            if maxCornerRadius != 0 { self.currentDrawerCornerRadius = endingCornerRadius }
            AnimationSupport.clientAnimateAlong(presentingDrawerAnimationActions: presentingAnimationActions,
                                                presentedDrawerAnimationActions: presentedAnimationActions,
                                                info)
            animateAlongside?()
        }

        animator.addCompletion { endingPosition in
            if autoAnimatesDimming && !handleViewHasImages { self.handleView?.alpha = endingHandleViewAlpha }
            let isStartingStateDismissed = (startingState == .dismissed)
            let isEndingStateDismissed = (endingState == .dismissed)
            self.backgroundView?.alpha = endBackgroundViewAlpha
            if handleViewHasImages { self.handleView?.image = self.handleViewImage(at: endingState) }

            let shouldDismiss =
                (isStartingStateDismissed && endingPosition == .start) ||
                    (isEndingStateDismissed && endingPosition == .end)

            if shouldDismiss {
                self.presentedViewController.dismiss(animated: true)
            }

            let isStartingStateDismissedOrFullyExpanded =
                (startingState == .dismissed || startingState == .fullyExpanded)

            let isEndingStateDismissedOrFullyExpanded =
                (endingState == .dismissed || endingState == .fullyExpanded)

            let shouldSetCornerRadiusToZero =
                (isStartingStateDismissedOrFullyExpanded && endingPosition == .end) ||
                (isEndingStateDismissedOrFullyExpanded && endingPosition == .start)

            if maxCornerRadius != 0
                && shouldSetCornerRadiusToZero
                && self.configuration.cornerAnimationOption != .none {
                self.currentDrawerCornerRadius = 0
            }

            if endingPosition != .end {
                self.targetDrawerState = GeometryEvaluator.drawerState(for: self.currentDrawerY,
                                                                       drawerCollapsedHeight: self.drawerCollapsedHeight,
                                                                       drawerPartialHeight: self.drawerPartialY,
                                                                       containerViewHeight: self.containerViewHeight,
                                                                       configuration: self.configuration)
            }

            AnimationSupport.clientCleanupViews(presentingDrawerAnimationActions: presentingAnimationActions,
                                                presentedDrawerAnimationActions: presentedAnimationActions,
                                                endingPosition,
                                                info)

            completion?()
        }

        animator.startAnimation()
    }

    func addCornerRadiusAnimationEnding(at endingState: DrawerState) {
        let drawerFullY = configuration.fullExpansionBehaviour.drawerFullY
        guard maximumCornerRadius != 0
            && drawerPartialY != drawerFullY
            && endingState != currentDrawerState
            else { return }

        let startingState = currentDrawerState
        let (startingPositionY, endingPositionY) = positionsY(startingState: startingState,
                                                              endingState: endingState)

        let animator = makeAnimator(startingPositionY: startingPositionY,
                                    endingPositionY: endingPositionY)

        let endingCornerRadius = cornerRadius(at: endingState)
        animator.addAnimations {
            self.currentDrawerCornerRadius = endingCornerRadius
        }

        let isStartingStateDismissedOrFullyExpanded =
            (startingState == .dismissed || startingState == .fullyExpanded)

        let isEndingStateDismissedOrFullyExpanded =
            (endingState == .dismissed || endingState == .fullyExpanded)

        if isStartingStateDismissedOrFullyExpanded || isEndingStateDismissedOrFullyExpanded {
            animator.addCompletion { endingPosition in
                let shouldSetCornerRadiusToZero =
                    (isEndingStateDismissedOrFullyExpanded && endingPosition == .end) ||
                    (isStartingStateDismissedOrFullyExpanded && endingPosition == .start)
                if shouldSetCornerRadiusToZero && self.configuration.cornerAnimationOption != .none {
                    self.currentDrawerCornerRadius = 0
                }
            }
        }

        animator.startAnimation()
    }

    private func makeAnimator(startingPositionY: CGFloat,
                              endingPositionY: CGFloat) -> UIViewPropertyAnimator {
        let duration =
            AnimationSupport.actualTransitionDuration(from: startingPositionY,
                                                      to: endingPositionY,
                                                      containerViewHeight: containerViewHeight,
                                                      configuration: configuration)

        return UIViewPropertyAnimator(duration: duration,
                                      timingParameters: timingCurveProvider)
    }

    private func positionsY(startingState: DrawerState,
                            endingState: DrawerState) -> (starting: CGFloat, ending: CGFloat) {
        let drawerFullY = configuration.fullExpansionBehaviour.drawerFullY
        let startingPositionY =
            GeometryEvaluator.drawerPositionY(for: startingState,
                                              drawerCollapsedHeight: drawerCollapsedHeight,
                                              drawerPartialHeight: drawerPartialHeight,
                                              containerViewHeight: containerViewHeight,
                                              drawerFullY: drawerFullY)

        let endingPositionY =
            GeometryEvaluator.drawerPositionY(for: endingState,
                                              drawerCollapsedHeight: drawerCollapsedHeight,
                                              drawerPartialHeight: drawerPartialHeight,
                                              containerViewHeight: containerViewHeight,
                                              drawerFullY: drawerFullY)

        return (startingPositionY, endingPositionY)
    }
}
