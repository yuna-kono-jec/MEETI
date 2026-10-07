import SwiftUI

// 選択値のBindingを維持し、16タイプを見比べられる選択カードにします。
struct MBTITypePickerView: View {
    @Binding var selectedMBTI: String
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 12) {
            ForEach(mbtiTypes, id: \.self) { type in
                Button {
                    selectedMBTI = type
                } label: {
                    VStack(spacing: 8) {
                        Image(type).resizable().scaledToFit().frame(height: 70).accessibilityHidden(true)
                        HStack(spacing: 4) {
                            Text(type).font(.subheadline.weight(.semibold))
                            if selectedMBTI == type { Image(systemName: "checkmark.circle.fill") }
                        }
                    }
                    .padding(12).frame(maxWidth: .infinity)
                    .background(selectedMBTI == type ? MEETIStyle.blue : .white.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(MEETIStyle.green.opacity(selectedMBTI == type ? 1 : 0.15), lineWidth: 1))
                }.buttonStyle(.plain).foregroundStyle(MEETIStyle.ink)
                .accessibilityAddTraits(selectedMBTI == type ? .isSelected : [])
            }
        }
    }
}
#Preview { MBTITypePickerView(selectedMBTI: .constant("ENFJ")) }
