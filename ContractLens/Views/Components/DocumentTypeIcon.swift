import SwiftUI

struct DocumentTypeIcon: View {
    let documentType: DocumentType
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size * 0.45))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(iconColor)
            .clipShape(Circle())
            .accessibilityLabel("\(documentType.rawValue) document type")
            .accessibilityHidden(false)
    }

    private var iconName: String {
        switch documentType {
        case .lease: return "building.2"
        case .employment: return "person.text.rectangle"
        case .nda: return "lock.shield"
        case .freelance: return "laptopcomputer"
        case .service: return "wrench.and.screwdriver"
        case .other: return "doc.text"
        }
    }

    private var iconColor: Color {
        switch documentType {
        case .lease: return .clSky
        case .employment: return .clNavy
        case .nda: return .clRiskMedium
        case .freelance: return .clRiskLow
        case .service: return .clSlate
        case .other: return .clSlate.opacity(0.7)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(DocumentType.allCases) { type in
            DocumentTypeIcon(documentType: type)
        }
    }
    .padding()
}
