import SwiftUI
import VisionKit
import UIKit

struct CameraScannerView: UIViewControllerRepresentable {
    let onScanComplete: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onScanComplete: onScanComplete)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onScanComplete: ([UIImage]) -> Void

        init(onScanComplete: @escaping ([UIImage]) -> Void) {
            self.onScanComplete = onScanComplete
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            onScanComplete(images)
            MainActor.assumeIsolated {
                controller.dismiss(animated: true)
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            MainActor.assumeIsolated {
                controller.dismiss(animated: true)
            }
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            MainActor.assumeIsolated {
                controller.dismiss(animated: true)
            }
        }
    }
}
