

//  HelpCenterView.swift

import SwiftUI

struct HelpCenterView: View {
    
    @State private var searchText = ""
    
    let faqs: [FAQItem] = [
        FAQItem(
            question: "How do I book a listing?",
            answer: "Tap any listing on the Explore tab, review the details, then tap 'Reserve'. You'll be guided through the checkout flow. Make sure you're logged in before booking."
        ),
        FAQItem(
            question: "How do I cancel a reservation?",
            answer: "Go to your Trips (coming soon), find the reservation you want to cancel, and tap 'Cancel reservation'. Refund eligibility depends on the host's cancellation policy shown on the listing."
        ),
        FAQItem(
            question: "How does pricing work?",
            answer: "The nightly rate is set by the host. The total price includes the nightly rate multiplied by the number of nights, plus any cleaning fee and service fee shown at checkout."
        ),
        FAQItem(
            question: "How do I add a listing to my wishlist?",
            answer: "Tap the heart icon on any listing card or detail page. You must be logged in to save wishlists — your saved items sync across devices."
        ),
        FAQItem(
            question: "Is my personal information secure?",
            answer: "Yes. Authentication is handled by Firebase Auth, and your profile data is stored securely in Firestore. We never share your data with third parties."
        ),
        FAQItem(
            question: "How do I contact a host?",
            answer: "Messaging functionality is coming in a future update. For now, host contact details are visible on the listing detail page after you make a reservation."
        ),
        FAQItem(
            question: "What payment methods are accepted?",
            answer: "Payment integration is coming soon. The app currently supports browsing and wishlisting. Full booking with payment will be available in a future release."
        ),
    ]
    
    var filteredFAQs: [FAQItem] {
        if searchText.isEmpty { return faqs }
        return faqs.filter {
            $0.question.localizedCaseInsensitiveContains(searchText) || //$0 means one FAQ item at a time, it is a closure
            $0.answer.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            
            // MARK: - Search bar
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search help articles", text: $searchText)
                        .autocorrectionDisabled()
                }
            }
            
            // MARK: - FAQs
            Section("Frequently asked questions") {
                if filteredFAQs.isEmpty {
                    Text("No results for \"\(searchText)\"")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(filteredFAQs) { faq in
                        DisclosureGroup {       //SwiftUI's built in expand/ collapse component
                            Text(faq.answer)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 8)
                        } label: {
                            Text(faq.question)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            // MARK: - Contact
            Section("Still need help?") {
                Link(destination: URL(string: "mailto:support@example.com")!) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundStyle(.blue)
                            .frame(width: 28)
                        Text("Email support")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://www.airbnb.com/help")!) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundStyle(.blue)
                            .frame(width: 28)
                        Text("Visit Airbnb Help Center")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // MARK: - App version
            Section {
                HStack {
                    Text("App version")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Model
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

#Preview {
    NavigationStack {
        HelpCenterView()
    }
}
