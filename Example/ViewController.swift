//
//  ViewController.swift
//  Example
//
//  Created by 蒋惠 on 2020/6/24.
//

import UIKit
import PhotosUI
import CardsRecognizer

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Start")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showPicker()
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        recognize(image: image)
    }
}

// MARK: - Private
extension ViewController {
    
    private func showPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func recognize(image: UIImage) {
        print("Start recognize")
        Recognizer.recognizeIDCard(source: image) { (result) in
            switch result {
            case .success(let card):
                print(card)
            case .failure(let error):
                print(error)
            }
        }
    }
}
