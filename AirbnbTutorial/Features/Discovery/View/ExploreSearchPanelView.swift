//  ExploreSearchPanelView.swift
//  AirbnbTutorial

import SwiftUI

enum SearchPanelOption {
    case location
    case dates
    case guests
}

struct ExploreSearchPanelView: View {
    @Binding var show: Bool
    @ObservedObject var viewModel: ExploreViewModel
    @State private var selectedOption: SearchPanelOption = .location

    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation(.snappy) {
                        viewModel.updateListingsForLocation()
                        show.toggle()
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                        .imageScale(.large)
                        .foregroundStyle(.black)
                }

                Spacer()

                if !viewModel.searchLocation.isEmpty {
                    Button("Clear") {
                        viewModel.searchLocation = ""
                        viewModel.updateListingsForLocation()
                    }
                    .foregroundStyle(.black)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                }
            }
            .padding()

            // MARK: - Location
            VStack(alignment: .leading) {
                if selectedOption == .location {
                    Text("Search stays")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.small)

                        TextField("Enter a location", text: $viewModel.searchLocation)
                            .font(.subheadline)
                            .onSubmit {
                                viewModel.updateListingsForLocation()
                                show.toggle()
                            }
                    }
                    .frame(height: 44)
                    .padding(.horizontal)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.0)
                            .foregroundStyle(Color(.systemGray4))
                    }
                } else {
                    CollapsedOptionView(title: "Location", description: "Set location")
                }
            }
            .modifier(CollapsiblePanelViewModifier())
            .frame(height: selectedOption == .location ? 120 : 64)
            .onTapGesture {
                withAnimation(.snappy) { selectedOption = .location }
            }

            // MARK: - Dates (now bound to viewModel)
            VStack(alignment: .leading) {
                if selectedOption == .dates {
                    Text("Select your dates")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack {
                        DatePicker("From", selection: $viewModel.startDate, displayedComponents: .date)
                        Divider()
                        DatePicker("To", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
                    }
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                } else {
                    CollapsedOptionView(
                        title: "Dates",
                        description: viewModel.formattedDateRange ?? "Pick dates"
                    )
                }
            }
            .modifier(CollapsiblePanelViewModifier())
            .frame(height: selectedOption == .dates ? 180 : 64)
            .onTapGesture {
                withAnimation(.snappy) { selectedOption = .dates }
            }

            // MARK: - Guests (now bound to viewModel)
            VStack(alignment: .leading) {
                if selectedOption == .guests {
                    Text("How many travelers?")
                        .font(.title)
                        .fontWeight(.semibold)

                    Stepper {
                        Text("\(viewModel.numGuests) Adults")
                    } onIncrement: {
                        viewModel.numGuests += 1
                    } onDecrement: {
                        guard viewModel.numGuests > 1 else { return }
                        viewModel.numGuests -= 1
                    }

                } else {
                    CollapsedOptionView(
                        title: "Travelers",
                        description: viewModel.numGuests > 1 ? "\(viewModel.numGuests) travelers" : "Add travelers"
                    )
                }
            }
            .modifier(CollapsiblePanelViewModifier())
            .frame(height: selectedOption == .guests ? 120 : 64)
            .onTapGesture {
                withAnimation(.snappy) { selectedOption = .guests }
            }

            Spacer()
        }
    }
}

#Preview {
    ExploreSearchPanelView(show: .constant(false), viewModel: ExploreViewModel(service: ExploreService()))
}

struct CollapsiblePanelViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .shadow(radius: 10)
    }
}

struct CollapsedOptionView: View {
    let title: String
    let description: String

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundStyle(.gray)
                Spacer()
                Text(description)
            }
            .fontWeight(.semibold)
            .font(.subheadline)
        }
    }
}
