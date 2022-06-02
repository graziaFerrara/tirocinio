//
//  DetailTripView.swift
//  ValigieSmart
//
//  Created by Salvatore Apicella on 25/04/22.
//

import SwiftUI

struct DetailTripView: View {
    
    var viaggio: Viaggio
    
    @Environment(\.colorScheme) var colorScheme
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    let valigieDB = PersistenceManager.shared.loadValigieViaggiantiFromViaggio(viaggio: viaggio)
                    let oggettiDB = PersistenceManager.shared.loadOggettiViaggiantiFromViaggio(viaggioRef: viaggio)
                    let insiemeDiValigie = leMieValigie.init(valigieViaggianti: valigieDB, oggettiViaggianti: oggettiDB)
                    HStack{
                        Spacer()
                        NavigationLink(destination: AddTripView(viaggio: viaggio)){
                            VStack{
                                Text("Aggiungi Oggetti")
                                Image(systemName: "archivebox.fill")
                                    .padding(.top, 1.0)
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color.init(white: 0.2) : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                            
                        }
                        Spacer()
                        
                        NavigationLink(destination: AddBagView(viaggio: viaggio)){
                            VStack{
                                Text("Aggiungi Valigie")
                                Image(systemName: "suitcase.fill")
                                    .padding(.top, 1.0)
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color.init(white: 0.2) : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)

                        
                        }
                        Spacer()
                    }
                    
                    
                    ForEach(insiemeDiValigie.tutteLeValigie){
                        singolaIstanza in
                        
                        if(singolaIstanza.oggettiInseriti.isEmpty == false){
                            Spacer()
                            VStack{
                                HStack{
                                    Text(singolaIstanza.nomeValigia)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    //                                    .foregroundColor(Color.blue)
                                    
                                    Spacer()
                                    VStack(alignment: .trailing){
                                        Text("Ingombro Occupato: \(singolaIstanza.volumeAttuale/1000)l di \(singolaIstanza.volumeMassimo/1000)l")
                                            .font(.caption)
                                        Text("Peso Occupato: \(singolaIstanza.pesoAttuale)g di \(singolaIstanza.pesoMassimo)g")
                                            .font(.caption)
                                    }
                                }
                                .padding(.bottom)
                                
                                ForEach(singolaIstanza.oggettiInseriti){
                                    singoloOggetto in
                                    
                                    HStack{
                                        Text("\((singoloOggetto.oggettoRef?.nome)!): \((singoloOggetto.oggettoRef?.peso)!)g")
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .background(coloreScelto(valigia: singolaIstanza))
                            .cornerRadius(10)
                            
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.large)
        .background{
            Image("bg1")
                .resizable()
                    .ignoresSafeArea()
                .scaledToFill()
        }
        .navigationTitle(viaggio.nome ?? "Nome viaggio")
        
        
        
        
    }
    
    private func  coloreScelto(valigia: valigiaDaRiempire) -> Color{
        
        var coloreDellaScheda: Color
        
        if(valigia.pesoAttuale > valigia.pesoMassimo){
            coloreDellaScheda = Color.init(Color.RGBColorSpace.sRGB, red: 1, green: 0.4, blue: 0.4, opacity: 1.0)
        }else if(Double(valigia.pesoAttuale) > Double(valigia.pesoMassimo) * 0.9){
            coloreDellaScheda = Color.init(Color.RGBColorSpace.sRGB, red: 1, green: 0.74, blue: 0.18, opacity: 1.0)
        }else{
            coloreDellaScheda = Color.init(Color.RGBColorSpace.sRGB, red: 0.39, green: 0.92, blue: 0.39, opacity: 1.0)
        }
        return coloreDellaScheda
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
    
    init(nomeValigiaExtra: String){
        self.id = UUID()
        self.nomeValigia = nomeValigiaExtra
        self.volumeAttuale = 0
        self.volumeMassimo = 0
        self.pesoAttuale = 0
        self.pesoMassimo = 0
        self.oggettiInseriti = []
    }
    
    func aggiungiOggettoAValigia(oggettoSingolo: OggettoViaggiante){
        self.oggettiInseriti.append(oggettoSingolo)
    }
}



struct leMieValigie{
    
    var oggettiDaAllocare: [OggettoViaggiante]
    
    var tutteLeValigie: [valigiaDaRiempire]
    
    init(valigieViaggianti: [ValigiaViaggiante], oggettiViaggianti: [OggettoViaggiante]){
        self.tutteLeValigie = []
        self.tutteLeValigie.append(valigiaDaRiempire.init(nomeValigiaExtra: "Non allocati"))
        for singolaValigia in valigieViaggianti{
            tutteLeValigie.append(valigiaDaRiempire.init(valigiaDaAggiungere: singolaValigia))
        }
        
        
        
        self.oggettiDaAllocare = oggettiViaggianti
        
        //Qui andrebbe ordinato il vettore oggettiDaAllocare in ordine di peso o di volume
        
        while (oggettiDaAllocare.isEmpty == false){
            
            var temp = (oggettiDaAllocare.popLast(),false)
            
            for valigiaAttuale in tutteLeValigie{
                if(temp.1 == false){
                    //Attualmente l'algoritmo implementato si basa solo ed unicamente sul peso va implementato anche sul volume
                    if((valigiaAttuale.pesoAttuale + Int(temp.0!.oggettoRef!.peso)) <= valigiaAttuale.pesoMassimo){
                        valigiaAttuale.oggettiInseriti.append(temp.0!)
                        valigiaAttuale.pesoAttuale += Int(temp.0!.oggettoRef!.peso)
                        temp.1 = true
                    }
                }
            }
            if(temp.1 == false){
                tutteLeValigie[0].oggettiInseriti.append(temp.0!)
                tutteLeValigie[0].pesoAttuale += Int(temp.0!.oggettoRef!.peso)
                temp.1 = true
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
