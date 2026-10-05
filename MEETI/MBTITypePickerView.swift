import SwiftUI

// MBTIが分かっている人が16タイプから直接選ぶ部品です。
// 既存画面へはまだ接続していません。
struct MBTITypePickerView: View {
    @Binding var selectedMBTI: String

    var body: some View {
        Picker("MBTIタイプ", selection: $selectedMBTI) {
            ForEach(mbtiTypes, id: \.self) { type in
                Text(type)
                    .tag(type)
            }
        }
        .pickerStyle(.menu)
    }
}

#Preview {
    MBTITypePickerView(selectedMBTI: .constant("ENFJ"))
}
