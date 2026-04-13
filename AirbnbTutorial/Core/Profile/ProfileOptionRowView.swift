//  ProfileOptionRowView.swift
//  AirbnbTutorial

import SwiftUI

struct ProfileOptionRowView: View {
    let imageName: String
    let title: String
    var iconColor: Color = .gray

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: imageName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray3))
            }
            .padding(.vertical, 14)

            Divider()
                .padding(.leading, 50)
        }
    }
}

#Preview {
    VStack {
        ProfileOptionRowView(imageName: "suitcase.fill", title: "My Trips", iconColor: .blue)
        ProfileOptionRowView(imageName: "gear", title: "Settings", iconColor: .gray)
        ProfileOptionRowView(imageName: "accessibility", title: "Accessibility", iconColor: .blue)
    }
    .padding()
}
