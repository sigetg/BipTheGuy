//
//  ContentView.swift
//  BipTheGuy
//
//  Created by George Sigety on 2/15/23.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var animateImage = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var bipImage = Image("clown")
    
    
    var body: some View {
        VStack {
            Spacer()
            bipImage
                .resizable()
                .scaledToFit()
                .scaleEffect(animateImage ? 1.0 : 0.9)
                .onTapGesture {
                    animateImage = false // will immediately shrink image down to 90% size using .scaleEffect
                    playSound(soundName: "punchSound")
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)) {
                        animateImage = true //will go from the 90% size back to 100% size using the .spring animation
                    }
                }
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                Label("Photo Library", systemImage: "photo.fill.on.rectangle.fill")
            }
            .onChange(of: selectedPhoto) { newValue in
                //we need to:
                // - get the data in the PhotosPickerItem selectedPhoto
                // - use the data to create a uiImage
                // - use the UI Image to create an image
                // - and assign the image to bipImage
                Task {
                    do {
                        if let data = try await
                            newValue?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                bipImage = Image(uiImage: uiImage)
                            }
                        }
                    } catch {
                        print("😡 ERROR: Loading failed \(error.localizedDescription)")
                    }
                }
            }
        }
        .padding()
    }
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription) creating audioPlayer.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
