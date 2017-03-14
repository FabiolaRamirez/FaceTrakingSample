//
//  MainViewController.swift
//  FaceTrackingSample
//
//  Created by Fabiola Ramirez on 3/12/17.
//  Copyright © 2017 Fabiola Ramirez. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func getStart(_ sender: UIButton) {
        
        let viewController : UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "rootTabBarController"))!
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
