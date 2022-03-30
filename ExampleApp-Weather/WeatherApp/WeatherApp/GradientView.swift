//
//  GradientView.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import UIKit

class GradientView: UIView {
    var colors: [UIColor] = [.red, .blue] {
        didSet {
            updateGradient()
            setNeedsDisplay()
        }
    }
    
    init(colors: [UIColor]) {
        self.colors = colors
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var gradient: CGGradient!
    private func updateGradient() {
        assert(colors.count == 2, "must provide exactly 2 colors")
        let cgColors = colors.map { $0.cgColor } as CFArray
        let locations: [CGFloat] = [0, 1]
        gradient = CGGradient(colorsSpace: nil, colors: cgColors, locations: locations)
    }
    
    override func layoutSubviews() {
        if gradient == nil {
            updateGradient()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: rect.midX, y: rect.minY),
                                   end: CGPoint(x: rect.midX, y: rect.maxY),
                                   options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
    }
}
