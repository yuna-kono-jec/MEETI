import SwiftUI
import UIKit

// iPhoneのカメラをSwiftUIから開くための部品。
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var photoData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        // 表示後に更新する設定はない
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraPicker
        // キャンセル後に古いJPEG変換結果で写真を上書きしないよう、処理を追跡します。
        private var conversionTask: Task<Void, Never>?

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard let image = info[.originalImage] as? UIImage else {
                parent.dismiss()
                return
            }
            // 撮影直後のフルサイズJPEG変換をメインスレッドから分離します。
            // 元の0.8の圧縮率と写真サイズは維持し、保存データや表示仕様は変えません。
            conversionTask?.cancel()
            conversionTask = Task { @MainActor in
                let data = await Task.detached(priority: .userInitiated) {
                    image.jpegData(compressionQuality: 0.8)
                }.value
                // SwiftUIのBinding更新とカメラを閉じる操作だけをメインアクターで行います。
                guard !Task.isCancelled else { return }
                parent.photoData = data
                parent.dismiss()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 変換中にキャンセルした場合も、遅れて届く写真を入力画面へ反映しません。
            conversionTask?.cancel()
            parent.dismiss()
        }
    }
}
