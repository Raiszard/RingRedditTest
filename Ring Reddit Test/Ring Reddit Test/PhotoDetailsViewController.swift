//
//  PhotoDetailsViewController.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/23/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    var imageURL: URL!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func saveTapped(_ sender: Any) {
        
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.zoomScale = 1.0

        imageView.image = UIImage(named: "placeholder")
        if imageURL != nil {
            imageView.downloadImageFrom(link: imageURL, contentMode: .scaleAspectFit)
        }
        
        saveButton.layer.cornerRadius = saveButton.frame.width/10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(imageURL, forKey: "imageURL")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        imageURL = coder.decodeObject(forKey: "imageURL") as! URL
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
        guard let image = imageURL else { return }
        imageView.downloadImageFrom(link: image, contentMode: .scaleAspectFit)
    }

}

extension PhotoDetailsViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}




