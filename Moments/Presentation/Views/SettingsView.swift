import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(AppLanguage.allCases) { language in
                        Button {
                            if languageManager.currentLanguage != language {
                                languageManager.setLanguage(language)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Text(language.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if languageManager.currentLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(BrandColors.accent)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Text(String(localized: "settings.language", bundle: LanguageManager.shared.bundle))
                }
            }
            .navigationTitle(String(localized: "settings", bundle: LanguageManager.shared.bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "done", bundle: LanguageManager.shared.bundle)) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(BrandColors.accent)
                }
            }
        }
        .tint(BrandColors.accent)
    }
}
