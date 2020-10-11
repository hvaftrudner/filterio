//
//  ViewController.swift
//  project 13
//
//  Created by Kristoffer Eriksson on 2020-10-10.
//
import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var filterButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Filterio"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        
    }
    
    @objc func importPicture(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIBoxBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction){
        
        guard currentImage != nil else {return}
        guard let actionTitle = action.title else {return}
        
        currentFilter = CIFilter(name: actionTitle)
        
        filterButton.setTitle(actionTitle, for: .normal)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
        
        
    }
    
    @IBAction func save(_ sender: Any) {
        //guard let image = imageView.image else {return}
        //changed to show errormessage if no picture is choosen
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let ac = UIAlertController(title: "Error", message: "No picture choosen", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: Any) {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputRadiusKey){
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey){
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y:currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        applyProcessing()
    }
    
    
    func applyProcessing(){
//        let inputKeys = currentFilter.inputKeys
        
//        if inputKeys.contains(kCIInputIntensityKey){
//            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
//        }
//        if inputKeys.contains(kCIInputScaleKey){
//            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
//        }
//        if inputKeys.contains(kCIInputRadiusKey){
//            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
//        }
//        if inputKeys.contains(kCIInputCenterKey){
//            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
//        }
        
        guard let outputImage = currentFilter.outputImage else {return}
        
        //This line breaks if the filter uses any other input then IntensityKey
        //currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){

            let processImage = UIImage(cgImage: cgImage)
            imageView.image = processImage
        }
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer ){
        if let error = error {
            let ac = UIAlertController(title: "save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
        } else {
            let ac = UIAlertController(title: "Saved! ", message: "Altered image has been saved to photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
    }
    
}

