//
//  ContentView.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import SwiftUI

struct ContentView: View {

    @State private var showToast = false
    @State private var pubKeyBase58: String = ""
    @State private var unsignedHex: String = ""

    let actions = Actions()

    var body: some View {

        VStack {

            Spacer()

            TextField("Enter pubKeyBase58", text: $pubKeyBase58)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.title)

            TextField("Enter unsigned hex", text: $unsignedHex)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.title)

            Button(action: { actions.scan() }) {
                Text("Scan")
                    .font(.title)
                    .padding(.horizontal, 40)
                    .padding(.vertical)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: { actions.sign(unsignedHex: unsignedHex, pubKeyBase58: pubKeyBase58) }) {
                Text("Sign")
                    .font(.title)
                    .padding(.horizontal, 40)
                    .padding(.vertical)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
