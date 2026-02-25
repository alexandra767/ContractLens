import SwiftUI

struct PDFPickerView: ViewModifier {
    @Binding var isPresented: Bool
    let onPick: (URL) -> Void

    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        onPick(url)
                    }
                case .failure:
                    break
                }
            }
    }
}

extension View {
    func pdfPicker(isPresented: Binding<Bool>, onPick: @escaping (URL) -> Void) -> some View {
        modifier(PDFPickerView(isPresented: isPresented, onPick: onPick))
    }
}
