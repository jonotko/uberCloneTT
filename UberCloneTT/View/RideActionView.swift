//
//  RideActionView.swift
//  UberCloneTT
//
//  Created by Jonathan Agarrat on 4/11/20.
//  Copyright © 2020 Jonathan Agarrat. All rights reserved.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
}

class RideActionView: UIView {
    
    // MARK: - Properties
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    weak var delegate: RideActionViewDelegate?
    
    private let titleLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 18)
           label.textAlignment = .center
        label.text = "Test Title"
           return label
       }()
       
       private let addressLabel: UILabel = {
           let label = UILabel()
           label.textColor = .lightGray
           label.font = UIFont.systemFont(ofSize: 16)
           label.textAlignment = .center
         label.text = "Test address"
           return label
       }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 30)
       label.textColor = .white
       label.text = "X"
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        return view
    }()
    
    private let uberInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "UberX"
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
               button.setTitle("CONFIRM UBERX", for: .normal)
               button.setTitleColor(.white, for: .normal)
               button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
               button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
      
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
       infoView.layer.cornerRadius = 60 / 2
        
        addSubview(uberInfoLabel)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        uberInfoLabel.centerX(inView: self)
        
        let separatorView = UIView()
               separatorView.backgroundColor = .lightGray
               addSubview(separatorView)
               separatorView.anchor(top: uberInfoLabel.bottomAnchor, left: leftAnchor,
                                    right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
               actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                                   right: rightAnchor, paddingLeft: 12, paddingBottom: 12,
                                   paddingRight: 12, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func actionButtonPressed(){
        delegate?.uploadTrip(self)
    }
}
