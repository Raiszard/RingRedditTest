//
//  PhotoDetailsViewController.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/23/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    var imageStr: String!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func saveTapped(_ sender: Any) {
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0//maximum zoom scale you want
        scrollView.zoomScale = 1.0

        imageView.image = UIImage(named: "placeholder")
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension PhotoDetailsViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}




