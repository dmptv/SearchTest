//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by 123 on 02.04.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        // remove underlying view of parent VC
        return false
    }
    
    lazy var dimmingView = GradientView(frame: .zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        animateView(self.dimmingView, alpha: 1)
    }
 
    override func dismissalTransitionWillBegin()  {
        animateView(self.dimmingView, alpha: 0)
    }
    
    fileprivate func animateView(_ view: UIView, alpha: CGFloat) {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                view.alpha = alpha
            }, completion: nil)
        }
    }
    
}










