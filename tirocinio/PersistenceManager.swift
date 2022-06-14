//
//  PersistenteManager.swift
//  tirocinio
//
//  Created by Cristian Cerasuolo on 29/04/22.
//

import Foundation
import CoreData
import SwiftUI

class PersistenceManager: ObservableObject {
    
    static let shared: PersistenceManager = PersistenceManager()
    
    private var context : NSManagedObjectContext

    // An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides convenience methods and properties for common patterns.
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer (name: "model")
        
        // Load stores from the storeDescriptions property that have not already been successfully added to the container. The completion handler is called once for each store that succeeds or fails.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init(){
        let center = NotificationCenter.default
        let notification = UIApplication.willResignActiveNotification
        
        self.context = self.persistentContainer.viewContext
        
        center.addObserver(forName: notification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            
            if self.persistentContainer.viewContext.hasChanges {
                try? self.persistentContainer.viewContext.save()
            }
            
            
        }
        
        
    }
    
    //     for later usage
    func saveContext() {
      // ViewContext is a special mangaed object context which is designated for use only on the main thread. Tou'll use this one to save any unsaved data.
      let context = persistentContainer.viewContext
      // 2
      if context.hasChanges {
        do {
          // 3
          try context.save()
        } catch {
          // 4
          // The context couldn't be saved.
          // You should add your own error handling here.
          let nserror = error as NSError
          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
      }
    }
    
    //Instructs the app to call the save method you previously added when the app goes into the background
    func sceneDidEnterBackground(_ scene: UIScene){
        saveContext()
    }
    
    //Retunr the context
    func getContext() -> NSManagedObjectContext{
        return self.context
    }
    //ADD
    func addValigia(categoria: String, lunghezza: Int, larghezza: Int, profondita: Int, nome: String, tara: Int, utilizzato:Bool){
        let entity = NSEntityDescription.entity(forEntityName: "Valigia", in: self.context)
        if(loadValigieFromNomeCategoria(nome: nome, categoria: categoria).isEmpty){
            let newValigia = Valigia(entity: entity!, insertInto: self.context)
            newValigia.nome = nome
            newValigia.categoria = categoria
            newValigia.lunghezza = Int32(lunghezza)
            newValigia.larghezza = Int32(larghezza)
            newValigia.profondita = Int32(profondita)
            newValigia.tara = Int32(tara)
            newValigia.utilizzato = utilizzato
            newValigia.volume = newValigia.profondita * newValigia.lunghezza * newValigia.larghezza
            newValigia.id = UUID()
            self.saveContext()
            print("Valigia salvata!")
        }else{
            print("Questa valigia è già presente!")
        }
    }
    
    

    func addViaggio(data: Date, nome: String){
        let entity = NSEntityDescription.entity(forEntityName: "Viaggio", in: self.context)
        
        if(loadViaggiFromNome(nome: nome).isEmpty){
            let newViaggio = Viaggio(entity: entity!, insertInto: self.context)
            
            newViaggio.nome = nome
            newViaggio.id = UUID()
            newViaggio.data = data
            
            self.saveContext()
            print("Viaggio salvato!")
        }else{
            print("Questo viaggio è già stato fatto")
        }
    }
    
    func addOggetto(categoria: String, larghezza: Int, lunghezza: Int, profondita: Int, peso: Int, nome: String){
        let entity = NSEntityDescription.entity(forEntityName: "Oggetto", in: self.context)
        
        if(loadOggettiFromNomeCategoria(nome: nome, categoria: categoria).isEmpty){
            let newOggetto = Oggetto(entity: entity!, insertInto: self.context)
            
            newOggetto.categoria = categoria
            newOggetto.nome = nome
            newOggetto.larghezza = Int32(larghezza)
            newOggetto.lunghezza = Int32(lunghezza)
            newOggetto.profondita = Int32(profondita)
            newOggetto.peso = Int32(peso)
            newOggetto.volume = Int32(larghezza * lunghezza * profondita)
            newOggetto.id = UUID()
            
            self.saveContext()
            print("Oggetto salvato!")
        }else{
            print("Questo oggetto esiste già")
        }
    }
    
    func addOggettoViaggiante(oggetto: Oggetto, viaggio: Viaggio){
        let entity = NSEntityDescription.entity(forEntityName: "OggettoViaggiante", in: self.context)
        
        //controllo se dati oggetto e valigia viaggiante, vi sia un oggetto viaggiante definito
        
        //        let oggettoInQuestione = loadOggettiViaggiantiFromOggettoViaggio(oggettoRef: oggetto, viaggioRef: viaggio)
        
        
        let newOggettoViaggiante = OggettoViaggiante(entity: entity!, insertInto: self.context)
        
        newOggettoViaggiante.id = UUID()
        newOggettoViaggiante.oggettoRef = oggetto
        newOggettoViaggiante.viaggioRef = viaggio
        newOggettoViaggiante.contenitore = nil //potrebbe non servire
        newOggettoViaggiante.allocato = false
        
        
        self.saveContext()
        print("Oggetto viaggiante salvato!")
    }
    
    func addValigiaViaggiante(valigia: Valigia, viaggio: Viaggio){
        let entity = NSEntityDescription.entity(forEntityName: "ValigiaViaggiante", in: self.context)
        
        
        let newValigiaViaggiante = ValigiaViaggiante(entity: entity!, insertInto: self.context)
        
        newValigiaViaggiante.id = UUID()
        newValigiaViaggiante.valigiaRef = valigia
        newValigiaViaggiante.viaggioRef = viaggio
        newValigiaViaggiante.pesoMassimo = 0 //a cosa serve? Forse per i limiti di peso
        newValigiaViaggiante.pesoAttuale = 0//come lo determino?
        newValigiaViaggiante.volumeAttuale = 0 //volume occupato internamente. 0 inizialmente
        newValigiaViaggiante.volumeMassimo = valigia.volume //il volume massimo è rappresentato dal volume massimo della valigia a cui si riferisce questa istanza
        newValigiaViaggiante.addToContenuto([])//nessun contenuto inizialmente
        
        valigia.utilizzato = true //se usiamo la valigia allora la mettiamo come utilizzata
        self.saveContext()
        print("ValigiaViaggiante salvata!")
        
    }
    
    //SELECTION
    func loadViaggiFromFetchRequest(request: NSFetchRequest<Viaggio>) -> [Viaggio] {
        var array = [Viaggio] ()
        do{
            
            array = try self.context.fetch(request)
        
            guard array.count > 0 else {print("Non ci sono elementi da leggere "); return [] }
            
//            for x in array {
//                let viaggio = x
//                print("Viaggio \(viaggio.nome!), data \(String(describing: viaggio.data)), id \(String(describing: viaggio.id))")
//            }
            
        }catch let errore{
            print("Problema nella esecuzione della FetchRequest")
            print("\(errore)")
        }
        return array
    }
    
    func loadValigieViaggiantiFromFetchRequest(request: NSFetchRequest<ValigiaViaggiante>) -> [ValigiaViaggiante] {
        var array = [ValigiaViaggiante]()
        do{
            array = try self.context.fetch(request)
        
            guard array.count > 0 else {print("Non ci sono elementi da leggere "); return [] }
            
            for x in array {
                let valigia = x.valigiaRef
                let viaggio = x.viaggioRef
                print("Valigia Viaggiante \n Contenitore: \(valigia?.nome ?? "Nome")\n Viaggio: \(viaggio?.nome ?? "Viaggio")")
            }
            
        }catch let errore{
            print("Problema nella esecuzione della FetchRequest")
            print("\(errore)")
        }
        return array
    }
    
    func loadOggettiViaggiantiFromFetchRequest(request: NSFetchRequest<OggettoViaggiante>) -> [OggettoViaggiante] {
        var array = [OggettoViaggiante]()
        do{
            array = try self.context.fetch(request)
        
            guard array.count > 0 else {print("Non ci sono elementi da leggere "); return [] }
            
            for x in array {
                let oggetto = x
                print("Oggetto Viaggiante \n OggettoRef:\(String(describing: oggetto.oggettoRef))\n ViaggioRef:\(String(describing: oggetto.viaggioRef))")
            }
            
        }catch let errore{
            print("Problema nella esecuzione della FetchRequest")
            print("\(errore)")
        }
        return array
    }
    
    func loadValigieFromFetchRequest(request: NSFetchRequest<Valigia>) -> [Valigia] {
        var array = [Valigia] ()
        do{
            array = try self.context.fetch(request)
            guard array.count > 0 else {print("Non ci sono elementi da leggere "); return [] }
            
//            for x in array {
//                let valigia = x
//                print("Valigia \(valigia.nome!), volume \(valigia.volume)")
//            }
            
        }catch let errore{
            print("Problema nella esecuzione della FetchRequest")
            print("\(errore)")
        }
        return array
    }
    
    func loadOggettiFromFetchRequest(request: NSFetchRequest<Oggetto>) -> [Oggetto]{
        var array = [Oggetto] ()
        do{
            array = try self.context.fetch(request)
            guard array.count > 0 else {print("Non ci sono elementi da leggere "); return [] }
            
        }catch let errore{
            print("Problema nella esecuzione della FetchRequest")
            print("\(errore)")
        }
        return array
    }
    
    
    
    func loadValigieFromNomeCategoria(nome: String, categoria: String) -> [Valigia] {
        let request: NSFetchRequest <Valigia> = NSFetchRequest(entityName: "Valigia")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "nome = %@ AND categoria = %@", nome, categoria)
        request.predicate = predicate
        
        let valigie = self.loadValigieFromFetchRequest(request:request)
        
        return valigie
    }
    
    func loadValigieFromCategoria(categoria: String) -> [Valigia] {
        let request: NSFetchRequest <Valigia> = NSFetchRequest(entityName: "Valigia")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "categoria = %@", categoria)
        request.predicate = predicate
        
        let valigie = self.loadValigieFromFetchRequest(request:request)
        
        return valigie
    }
    
    func loadValigieViaggiantiFromViaggioValigia(viaggio: Viaggio, valigia: Valigia) -> [ValigiaViaggiante] {
        let request: NSFetchRequest <ValigiaViaggiante> = NSFetchRequest(entityName: "ValigiaViaggiante")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "viaggioRef = %@ AND valigiaRef = %@", viaggio , valigia)
        request.predicate = predicate
        
        let valigie = self.loadValigieViaggiantiFromFetchRequest(request:request)
        
        return valigie
    }
    
    func loadValigieViaggiantiFromViaggio(viaggio: Viaggio) -> [ValigiaViaggiante] {
        let request: NSFetchRequest <ValigiaViaggiante> = NSFetchRequest(entityName: "ValigiaViaggiante")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "viaggioRef = %@", viaggio)
        request.predicate = predicate
        
        let valigie = self.loadValigieViaggiantiFromFetchRequest(request:request)
        
        return valigie
    }
    
    func loadOggettiViaggiantiFromOggettoViaggio(oggettoRef: Oggetto, viaggioRef: Viaggio) -> [OggettoViaggiante]{
        let request: NSFetchRequest <OggettoViaggiante> = NSFetchRequest(entityName: "OggettoViaggiante")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "oggettoRef = %@ AND viaggioRef = %@", oggettoRef, viaggioRef)
        request.predicate = predicate
        
        let oggetti = self.loadOggettiViaggiantiFromFetchRequest(request:request)
        
        return oggetti
    }
    
    func loadOggettiViaggiantiFromViaggio(viaggioRef: Viaggio) -> [OggettoViaggiante]{
        let request: NSFetchRequest <OggettoViaggiante> = NSFetchRequest(entityName: "OggettoViaggiante")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "viaggioRef = %@", viaggioRef)
        request.predicate = predicate
        
        let oggetti = self.loadOggettiViaggiantiFromFetchRequest(request:request)
        
        return oggetti
    }
    
    func loadValigieViaggiantiFromViaggio(viaggioRef: Viaggio) -> [ValigiaViaggiante]{
        let request: NSFetchRequest <ValigiaViaggiante> = NSFetchRequest(entityName: "ValigiaViaggiante")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "viaggioRef = %@", viaggioRef)
        request.predicate = predicate
        
        let valigie = self.loadValigieViaggiantiFromFetchRequest(request:request)
        
        return valigie
    }
    
    func loadViaggiFromNome(nome: String) -> [Viaggio] {
        let request: NSFetchRequest <Viaggio> = NSFetchRequest(entityName: "Viaggio")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "nome = %@", nome)
        request.predicate = predicate
        
        let viaggi = self.loadViaggiFromFetchRequest(request:request)
        return viaggi
    }
    
    func loadOggettiFromNomeCategoria(nome: String, categoria: String) -> [Oggetto] {
        let request: NSFetchRequest <Oggetto> = NSFetchRequest(entityName: "Oggetto")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "nome = %@ AND categoria = %@", nome, categoria)
        request.predicate = predicate
        
        let oggetti = self.loadOggettiFromFetchRequest(request:request)
        
        
        return oggetti
    }
    
    func loadOggettiFromCategoria(categoria: String) -> [Oggetto] {
        
        let request: NSFetchRequest <Oggetto> = NSFetchRequest(entityName: "Oggetto")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "categoria = %@", categoria)
        request.predicate = predicate
        
        let oggetti = self.loadOggettiFromFetchRequest(request:request)
        
        
        
        
        return oggetti
    }
    
    func loadOggettiFromID(ID: String) -> [Oggetto] {
        
        let request: NSFetchRequest <Oggetto> = NSFetchRequest(entityName: "Oggetto")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "id = %@", ID)
        request.predicate = predicate
        
        let oggetti = self.loadOggettiFromFetchRequest(request:request)
        
        
        
        
        return oggetti
    }
    
    
    func loadAllViaggi() -> [Viaggio] {
        let request: NSFetchRequest<Viaggio> = NSFetchRequest(entityName: "Viaggio")
        request.returnsObjectsAsFaults = false
        
        return self.loadViaggiFromFetchRequest(request: request)
    }
    
    func loadAllValigie() -> [Valigia] {
        
        let request: NSFetchRequest<Valigia> = NSFetchRequest(entityName: "Valigia")
        // Questa proprietà, che di default è true, permette di recuperare gli oggetti in maniera non completa. Questo ti permette di ottimizzare i tempi di recupero degli oggetti nel caso in cui il context sia composto da più di 1k managed object.
                
        //  In pratica, con la proprietà uguale a true, vengono recuperati gli oggetti ma i valori delle loro proprietà vengono mantenuti in cache e recuperati solo quando d’effettivo bisogno (cioè quando ci accedi).
                
        //  Nel nostro caso, dato che stiamo leggendo i valori degli oggetti, questa proprietà risulterebbe inutile dato che vogliamo leggere immediatamente i valori. Quindi, a valore = false, significa che gli oggetti vengono recuperati per interi.
        request.returnsObjectsAsFaults = false
        
//        /*let valigie = */self.loadValigieFromFetchRequest(request: request)
        return self.loadValigieFromFetchRequest(request: request)
    }
    
    func loadAllOggetti() -> [Oggetto]{
        let request: NSFetchRequest<Oggetto> = NSFetchRequest(entityName: "Oggetto")
        request.returnsObjectsAsFaults = false
    
        return self.loadOggettiFromFetchRequest(request: request)
    }
    
    func loadAllCategorieOggetti() -> [String]{
        let request: NSFetchRequest<Oggetto> = NSFetchRequest(entityName: "Oggetto")
        request.returnsObjectsAsFaults = false
        
        let oggettiDaDB = self.loadOggettiFromFetchRequest(request: request)
        
        var categorieLista = Set<String>.init()
        
        for oggetto in oggettiDaDB {
            categorieLista.insert(oggetto.categoria!)
        }
        
        var categorieArray = Array<String>.init()
        
        for singolaCat in categorieLista{
            categorieArray.append(singolaCat)
        }
        
        return categorieArray
    }
    
    func loadAllCategorieValigie() -> [String]{
        let request: NSFetchRequest<Valigia> = NSFetchRequest(entityName: "Valigia")
        request.returnsObjectsAsFaults = false
        
        let valieieDaDB = self.loadValigieFromFetchRequest(request: request)
        
        var categorieLista = Set<String>.init()
        
        for valigia in valieieDaDB {
            categorieLista.insert(valigia.categoria!)
        }
        
        var categorieArray = Array<String>.init()
        
        for singolaCat in categorieLista{
            categorieArray.append(singolaCat)
        }
        
        return categorieArray
    }
    
    func loadAllOggettiViaggianti() -> [OggettoViaggiante]{
        let request: NSFetchRequest<OggettoViaggiante> = NSFetchRequest(entityName: "OggettoViaggiante")
        request.returnsObjectsAsFaults = false
    
        return self.loadOggettiViaggiantiFromFetchRequest(request: request)
    }
    
    func loadAllValigieViaggianti() -> [ValigiaViaggiante] {
        let request: NSFetchRequest<ValigiaViaggiante> = NSFetchRequest(entityName: "ValigiaViaggiante")
        request.returnsObjectsAsFaults = false
        
        return self.loadValigieViaggiantiFromFetchRequest(request: request)
    }
    
    //DELETE
    func deleteValigia(nome: String, categoria: String) {
        let valigie = self.loadValigieFromNomeCategoria(nome: nome, categoria: categoria)
        
        if (valigie.count>0){
            self.context.delete(valigie[0])
            // per ipotesi nome e categoria sono le chiavi, per cui non ci possono essere duplicati su questi attributi, dunque l'array sarà composto da un unico valore
            print("Valigie: \(String(describing: valigie[0].nome))")
            self.saveContext()
        }
    }
    
    func deleteValigiaViaggiante(viaggio: Viaggio, valigia: Valigia) {
        let valigieviaggianti = self.loadValigieViaggiantiFromViaggioValigia(viaggio: viaggio, valigia: valigia)
        
        if(valigieviaggianti.count > 0){
            self.context.delete(valigieviaggianti[0])
            
            self.saveContext()
        }
    }
    
    func deleteViaggio(nome: String){
        let viaggi = self.loadViaggiFromNome(nome: nome)
        
        if(viaggi.count > 0){
            self.context.delete(viaggi[0])
            print("Viaggi: \(String(describing: viaggi[0].nome))")
            self.saveContext()
        }
    }
    
    func deleteOggetto(nome: String, categoria: String){
        let oggetti = self.loadOggettiFromNomeCategoria(nome: nome, categoria: categoria)
        
        if(oggetti.count > 0){
            self.context.delete(oggetti[0])
            print("Oggetti: \(String(describing: oggetti[0].nome))")
            self.saveContext()
        }
    }
    
    func deleteOggettoViaggiante(ogetto: Oggetto, viaggio: Viaggio){
        let oggettiViaggianti = self.loadOggettiViaggiantiFromOggettoViaggio(oggettoRef: ogetto, viaggioRef: viaggio)
        
        if(oggettiViaggianti.count > 0){
            self.context.delete(oggettiViaggianti[0])
            print("Oggetti: \(String(describing: oggettiViaggianti[0].oggettoRef?.nome))")
            self.saveContext()
        }
    }
    
    func deleteAllOggettoViaggiante(viaggio: Viaggio){
        let oggettiViaggianti = self.loadOggettiViaggiantiFromViaggio(viaggioRef: viaggio)
        
        if(oggettiViaggianti.count > 0){
            
            for oggetto in oggettiViaggianti{
                self.context.delete(oggetto)
               
            }
            self.saveContext()
        }
    }
    
    func deleteAllValigiaViaggiante(viaggio: Viaggio){
        let valigieViaggianti = self.loadValigieViaggiantiFromViaggio(viaggioRef: viaggio)
        
        if(valigieViaggianti.count > 0){
            
            for valigia in valigieViaggianti{
                self.context.delete(valigia)
                
            }
            self.saveContext()
        }
    }
    
    //UTILITY
    func allocaOggetti(viaggio: Viaggio) -> Bool{
        print("Inizio ad allocare")
        var state = true //false indica che non è stato trovata una configurazione tale per cui gli item sono conservati in maniera ottimale
        //dato un viaggio effettua l'allocazione degli oggetti non ancora allocati (o la rifa totalmetne?) nella valigieviaggianti create per quel viaggio
        //Dovrebbe essere la main function per performare gli algoritmi ancora da definrie :(
        
        //definisco la lista dei miei contenitore per quel viaggio
        var bins: [ValigiaViaggiante] = []
        
        let allValigie = loadAllValigie()
        
        for valigiareale in allValigie{
            //per ogni valigia vado a vedere le valigie viaggianti associate per il dato viaggio
            bins.append(contentsOf: loadValigieViaggiantiFromViaggioValigia(viaggio: viaggio, valigia: valigiareale))
        }
        //definisco l'insieme degli oggetti che sono definiti per quel viaggio. Non prendo solo quelli allocati perchè ritengo più efficiente rifare l'allocazione avendo oggetti diversi e quindi una possibile allocazione totalmente diversa
        var elements: [OggettoViaggiante] = []
        
        elements.append(contentsOf: loadOggettiViaggiantiFromViaggio(viaggioRef: viaggio))
        
        //a questo punto ho tutti i bins di volume differente e tutti gli elementi di volume
        
        //ordino gli oggetti in maniera decrescente di priorità di inserimento. Assumo che la priorità sia dettata dal volume
        //FIRST FIT DECREASING
        
        elements.sorted(by: {$0.oggettoRef?.volume ?? 0 > $1.oggettoRef?.volume ?? 0}) //Ordino gli elementi in maniera decrescente
        
        
        for item in elements{
            item.allocato = false //poichè potrei partire da una situazione in cui ho già fatto una allocazione, imposto a falso il flag
            for i in bins.indices{
                if bins[i].volumeAttuale + (item.oggettoRef!.volume) < bins[i].volumeMassimo /*&& (bins[i].pesoAttuale + (item.oggettoRef!.peso) < bins[i].pesoMassimo)*/{
                    item.allocato = true
                    print("\(item) allocato in \(bins[i].valigiaRef!.nome)")
                    bins[i].addToContenuto(item)
                    bins[i].volumeAttuale += item.oggettoRef!.volume
                    bins[i].pesoAttuale += item.oggettoRef!.peso
                    //modifico l'array di contenitori in maniera tale da spostare il bin considerato alla fine ed equilibare il carico
                    bins.append(bins.removeFirst())
                    
                    break
                }

            }
            if !item.allocato{
                print("Ops l'elemento non entra")
                state = false
            }
        }
        
        return state
    }
   

}