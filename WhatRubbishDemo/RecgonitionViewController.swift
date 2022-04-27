//
//  RecgonitionViewController.swift
//  WhatRubbishDemo
//
//  Created by 闫润邦 on 2022/4/7.
//

import UIKit
import CoreML
import Vision
class RecgonitionViewController: UIViewController {
    let selectButton = UIButton()
    let takeButton = UIButton()
    let imagePickerController = UIImagePickerController()
    let imageView = UIImageView()
    let label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .darkGray
        imagePickerController.delegate = self
        configureButtons()
        configureLabel()
        configureImageView()
        configureConstaints()
    }
    
    func configureButtons() {
        selectButton.setImage(UIImage(systemName: "photo.artframe"), for: .normal)
        selectButton.setTitle("从图库选择", for: .normal)
        selectButton.addTarget(self, action: #selector(showSelectImage), for: .touchUpInside)
        
        takeButton.setImage(UIImage(systemName: "camera"), for: .normal)
        takeButton.setTitle("拍摄", for: .normal)
        takeButton.addTarget(self, action: #selector(showTakeImage), for: .touchUpInside)
        
        self.view.addSubview(selectButton)
        self.view.addSubview(takeButton)
    }
    
    func configureLabel() {
        self.view.addSubview(label)
        label.text = "book"
        label.textAlignment = .center
    }
    
    func configureImageView() {
        self.view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "book")
    }
    
    func configureConstaints() {
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        takeButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            // selectButton
            selectButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            selectButton.heightAnchor.constraint(equalToConstant: 75),
            selectButton.imageView!.widthAnchor.constraint(equalToConstant: 50),
            selectButton.imageView!.heightAnchor.constraint(equalToConstant: 50),
            selectButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: -25),
            // takeButton
            takeButton.topAnchor.constraint(equalTo: selectButton.topAnchor),
            takeButton.heightAnchor.constraint(equalToConstant: 75),
            takeButton.imageView!.widthAnchor.constraint(equalToConstant: 50),
            takeButton.imageView!.heightAnchor.constraint(equalToConstant: 50),
            takeButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 25),
            //imageView
            imageView.topAnchor.constraint(equalTo: selectButton.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            //textView
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 75),
        ]
        self.view.addConstraints(constraints)
    }
    
    @objc func showSelectImage() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    @objc func showTakeImage() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) == true else {
            let alert = UIAlertController(title: "相机不可用",
                                          message: "请到设置->隐私->相机中开启相机权限",
                                          preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            let settingsAction = UIAlertAction(title: "转到设置", style: .default, handler: { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                }
            })
            alert.addAction(settingsAction)
            
            present(alert, animated: true)
            return
        }
        
        imagePickerController.sourceType = .camera
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(imagePickerController, animated: true)
        
    }
    
    func didFinishSelecting(_ image: UIImage) {
        imageView.image = image
        dismiss(animated: true)
        guard let ciImage = CIImage(image: image) else {
            return
        }
        getPrediction(ciImage)
    }
    
    func getPrediction(_ image: CIImage) {
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model) else {
            return
        }
        let request = VNCoreMLRequest(model: model, completionHandler: handleResult)
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        }
        catch {
            fatalError("\(error)")
        }
    }
    
    func handleResult(request: VNRequest, error: Error?) {
        print("handling")
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("No result has been gotten")
        }
        
        guard let result = results.first else {
            fatalError("No result has been gotten")
        }
        
        print(result)
        label.text = "\(result.identifier), \(result.confidence)"
    }
}

extension RecgonitionViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        didFinishSelecting(image)
    }
}

extension RecgonitionViewController: UINavigationControllerDelegate {
    
}
