//
//  SectionSeparatorView.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/23/20.
//

import UIKit

class SectionSeparatorView: UICollectionReusableView {
    static let reuseIdentifier = "SectionSeparatorView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        isOpaque = false
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        UIColor.white.withAlphaComponent(0.3).setStroke()
        context.setLineWidth(1)
        context.clear(bounds)
        
        context.move(to: bounds.origin)
        context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        
        context.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        context.strokePath()
    }
}
