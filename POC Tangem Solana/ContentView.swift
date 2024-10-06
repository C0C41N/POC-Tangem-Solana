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
            
            HStack {

                TextField("pubKeyBase58", text: $pubKeyBase58)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .frame(width: 240)
                    .multilineTextAlignment(.center)
                    .disabled(true)
                
                Button(action: { if let clipboardString = UIPasteboard.general.string { pubKeyBase58 = clipboardString } }) {
                    Text("Paste").font(.caption)
                }
                
                Button(action: { pubKeyBase58 = "" }) {
                    Text("Clear").font(.caption)
                }

            }
            .padding()

            HStack {

                TextField("unsignedHex", text: $unsignedHex)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .frame(width: 240)
                    .multilineTextAlignment(.center)
                    .disabled(true)
                
                Button(action: { if let clipboardString = UIPasteboard.general.string { unsignedHex = clipboardString } }) {
                    Text("Paste").font(.caption)
                }
                
                Button(action: { unsignedHex = "" }) {
                    Text("Clear").font(.caption)
                }

            }
            .padding()

            Spacer().frame(height: 40)

            Button(action: { actions.scan() }) {
                Text("Scan")
                    .font(.title3)
                    .frame(width: 300)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer().frame(height: 20)

            Button(action: { actions.sign(unsignedHex: unsignedHex, pubKeyBase58: pubKeyBase58) }) {
                Text("Sign")
                    .font(.title3)
                    .frame(width: 300)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer().frame(height: 20)

            Button(action: { actions.purgeAllWallets() }) {
                Text("Purge All Wallets")
                    .font(.title3)
                    .frame(width: 300)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer().frame(height: 20)

            Button(action: { actions.createAllWallets() }) {
                Text("Create All Wallets")
                    .font(.title3)
                    .frame(width: 300)
                    .padding()
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
