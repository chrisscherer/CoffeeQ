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
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var BuyContainer: UIView!
    @IBOutlet weak var RedeemContainer: UIView!
    @IBOutlet weak var BuyEmailTextField: UITextField!
    @IBOutlet weak var BuyNoteTextView: UITextView!
    @IBOutlet weak var RedeemEmailTextField: UITextField!
    @IBOutlet weak var RedeemNoteTextView: UITextView!
    @IBOutlet weak var BuyCancelButton: UIButton!
    @IBOutlet weak var BuyConfirmButton: UIButton!
    @IBOutlet weak var RedeemCancelButton: UIButton!
    @IBOutlet weak var RedeemConfirmButton: UIButton!
    
    @IBOutlet weak var DonateSmallCoffeeButton: UIButton!
    @IBOutlet weak var DonateMediumCoffeeButton: UIButton!
    @IBOutlet weak var DonateLargeCoffeeButton: UIButton!
    
    @IBOutlet weak var RedeemSmallCoffeeButton: UIButton!
    @IBOutlet weak var RedeemMediumCoffeeButton: UIButton!
    @IBOutlet weak var RedeemLargeCoffeeButton: UIButton!
    
    @IBOutlet weak var SegmentControl: UISegmentedControl!
    
    private let AFService = AlamoFireService()
    
    var pageState = Constants.pageState.home
    
    var sizeState = Constants.sizeSelectionState.medium
    
    var currentRedemption: RedemptionResponse?
    
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
        
        
        let font = UIFont.systemFont(ofSize: 24)
        
        SegmentControl.setTitleTextAttributes([NSFontAttributeName: font],
                                              for: .normal)
        
        self.RedeemContainer.layer.cornerRadius = 9
        self.BuyContainer.layer.cornerRadius = 9
        self.RedeemCancelButton.layer.cornerRadius = 28
        self.RedeemConfirmButton.layer.cornerRadius = 28
        self.BuyCancelButton.layer.cornerRadius = 28
        self.BuyConfirmButton.layer.cornerRadius = 28
        self.BuyEmailTextField.layer.cornerRadius = 4
        self.BuyNoteTextView.layer.cornerRadius = 4
        self.RedeemNoteTextView.layer.cornerRadius = 4
        self.RedeemEmailTextField.layer.cornerRadius = 4
        
        self.DonateSmallCoffeeButton.layer.cornerRadius = 9
        self.DonateMediumCoffeeButton.layer.cornerRadius = 9
        self.DonateLargeCoffeeButton.layer.cornerRadius = 9
        
        self.DonateSmallCoffeeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.DonateMediumCoffeeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.DonateLargeCoffeeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        self.RedeemSmallCoffeeButton.layer.cornerRadius = 9
        self.RedeemMediumCoffeeButton.layer.cornerRadius = 9
        self.RedeemLargeCoffeeButton.layer.cornerRadius = 9
        
        self.RedeemSmallCoffeeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.RedeemMediumCoffeeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.RedeemLargeCoffeeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        self.SegmentControl.layer.cornerRadius = 500
    }
    
    @IBAction func showComponent(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.RedeemContainer.alpha = 0
                    self.BuyContainer.alpha = 1
                })
            }
        } else {
            initiateRedemption()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.RedeemContainer.alpha = 1
                    self.BuyContainer.alpha = 0
                })
            }
        }
    }
    
    @IBAction func donateSmallCoffeePressed(_ sender: UIButton) {
        sizeState = Constants.sizeSelectionState.small
        self.DonateSmallCoffeeButton.backgroundColor = Constants.coffeeQGreen
        self.DonateMediumCoffeeButton.backgroundColor = UIColor.clear
        self.DonateLargeCoffeeButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func donateMediumCoffeePressed(_ sender: UIButton) {
        sizeState = Constants.sizeSelectionState.medium
        self.DonateSmallCoffeeButton.backgroundColor = UIColor.clear
        self.DonateMediumCoffeeButton.backgroundColor = Constants.coffeeQGreen
        self.DonateLargeCoffeeButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func donateLargeCoffeePressed(_ sender: UIButton) {
        sizeState = Constants.sizeSelectionState.large
        self.DonateSmallCoffeeButton.backgroundColor = UIColor.clear
        self.DonateMediumCoffeeButton.backgroundColor = UIColor.clear
        self.DonateLargeCoffeeButton.backgroundColor = Constants.coffeeQGreen
    }
    
    @IBAction func redeemSmallCoffeePressed(_ sender: UIButton) {
        sizeState = Constants.sizeSelectionState.small
        self.RedeemSmallCoffeeButton.backgroundColor = Constants.coffeeQGreen
        self.RedeemMediumCoffeeButton.backgroundColor = UIColor.clear
        self.RedeemLargeCoffeeButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func redeemMediumCoffeePressed(_ sender: UIButton) {
        sizeState = Constants.sizeSelectionState.medium
        self.RedeemSmallCoffeeButton.backgroundColor = UIColor.clear
        self.RedeemMediumCoffeeButton.backgroundColor = Constants.coffeeQGreen
        self.RedeemLargeCoffeeButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func redeemLargeCoffeePressed(_ sender: UIButton) {
        sizeState = Constants.sizeSelectionState.large
        self.RedeemSmallCoffeeButton.backgroundColor = UIColor.clear
        self.RedeemMediumCoffeeButton.backgroundColor = UIColor.clear
        self.RedeemLargeCoffeeButton.backgroundColor = Constants.coffeeQGreen
    }
    
    func transitionToPurchase(){
        pageState = Constants.pageState.buy
    }
    
    @IBAction func confirmPurchase(){
        let purchaseRequest = CompletePurchaseRequest()
        
        purchaseRequest.customerEmail = BuyEmailTextField.text != "" ? BuyEmailTextField.text! : "default@na.com"
        purchaseRequest.customerName = "N/A"
        purchaseRequest.itemName = "Small Coffee"
        purchaseRequest.itemPrice = 15.50
        purchaseRequest.message = BuyNoteTextView.text != "" ? BuyNoteTextView.text! : "No note"
        
        let uri = Constants.DEV_URL + "purchases"
        
        AFService.makeRequest(uri, HTTPMethod.post, purchaseRequest.toJSON(), Constants.getHeaders()) {
            (response: [CompletePurchaseResponse]) in
            
            if(response.count > 0) {
                if(response[0].status == "C") {
                    self.displayRedemptionCompleteModal("")
                }
            }
            
        }
        
        pageState = Constants.pageState.home
    }
    
    func cancelPurchase(){
        pageState = Constants.pageState.home
    }
    
    func initiateRedemption() {
        let uri = Constants.DEV_URL + "redemptions"
        
        AFService.makeRequest(uri, HTTPMethod.post, [:], Constants.getHeaders()) {
            (response: [RedemptionResponse]) in
            
            if(response.count > 0) {
                self.currentRedemption = response[0]
            }
        }
    }
    
    @IBAction func confirmRedeem(){
        if(currentRedemption == nil) {
            return
        }
        
        let completeRedemptionRequest = CompleteRedemptionRequest()
        
        completeRedemptionRequest.itemName = "Small Coffee"
        completeRedemptionRequest.message = RedeemNoteTextView.text != "" ? RedeemNoteTextView.text! : "No Note"
        completeRedemptionRequest.redeemerName = RedeemEmailTextField.text != "" ? RedeemEmailTextField.text! : "N/A"
        completeRedemptionRequest.itemPrice = 2.50
        
        let uri = Constants.DEV_URL + "redemptions/" + (currentRedemption?.redemptionId)!
        
        AFService.makeRequest(uri, HTTPMethod.put, completeRedemptionRequest.toJSON(), Constants.getHeaders()) {
            (response: [RedemptionFinalizedResponse]) in
            if(response.count > 0) {
                self.displayRedemptionCompleteModal("")
            }
        }
    }
    
    func cancelRedeem(){
        currentRedemption = nil
    }
    
    func displayRedemptionCompleteModal(_ message: String?) {
        let defaultMessage = (message != "") ? message : "Thanks for being a part of the CoffeeQ movement!"
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Success!", message: defaultMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true)
        }
    }
}

