import SwiftUI
import UIKit
import PhotosUI // Import PhotosUI for PHPickerViewController

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage] // Array of selected images
    @Environment(\.presentationMode) var presentationMode // To dismiss the picker

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // 0 means unlimited selection
        configuration.filter = .images // Only allow images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for result in results {
                // Check if the result is an image
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(uiImage) // Append the selected image
                            }
                        }
                    }
                }
            }
            picker.dismiss(animated: true) {
                self.parent.presentationMode.wrappedValue.dismiss() // Dismiss the picker
            }
        }
    }
}
