//
//  ViewController.swift
//  CoffeeQ
//
//  Created by Christopher Scherer on 4/22/17.
//  Copyright @ 2017 CoffeeQ. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var redeemButton: UIButton!
    
    @IBOutlet weak var buttonStack: UIStackView!
    
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var noteInput: UITextView!
    @IBOutlet weak var thankYouMessage: UILabel!
    @IBOutlet weak var coffeeCountMessage: UILabel!
    
    @IBOutlet weak var firstTimeCoffeeImage: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    
    var pageState = Constants.pageState.home

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pageState = Constants.pageState.home
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupUI(){
        DispatchQueue.main.async {
            self.buyButton.layer.cornerRadius = 9
            self.redeemButton.layer.cornerRadius = 9
            self.noteInput.layer.cornerRadius = 9
        }
    }
    
    func transitionToPurchase(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.logo.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                self.buttonStack.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                self.userInput.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                self.noteInput.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                
                self.userInput.placeholder = "Please enter your email!"
                self.userInput.alpha = 1.0
                self.noteInput.alpha = 1.0
                
                self.redeemToCancelButton()
            })
        }
        
        pageState = Constants.pageState.buy
    }
    
    func confirmPurchase(){
        let parameters: Parameters = [
            "email": "chrisscherer90@gmail.com",
            "firstname": "Chris",
            "lastname": "Scherer",
            "cafe_id": 1,
            "message": "Test Message",
            "quantity": 1
        ]
        
        Alamofire.request("localhost:3000/v1/buy", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            
            switch response.result {
            case .success:
                print(response.result.value)
                break
            case .failure:
                break
            }
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, animations: {
                self.logo.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.buttonStack.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.userInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.noteInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                
                self.thankYouMessage.text = "Thanks for paying it forward!"
                self.coffeeCountMessage.text = "This was your first coffee payed forward!"
                
                self.userInput.alpha = 0.0
                self.noteInput.alpha = 0.0
                self.logo.alpha = 0.0
                self.buttonStack.alpha = 0.0
                
                self.thankYouMessage.alpha = 1.0
                self.coffeeCountMessage.alpha = 1.0
                self.firstTimeCoffeeImage.alpha = 1.0
                

                self.revertRedeemButton()
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.5, delay: 2.0, animations: {
                    self.userInput.alpha = 0.0
                    self.noteInput.alpha = 0.0
                    self.logo.alpha = 1.0
                    self.buttonStack.alpha = 1.0
                    
                    self.thankYouMessage.alpha = 0.0
                    self.coffeeCountMessage.alpha = 0.0
                    self.firstTimeCoffeeImage.alpha = 0.0
                    
                    self.revertRedeemButton()
                })
            })
        }
        
        pageState = Constants.pageState.home
    }
    
    func cancelPurchase(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.logo.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.buttonStack.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.userInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.noteInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                
                self.userInput.alpha = 0.0
                self.noteInput.alpha = 0.0

                
                self.revertRedeemButton()
            })
        }
        
        pageState = Constants.pageState.home
    }
    
    func transitionToRedeem(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.logo.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                self.buttonStack.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                self.userInput.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                self.noteInput.transform = CGAffineTransform.init(translationX: 0.0, y: -self.view.bounds.height / 4)
                
                self.userInput.placeholder = "Please enter your name!"
                self.userInput.alpha = 1.0
                self.noteInput.alpha = 1.0

                self.buyToCancelButton()
            })
        }
        
        pageState = Constants.pageState.redeem
    }
    
    func confirmRedeem(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.logo.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.buttonStack.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.userInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.noteInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                
                self.thankYouMessage.text = "Thanks for using CoffeeQ!"
                self.coffeeCountMessage.text = "\"I hope you enjoy your coffee! - Chris\""
                
                self.userInput.alpha = 0.0
                self.noteInput.alpha = 0.0
                self.logo.alpha = 0.0
                self.buttonStack.alpha = 0.0
                
                self.thankYouMessage.alpha = 1.0
                self.coffeeCountMessage.alpha = 1.0

                self.revertBuyButton()
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.5, delay: 2.0, animations: {
                    self.userInput.alpha = 0.0
                    self.noteInput.alpha = 0.0
                    self.logo.alpha = 1.0
                    self.buttonStack.alpha = 1.0
                    
                    self.thankYouMessage.alpha = 0.0
                    self.coffeeCountMessage.alpha = 0.0
                    
                    self.revertRedeemButton()
                })
            })
        }
        
        pageState = Constants.pageState.home
    }
    
    func cancelRedeem(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.logo.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.buttonStack.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.userInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                self.noteInput.transform = CGAffineTransform.init(translationX: 0.0, y: 0)
                
                self.userInput.alpha = 0.0
                self.noteInput.alpha = 0.0

                self.revertBuyButton()
            })
        }
        
        pageState = Constants.pageState.home
    }
    
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        switch pageState{
            //submit coffee to api
        case Constants.pageState.buy: confirmPurchase(); break
            //transition to enter email
        case Constants.pageState.home: transitionToPurchase(); break
            //cancel back to home page
        case Constants.pageState.redeem: cancelRedeem(); break
            
        case Constants.pageState.confirmation: break
        }
    }
    
    @IBAction func redeemButtonPressed(_ sender: UIButton) {
        switch pageState{
            //cancel back to home page
        case Constants.pageState.buy: cancelPurchase(); break
            //Go to redeem page
        case Constants.pageState.home: transitionToRedeem(); break
            //confirm redemption of coffee
        case Constants.pageState.redeem: confirmRedeem(); break
            
        case Constants.pageState.confirmation: break
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.logo.transform = CGAffineTransform.init(translationX: 0.0, y: 0.0)
            self.buttonStack.transform = CGAffineTransform.init(translationX: 0.0, y: 0.0)
        })
    }
    
    func buyToCancelButton(){
        self.buyButton.setTitle("Cancel", for: .normal)
        self.buyButton.backgroundColor = Constants.cancelRed
        self.buyButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func revertBuyButton(){
        self.buyButton.setTitle("Buy", for: .normal)
        self.buyButton.backgroundColor = Constants.darkBlue
        self.buyButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func redeemToCancelButton(){
        self.redeemButton.setTitle("Cancel", for: .normal)
        self.redeemButton.backgroundColor = Constants.cancelRed
        self.redeemButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func revertRedeemButton(){
        self.redeemButton.setTitle("Redeem", for: .normal)
        self.redeemButton.backgroundColor = UIColor.white
        self.redeemButton.setTitleColor(Constants.darkBlue, for: .normal)
    }
}

