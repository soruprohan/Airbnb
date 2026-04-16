//
//  ExploreSearchBarView.swift
//  AirbnbTutorial


import SwiftUI

struct ExploreSearchBarView: View {
    @Binding var location: String
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
            VStack(alignment: .leading, spacing: 2) {
                Text(location.isEmpty ? "Search stays" : location)
                    .font(.footnote)
                    .fontWeight(.semibold)
                Text("\(location.isEmpty ? "Any location - " :"")Any dates - Add travelers")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: { //empty action for now since the button will be handled by the parent view 
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundStyle(.black)
            })
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .overlay{
            Capsule()
                .stroke(lineWidth: 0.5)
                .foregroundStyle(Color(.systemGray4))
                .shadow(color: .black.opacity(0.1), radius:2)
        }
        .padding()
    }
}

#Preview {
    ExploreSearchBarView(location: .constant("Los Angeles")) //since the location variable is a binding,
                                                        //  we need to provide a constant value for the preview.
}
