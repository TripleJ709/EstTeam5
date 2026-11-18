import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "시스템"
        case .light: "라이트"
        case .dark: "다크"
        }
    }
}

struct DisplaySettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("appTheme") private var savedTheme = AppTheme.system.rawValue
    @AppStorage("useSystemFontSize") private var savedUseSystemFontSize = true
    @AppStorage("fontScale") private var savedFontScale = 1.0

    @State private var theme = AppTheme.system
    @State private var useSystemFontSize = true
    @State private var fontScale = 1.0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    themeSection
                    fontSizeSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 42)
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("화면 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .accessibilityLabel("닫기")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                            .accessibilityLabel("완료")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FeeloColor.tint)
                }
            }
        }
        .tint(FeeloColor.tint)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(40)
        .presentationBackground(FeeloColor.bgApp)
        .onAppear(perform: load)
    }

    private var themeSection: some View {
        VStack(spacing: 0) {
            sectionHeader("테마")

            Picker("테마", selection: $theme) {
                ForEach(AppTheme.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .controlSize(.large)
            .frame(height: 50)
            .padding(8)
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.calendar))

            sectionFooter("시스템을 고르면 기기 설정에 맞춰 라이트/다크 모드가 자동으로 바뀌어요.")
        }
    }

    private var fontSizeSection: some View {
        VStack(spacing: 0) {
            sectionHeader("글꼴 크기")

            VStack(spacing: 0) {
                Toggle("시스템 글꼴 크기 사용", isOn: $useSystemFontSize)
                    .font(.body)
                    .foregroundStyle(FeeloColor.textPrimary)
                    .padding(.horizontal, 16)
                    .frame(height: 52)

                HStack(spacing: 8) {
                    Text("가")
                        .font(.footnote)
                    Slider(value: $fontScale, in: 0.8...1.4)
                        .tint(.blue)
                        .disabled(useSystemFontSize)
                    Text("가")
                        .font(.title2.bold())
                }
                .foregroundStyle(FeeloColor.textPrimary)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.calendar))

            sectionFooter("앱 안에서만 글꼴 크기가 바뀌어요. 시스템 설정은 그대로예요.")
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(FeeloColor.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 42)
            .padding(.horizontal, 16)
    }

    private func sectionFooter(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .lineSpacing(2.5)
            .foregroundStyle(FeeloColor.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
            .padding(.horizontal, 16)
    }

    private func load() {
        theme = AppTheme(rawValue: savedTheme) ?? .system
        useSystemFontSize = savedUseSystemFontSize
        fontScale = savedFontScale
    }

    private func save() {
        savedTheme = theme.rawValue
        savedUseSystemFontSize = useSystemFontSize
        savedFontScale = fontScale
        dismiss()
    }
}

#Preview {
    Text("회고")
        .sheet(isPresented: .constant(true)) {
            DisplaySettingsView()
        }
}
