//
//  AddViaggioView.swift
//  tirocinio
//
//  Created by Salvatore Apicella on 02/06/2022.
//

import SwiftUI

struct EditValigiaView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var nomeAgg: String
    @State var lunghezzaAgg: Double
    @State var larghezzaAgg: Double
    @State var profonditaAgg: Double
    @State var pesoAgg: Double
    
    var valigia: Valigia
    
    var body: some View {
        
        
        Form{
            Section(header: Text("Nome")){
                TextField("Nuovo nome viaggio", text: $nomeAgg)
            }

            Section(header: Text("Dimensioni")){
                Text("Volume (litri): \(String(format: "%.3f", lunghezzaAgg*larghezzaAgg*profonditaAgg/1000))")
                Text("Lunghezza (centimetri): \(Int(lunghezzaAgg)) ")
                Slider(value: $lunghezzaAgg, in: 1...60, step: 1.0)
                Text("Larghezza (centimetri): \(Int(larghezzaAgg))")
                Slider(value: $larghezzaAgg, in: 1...60, step: 1.0)
                Text("Profondita (centimetri): \(Int(profonditaAgg))")
                Slider(value: $profonditaAgg, in: 1...60, step: 1.0)
                
            }
            
            Section(header: Text("Tara (grammi): \(Int(pesoAgg))")){
                Slider(value: $pesoAgg, in: 0...3000, step: 50.0)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Modifica valigia")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    
                    if(lunghezzaAgg == 0){
                        lunghezzaAgg = 1
                    }
                    
                    if(larghezzaAgg == 0){
                        larghezzaAgg = 1
                    }
                    
                    if(profonditaAgg == 0){
                        profonditaAgg = 1
                    }
                    
                    if(pesoAgg == 0){
                        pesoAgg = 1
                    }
                    
                    let volume = lunghezzaAgg * larghezzaAgg * profonditaAgg
                    valigia.nome = nomeAgg
                    valigia.lunghezza = Int32(lunghezzaAgg)
                    valigia.larghezza = Int32(larghezzaAgg)
                    valigia.profondita = Int32(profonditaAgg)
                    valigia.volume = Int32(volume)
                    valigia.tara = Int32(pesoAgg)
                    PersistenceManager.shared.saveContext()
   
                    presentationMode.wrappedValue.dismiss()
                }, label: {Text("Save")})
            }
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {Text("Cancel")})
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .onChange(of: larghezzaAgg, perform: {value in hideKeyboard()})
        .onChange(of: lunghezzaAgg, perform: {value in hideKeyboard()})
        .onChange(of: profonditaAgg, perform: {value in hideKeyboard()})
        .onChange(of: pesoAgg, perform: {value in hideKeyboard()})

    }
    
}
