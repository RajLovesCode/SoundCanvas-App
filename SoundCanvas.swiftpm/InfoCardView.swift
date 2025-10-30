import SwiftUI

struct InfoCardView: View {
   var body: some View {
       VStack(alignment: .leading, spacing: 20) {
    
           Text("How to Start Creating Your Masterpieces with SoundCanvas")
               .font(.system(size: 22, weight: .bold))
               .foregroundColor(.primary)
               .fixedSize(horizontal: false, vertical: true)
           
           
           ScrollView {
               VStack(alignment: .leading, spacing: 16) {
                   InstructionItem(
                       number: "1",
                       title: "Start Simple",
                       description: "Begin with basic shapes, lines, or patterns. The simpler your drawing, the easier it will be to hear how the shapes turn into melodies. You can use different brush sizes and colors to make your work more interesting."
                   )
                   InstructionItem(
                       number: "2",
                       title: "Pitch Guidelines",
                       description: "As you draw higher on the canvas you get  higher sounds, and the lower you draw the lower the sounds. Use this to guide your music creation. Enjoy experimenting with different heights!"
                   )
                   
                   InstructionItem(
                       number: "3",
                       title: "Control The Speed",
                       description: "Adjust the speed slider to change the overall feel of your music. The speed of music is called tempo, and you can experiment with faster or slower tempos to see how they change the feel of your piece."
                   )
                   
                   InstructionItem(
                       number: "4",
                       title: "Use Horizontal/Diagonal Lines",
                       description: "Horizontal and diagonal lines tend to create more interesting sounds. Vertical lines may sound too heavy or messy, so try to avoid them for cleaner melodies."
                   )
                   
                   InstructionItem(
                       number: "5",
                       title: "Create Harmony with Spacing",
                       description: "The space between your lines helps create harmony. For example, skipping lines in a column forms chords (a group of notes played together). Experiment by extending columns across the rows to hear how that sounds."
                   )
                   
                   InstructionItem(
                       number: "6",
                       title: "Choose a Mood",
                       description: "Pick a mood that fits your drawing to make sure your music feels right. Different moods can make your music feel very different. Moods like “Excited” and “Mysterious” work well for beginners, because they’re based on chords and are hard to make sound bad, though they may feel a bit repetitive."
                   )
                   InstructionItem(
                       number: "7",
                       title: "Toggle the Grid",
                       description: "If the grid is distracting, click the eye icon to hide it. You can always bring it back by clicking again."
                   )
                   
                   InstructionItem(
                       number: "8",
                       title: "Drawing Speed Matters",
                       description: "The faster you draw, the more spread out your notes will be, making the music lively and fun. If you draw slowly, your notes will be packed closer together."
                   )
                   
                   InstructionItem(
                       number: "9",
                       title: "Layer for Depth",
                       description: "Layering your drawing adds complexity and depth to your music. By drawing across multiple rows, you can add more notes and create a fuller sound."
                   )
                   InstructionItem(
                       number: "10",
                       title: "Save & Edit",
                       description: "Save your work so you can come back and update it later. Just remember to click the update button when making changes to your saved file."
                   )
                   
                   InstructionItem(
                       number: "11",
                       title: "Don't Be Afraid to Experiment",
                       description: "Music is all about creativity, so don’t be afraid to try new things. Have fun and see where your imagination takes you!"
                   )
               }
               .padding(.bottom, 8)
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           

           Button(action: {
             
               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                   windowScene.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
               }

           }) {
               Text("Got it!")
                   .font(.system(size: 18, weight: .semibold))
                   .frame(maxWidth: .infinity)
                   .padding(.vertical, 16)
                   .background(
                       LinearGradient(
                           gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                           startPoint: .leading,
                           endPoint: .trailing
                       )
                   )
                   .foregroundColor(.white)
                   .cornerRadius(12)
                   .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
           }
       }
       .padding(24)
       .background(
           Color(UIColor.systemBackground)
               .overlay(
                   RoundedRectangle(cornerRadius: 20)
                       .stroke(Color.gray.opacity(0.15), lineWidth: 1)
               )
       )
       .cornerRadius(20)
       .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
   }
}

struct InstructionItem: View {
   let number: String
   let title: String
   let description: String
   
   var body: some View {
       HStack(alignment: .top, spacing: 16) {
    
           Text(number)
               .font(.system(size: 16, weight: .bold))
               .foregroundColor(.white)
               .frame(width: 32, height: 32)
               .background(
                   Circle()
                       .fill(
                           LinearGradient(
                               gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                               startPoint: .top,
                               endPoint: .bottom
                           )
                       )
               )
               .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 0, y: 1)
           
           VStack(alignment: .leading, spacing: 6) {
               Text(title)
                   .font(.system(size: 18, weight: .semibold))
                   .foregroundColor(.primary)
               
               Text(description)
                   .font(.system(size: 16))
                   .foregroundColor(.secondary)
                   .fixedSize(horizontal: false, vertical: true)
           }
       }
   }
}
