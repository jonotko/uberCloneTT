//
//  SignUpController.swift
//  UberCloneTT
//
//  Created by Jonathan Agarrat on 2/5/20.
//  Copyright © 2020 Jonathan Agarrat. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class SignUpController: UIViewController {
    
    private let location = LocationHandler.shared.locationManager.location
    
    //MARK: - Properties
       private let titleLabel: UILabel = {
           let label = UILabel()
           label.text = "UBER"
           label.font = UIFont(name: "Avenir-Light", size: 36)
           label.textColor = UIColor(white: 1, alpha: 0.8)
           return label
       }()
    
    private lazy var emailContainerView: UIView = {
          let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
          view.heightAnchor.constraint(equalToConstant: 50).isActive = true
          return view
      }()
    
    private lazy var fullNameContainerView: UIView = {
             let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullNameTextField)
             view.heightAnchor.constraint(equalToConstant: 50).isActive = true
             return view
         }()
      
      private lazy var passwordContainerView: UIView = {
          let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
          view.heightAnchor.constraint(equalToConstant: 50).isActive = true
          
          return view
      }()
    
    
    private lazy var accountTypeContainerView: UIView = {
             let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmetedControl: accountTypeSegmentedControl)
             view.heightAnchor.constraint(equalToConstant: 80).isActive = true
             
             return view
         }()
         
      
      private let emailTextField: UITextField = {
          
          return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
          
      }()
    
    private let fullNameTextField: UITextField = {
             
             return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
             
         }()
      
      private let passwordTextField: UITextField = {
          
          return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
          
      }()
    
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        
        let sc = UISegmentedControl(items: ["Rider","Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
             
        return sc
             
    }()
    
    
    private let signUpButton: UIButton = {
           let button = AuthButton(type: .system)
           button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
           return button
       }()
       
    private let alreadyHaveAccountButton: UIButton = {
           let button = UIButton(type: .system)
           
           let attributedTitle = NSMutableAttributedString(string: "Already have an Account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                                                                           NSAttributedString.Key.foregroundColor: UIColor.lightGray])
           
           attributedTitle.append(NSAttributedString(string: "Log in", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                                                     NSAttributedString.Key.foregroundColor: UIColor.mainBlue
           ]))
           
           button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
           
           button.setAttributedTitle(attributedTitle, for: .normal)
           
           return button
       }()
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    
        print("DEBUG Location is \(location)")
    }
    
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullNameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Failed to register user with error \(error)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = [
                           "email": email,
                           "fullname": fullname,
                           "accountType": accountTypeIndex
                       ] as [String : Any]
            
            if accountTypeIndex == 1 {
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                
                guard let location = self.location else { return }
               geofire.setLocation(location, forKey: uid) { (error) in
                self.uploadUserDataAndShowHomeController(uid: uid, values: values)
               }
                
            }
            
            self.uploadUserDataAndShowHomeController(uid: uid, values: values)
            
           
        }
    }
    
    // MARK: - Helper Functions
    
    func uploadUserDataAndShowHomeController(uid: String, values: [String: Any]) {
        
        REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
                       print("Successfully registered user and saved data...")
            controller.configure();
                       self.dismiss(animated: true, completion: nil)
                   }
    }
    
    func configureUI(){
           
           view.backgroundColor = .backgroundColor
           
           view.addSubview(titleLabel)
           titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
           titleLabel.centerX(inView: view)
           
           let stackView = UIStackView(arrangedSubviews: [emailContainerView, fullNameContainerView, passwordContainerView, accountTypeContainerView, signUpButton])
           stackView.axis = .vertical
           stackView.distribution = .fillProportionally
           stackView.spacing = 24
           
           view.addSubview(stackView)
           
           stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
           
            view.addSubview(alreadyHaveAccountButton)
               
            alreadyHaveAccountButton.centerX(inView: view)
               
            alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
           
       }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
       
    

}
