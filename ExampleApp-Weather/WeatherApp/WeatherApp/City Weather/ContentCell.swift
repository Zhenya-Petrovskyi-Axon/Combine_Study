//
//  ContentCell.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/21/20.
//

import UIKit

class ContentCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView = GradientView(colors: [UIColor(named: "weatherBlue100")!, UIColor(named: "weatherBlue200")!])
    }
    
    var content: UIView? {
        willSet {
            if contentView.subviews.first == newValue {
                return
            }
            
            contentView.subviews.first?.removeFromSuperview()
            if let innerContentView = newValue {
                innerContentView.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(innerContentView)
                innerContentView.constrainToFill(contentView)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
