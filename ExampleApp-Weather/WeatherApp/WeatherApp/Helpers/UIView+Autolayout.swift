//
//  UIView+Autolayout.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/20/20.
//

import UIKit

extension UIView {
    func constrainToFill(_ parent: UIView) {
        assert(superview != nil, "Must add to view hierarchy first")
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            topAnchor.constraint(equalTo: parent.topAnchor),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
    }
}
