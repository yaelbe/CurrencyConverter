import SwiftUI

struct BorderedViewWithTitle<Content: View>: View {
    let title: String
    let buttonText: String
    let content: Content
    let buttonAction: () -> Void
    
    init(title: String,
         buttonText:String,
         buttonAction: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        self.content = content()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer() // Pushes the button to the right
                
                Button(buttonText,action: buttonAction)
                    .foregroundColor(.red)
            }
            .padding(.horizontal)
            .background(Color.white) // Match the background color of your parent view
            .frame(maxWidth: .infinity, alignment: .leading)
            
            content
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding([.horizontal, .top])
    }
}
