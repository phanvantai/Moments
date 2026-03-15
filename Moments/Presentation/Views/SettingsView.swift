import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showThemePicker = false
    @State private var showLanguagePicker = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showThemePicker = true
                    } label: {
                        settingsRow(
                            title: String(localized: "settings.theme", bundle: LanguageManager.shared.bundle),
                            value: themeManager.currentTheme.displayName
                        ) {
                            Image(systemName: themeManager.currentTheme.iconName)
                                .font(.body)
                                .foregroundStyle(BrandColors.accent)
                        }
                    }

                    Button {
                        showLanguagePicker = true
                    } label: {
                        settingsRow(
                            title: String(localized: "settings.language", bundle: LanguageManager.shared.bundle),
                            value: languageManager.currentLanguage.displayName
                        ) {
                            Text(languageManager.currentLanguage.flag)
                                .font(.title3)
                        }
                    }
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
            .sheet(isPresented: $showThemePicker) {
                pickerSheet(
                    title: String(localized: "settings.theme", bundle: LanguageManager.shared.bundle),
                    items: AppTheme.allCases,
                    selected: themeManager.currentTheme,
                    label: \.displayName,
                    icon: { theme in
                        Image(systemName: theme.iconName)
                            .font(.body)
                            .foregroundStyle(BrandColors.accent)
                    }
                ) { theme in
                    themeManager.setTheme(theme)
                    showThemePicker = false
                    dismiss()
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                pickerSheet(
                    title: String(localized: "settings.language", bundle: LanguageManager.shared.bundle),
                    items: AppLanguage.allCases,
                    selected: languageManager.currentLanguage,
                    label: \.displayName,
                    icon: { language in
                        Text(language.flag)
                            .font(.title3)
                    }
                ) { language in
                    languageManager.setLanguage(language)
                    showLanguagePicker = false
                    dismiss()
                }
            }
        }
        .tint(BrandColors.accent)
    }

    // MARK: - Settings Row

    private func settingsRow<Icon: View>(
        title: String,
        value: String,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        HStack(spacing: 12) {
            icon()
                .frame(width: 28, height: 28)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(BrandColors.textSecondary)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BrandColors.textSecondary)
        }
    }

    // MARK: - Picker Sheet

    private func pickerSheet<Item: Identifiable & Equatable, Icon: View>(
        title: String,
        items: [Item],
        selected: Item,
        label: KeyPath<Item, String>,
        @ViewBuilder icon: @escaping (Item) -> Icon,
        onSelect: @escaping (Item) -> Void
    ) -> some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Button {
                        if item != selected {
                            onSelect(item)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            icon(item)
                                .frame(width: 28, height: 28)
                            Text(item[keyPath: label])
                                .foregroundStyle(.primary)
                            Spacer()
                            if item == selected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(BrandColors.accent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
