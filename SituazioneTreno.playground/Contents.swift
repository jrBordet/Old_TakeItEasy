//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

//: Playground - noun: a place where people can play

import UIKit

func jrDecoder<T: Decodable>(_ a: T, data: Data) -> T? {
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        return nil
    }
}

struct ReturnInfo: Decodable {
    let ReturnsInfo: String
}

extension Decodable {
    static func jrDecoder<T>(_ a: T, data: Data) -> T? where T : Decodable {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}


struct Andamento: Decodable {
    let origine: String
    let destinazione: String
    let compNumeroTreno: String
    let compOraUltimoRilevamento: String
    let compRitardoAndamento: [String]
    //let compRitardo: Int
}
/*
 compRitardo
compRitardoAndamento
 */

if let path = Bundle.main.path(forResource: "source", ofType: "json")
{
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        
        let andamento = try JSONDecoder().decode(Andamento.self, from: data)
        
        print(andamento)
        print("\n\n")
        
//        let deliveryInfoRoot = try JSONDecoder().decode(DeliveryInfoRoot.self, from: data)
//        //jrDecoder(DeliveryInfoRoot, data: data)
//        //try JSONDecoder().decode(DeliveryInfoRoot.self, from: data)
//
//        debugPrint(deliveryInfoRoot.DeliveryInfo[0].icon)
//        debugPrint(deliveryInfoRoot.DeliveryInfo[0].title)
//        print("\n")
//
//        debugPrint(deliveryInfoRoot.DeliveryInfo[0].content[0].content)
//        debugPrint(deliveryInfoRoot.DeliveryInfo[0].content[0].header)
//        print("\n")
//
//        debugPrint(deliveryInfoRoot.DeliveryInfo[0].content[1].content)
//        debugPrint(deliveryInfoRoot.DeliveryInfo[0].content[1].header)
//        print("\n")
//
//        debugPrint(deliveryInfoRoot.DeliveryInfo[0])
//
//        deliveryInfoRoot.DeliveryInfo.forEach({ deliveryInfo in
//            debugPrint(deliveryInfo)
//            print("\n\n")
//        })
    }
    catch
    {
        // handle error
        debugPrint(error)
    }
}



