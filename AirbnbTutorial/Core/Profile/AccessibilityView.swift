//  AccessibilityView.swift
//  AirbnbTutorial

import SwiftUI

struct AccessibilityView: View {

    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("textSizeIndex") private var textSizeIndex = 2

    let textSizes: [DynamicTypeSize] = [.small, .medium, .large, .xLarge, .xxLarge] //DynamicTypeSize is a SwiftUI enum that represents the different text size categories 
    let textSizeLabels = ["S", "M", "L", "XL", "XXL"]

    var body: some View {
        List {

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Text size")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Preview text")
                        .dynamicTypeSize(textSizes[textSizeIndex])
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    HStack {
                        Text("A").font(.caption).foregroundStyle(.secondary)
                        Slider(
                            value: Binding(
                                get: { Double(textSizeIndex) },
                                set: { textSizeIndex = Int($0.rounded()) }
                            ),
                            in: 0...Double(textSizes.count - 1),
                            step: 1
                        )
                        .tint(.pink)
                        Text("A").font(.title3).foregroundStyle(.secondary)
                    }

                    HStack {
                        ForEach(textSizeLabels, id: \.self) { label in
                            Text(label).font(.caption2).frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Text")
            }

            Section("Feedback") {
                Toggle("Haptic feedback", isOn: $hapticFeedbackEnabled)
            }

            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.pink)
                        .padding(.top, 1)
                    Text("Options like High Contrast, Bold Text, and Reduce Motion are available in your iPhone's **Settings → Accessibility**.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { AccessibilityView() }
}
