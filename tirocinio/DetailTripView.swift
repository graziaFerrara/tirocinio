//
//  DetailTripView.swift
//  ValigieSmart
//
//  Created by Salvatore Apicella on 25/04/22.
//

import SwiftUI

struct DetailTripView: View {
    
    var viaggio: Viaggio
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        VStack{
            Text("Per essere pronto al viaggio non dimenticare di aggiungere tutti gli oggetti necessari e le valigie che hai a disposizione per questo viaggio!")
                .font(.headline)
                .multilineTextAlignment(.center)
                
            HStack{
                
                Spacer()
                NavigationLink(destination: AddTripView(viaggio: viaggio)){
                    VStack{
                        Text("Aggiungi Oggetti")
                        Image(systemName: "archivebox.fill")
                            .padding(.top, 1.0)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    
                }
            
                Spacer()
            
                NavigationLink(destination: AddBagView(viaggio: viaggio)){
                    VStack{
                        Text("Aggiungi Valigie")
                        Image(systemName: "suitcase.fill")
                            .padding(.top, 1.0)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                }
                
                Spacer()
               
                
            }
            
            
//            ForEach(PersistenceManager.shared.loadAllOggettiViaggianti()){
//                oggettino in
//                Text((oggettino.oggettoRef?.nome)!)
//            }
//            ForEach(PersistenceManager.shared.loadAllValigieViaggianti()){
//                valigetta in
//                Text((valigetta.valigiaRef?.nome)!)
//            }
            
            
            ScrollView(.vertical){
                
                let valigieDB = PersistenceManager.shared.loadAllValigieViaggianti()
                let oggettiDB = PersistenceManager.shared.loadAllOggettiViaggianti()
               
                let insiemeDiValigie = leMieValigie.init(valigieViaggianti: valigieDB, oggettiViaggianti: oggettiDB)
                
//                ForEach(insiemeDiValigie.tutteLeValigie){
//                    singolaIstanza in
//                    Text("Nome valigia:\(singolaIstanza.nomeValigia), ci sono \(singolaIstanza.oggettiInseriti.count)oggetti")
//                }
                
                ForEach(insiemeDiValigie.tutteLeValigie){
                    singolaIstanza in
                    VStack{
                        Text(singolaIstanza.nomeValigia)
                            .font(.title)
                            .foregroundColor(Color.blue)
                        ForEach(singolaIstanza.oggettiInseriti){
                            singoloOggetto in
                            Text((singoloOggetto.oggettoRef?.nome)!)
                                .font(.body)
                            
                        }
                        Spacer()
                    }
                }
            }
            
             
            
            Spacer()
        }
        .padding()
        
        
        
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(viaggio.nome ?? "Nome viaggio")
        
    }
    
}

class valigiaDaRiempire: Identifiable{
    var id: UUID
    var nomeValigia: String
    var volumeAttuale: Int
    var volumeMassimo: Int
    var pesoAttuale: Int
    var pesoMassimo: Int
    var oggettiInseriti: [OggettoViaggiante]
    
    
    init(valigiaDaAggiungere: ValigiaViaggiante){
        self.id = UUID()
        self.nomeValigia = (valigiaDaAggiungere.valigiaRef?.nome)!
        self.volumeAttuale = 0
        self.volumeMassimo = Int(valigiaDaAggiungere.valigiaRef!.volume)
        self.pesoAttuale = 0
        self.pesoMassimo = Int(valigiaDaAggiungere.valigiaRef!.tara) //qui ci dovrà andare peso
        self.oggettiInseriti = []
    }
    
    func aggiungiOggettoAValigia(oggettoSingolo: OggettoViaggiante){
        self.oggettiInseriti.append(oggettoSingolo)
    }
}

struct leMieValigie{
    
    var tutteLeValigie: [valigiaDaRiempire]
    
    init(valigieViaggianti: [ValigiaViaggiante], oggettiViaggianti: [OggettoViaggiante]){
        self.tutteLeValigie = []
        for singolaValigia in valigieViaggianti{
            tutteLeValigie.append(valigiaDaRiempire.init(valigiaDaAggiungere: singolaValigia))
            }
        
      
        for valigiaAttuale in tutteLeValigie{
            for singoloOggetto in oggettiViaggianti{
                if((valigiaAttuale.pesoAttuale + Int(singoloOggetto.oggettoRef!.peso)) < valigiaAttuale.pesoMassimo){
                    valigiaAttuale.oggettiInseriti.append(singoloOggetto)
                    valigiaAttuale.pesoAttuale += Int(singoloOggetto.oggettoRef!.peso)
                }
            }
        }
    }
}

struct DetailTripView_Previews: PreviewProvider {
    static var previews: some View {
        DetailTripView(viaggio: PersistenceManager.shared.loadAllViaggi()[0])
            .previewDevice("iPhone 11")
    }
}
