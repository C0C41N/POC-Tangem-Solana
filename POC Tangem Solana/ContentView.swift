//
//  ContentView.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showToast = false
    let actions = Actions()

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                actions.scan()
            }) {
                Text("Scan")
                    .font(.title)
                    .padding(.horizontal, 40)
                    .padding(.vertical)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                actions.trx()
            }) {
                Text("TRX")
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
