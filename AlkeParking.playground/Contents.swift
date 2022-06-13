import UIKit
import Foundation

// 2.1 generar enum
enum VehicleType {
    
    case car, moto, miniBus, bus
    
    // 2.3 precio x tipo de vehiculo
    var price: Int {
        switch self {
        case .car:
            return 20
        case .moto:
            return 15
        case .miniBus:
            return 25
        case .bus:
            return 30
        }
    }
}

// todo lo que tiene vehiculo debe usar la interfaz protocol
// 1 protocol
protocol Parkable {

    // 1.1 Tener una patente
    var plate: String { get }
    // 1.2 Debe ser de un tipo de vehículo permitido en el estacionamiento
    // 2.2 Tipo del enum
    var type: VehicleType { get }
    // 1.3,3.1 Se debe registrar la fecha de ingreso.
    var checkInTime: Date { get }
    // 1.4,3.2 Tarjeta de descuentos opcional
    var discountCard: String? { get }
    // 1.5 Tiempo total en el estacionamiento
    var parkedTime: Int { get }
}

// 1 protocolo Hashable
struct Vehicle: Parkable, Hashable {

    var plate: String
    
    var type: VehicleType
    
    var checkInTime: Date
    
    var discountCard: String?
    
    // 4.1 Calcular diferencia en minutos
    var parkedTime: Int {
        get {
            return Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
        }
    }
}

extension Vehicle {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    // funcion que permite determinar si las patentes son iguales List  vs nueva patente
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
    
    func fullDescription() {
        
        var message: String = "plate: \(plate) type: \(type) check in time: \(checkInTime)"
        if let discountCard =  discountCard  {
            message += " discount card:  \(discountCard)"
        }
        print(message)
    }
}


struct Parking {
    
    // pasar variable a privado.
    var vehicles: Set<Vehicle> = []
    
    // 5.1 maximo de vehiculo
    let maximumVehiclesParked: Int = 20
    
    // 11.1
    var totalEarned: (vehicleQuantity: Int, totalCharged: Int) = (0,0)
    
    // parte de ejemplos, verificar si esta en alguna pregunta ¿ 1-5 ?
    mutating func addVehicle( vehicle: Vehicle)  -> Bool {
        // considerar la fecha de inicio - buscar en internet
        print("new item:")
        vehicle.fullDescription()
        return vehicles.insert(vehicle).inserted
    }
    mutating func removeVehicle ( vehicle: Vehicle) {
        // considerar la fecha de fin - buscar en internet
        vehicles.remove(vehicle)
    }
    mutating func removeVehicleByIndex ( index: Set<Vehicle>.Index) {
        vehicles.remove(at: index)
    }
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool) -> Void) {
        
        // 5.2a
        guard  vehicles.count < maximumVehiclesParked else {
            print("the maximum capacity of the car park has been reached:  \(vehicles.count)")
            onFinish(false)
            return
        }
        // 5.2b
        let isVehicle =  vehicles.contains {
            veh in
            if case vehicle.plate = veh.plate {
                //print("plate found in vehicle list: \(vehicle.plate)")
                return true
            }
            //print ("plate not found")
            return false
        }
        // 5.2b
        guard !isVehicle else {
            print("plate found in vehicle list: \(vehicle.plate)")
            onFinish(false)
            return
        }
        
        // 5.3
        let isInsertedVehicle = addVehicle(vehicle: vehicle)
        
        if isInsertedVehicle {
            print("position index of the new element: \(vehicles.count)")
        }
        onFinish(isInsertedVehicle)
        return
    }
    
    // 7.1
    mutating func checkOutVehicle(_ plate: String, onSuccess: (Int) -> Void, onError: () -> Void) {
        
        print("plate              : \(plate)")

        // 7.2
        guard let vehicle = vehicles.first(where: { $0.plate == plate }) else {
            onError()
            return
        }
        
        let isDiscountCard = !(vehicle.discountCard?.isEmpty ?? false)
        print("is discount card?  : \(isDiscountCard)")
        
        let parkedTime = vehicle.parkedTime
        
        print("total parked time  : \(parkedTime) minute(s)")
        
        let feePayParking = calculateFee(vehicle.type, parkedTime, isDiscountCard);
        print("fee pay parking    : \(feePayParking)")
        
        // 7.3 -- validar si lo elimino***
        removeVehicle(vehicle: vehicle)
        
        // 11.1
        // vehicleQuantity = 0 = vehiculos retirados
        totalEarned.vehicleQuantity += 1
        // totalCharged = 1 = tarifa cobrada acumalada
        totalEarned.totalCharged += feePayParking
        
        // 10.1
        onSuccess(feePayParking)
    }
    
    // 8.1, 8.2
    // 9.1 agregar un parámetro booleano hasDiscountCard
    func calculateFee(_ type: VehicleType, _ parkedTime: Int, _ hasDiscountCard: Bool) -> Int {
        
        print("type               : \(type)")
        print("type - price       : \(type.price)")
        
        var fee: Int = 0
        var fifteenExtraMinutes: Double = 0
        var discount = 0
        
        // 2 horas
        if parkedTime > 120 {
            print("extra minutes      : \(parkedTime-120) min")
            fifteenExtraMinutes = ceil(Double(parkedTime-120) / 15)
        }
        print("15 minutes         : \(fifteenExtraMinutes)")
        fee = type.price  + (Int(fifteenExtraMinutes) * 5)
        print("sub total          : \(fee)")
        
        // 9.2
        if hasDiscountCard {
            discount = Int( round(Double(fee) * 0.15 ))
            //if fee < 0 { fee = 0}
        }
        print("discount           : \(discount)")
        
        // 9.2
        return fee - discount
    }
    
    // 11.2
    func totalEarnings() {
        print("\(totalEarned.vehicleQuantity) vehicles have checked out and have earnings of \(totalEarned.totalCharged) dolars")
    }
    
    // 12
    func vehicleList() {
        for veh in vehicles {
            veh.fullDescription()
        }
    }
}

func messageCheckOutSuccess(fee: Int) {
    print("Your fee is: \(fee) dolars. Come back soon\n")
}

func messageCheckOutFailed() {
    print("Sorry, the chek-out failed\n")
}

// Se extiende funcionalidad de Date para agregar o restar minutos a una fecha.
extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}

// TESTING

var accParking = Parking()
let accVehicle = Vehicle(plate: "RRHK-51", type: .car, checkInTime: Date(), discountCard: "yes")
accParking.addVehicle(vehicle: accVehicle)

print("Cantidad de vehículos en el estacionamiento: \(accParking.vehicles.count)")

//sleep(3)

print("parked Time: \(accVehicle.parkedTime)s")

let index = accParking.vehicles.firstIndex(of: accVehicle)
if let index = index {
    accParking.removeVehicleByIndex(index: index)
}

print("Cantidad de vehículos en el estacionamiento: \(accParking.vehicles.count)")
print("")


// 4
var alkeParking = Parking()

let car = Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_001")
let car_2 = Vehicle(plate: "AA111AA", type: VehicleType.moto, checkInTime: Date(), discountCard: nil)
let moto = Vehicle(plate: "B222BBB", type: VehicleType.moto, checkInTime: Date(), discountCard: nil)
let miniBus = Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let bus = Vehicle(plate: "DD444DD", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002")

print("car \(car.plate) - insert is    : "  + String(alkeParking.vehicles.insert(car).inserted))
print("car \(car.plate) - insert is    : "  + String(alkeParking.vehicles.insert(car).inserted))
print("car \(car_2.plate) - insert is    : "  + String(alkeParking.vehicles.insert(car_2).inserted))

print("moto \(moto .plate) - insert is   : "  + String(alkeParking.vehicles.insert(moto).inserted))
print("miniBus \(miniBus.plate) - insert is: "  + String(alkeParking.vehicles.insert(miniBus).inserted))
print("bus \(bus.plate) - insert is    : "  + String(alkeParking.vehicles.insert(bus).inserted))

let car2 = Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003")
print("car2 \(car2.plate) - insert is   : "  + String(alkeParking.vehicles.insert(car2).inserted))
alkeParking.vehicles.insert(car2)

// remover moto
alkeParking.vehicles.remove(moto)


var alkemiParking = Parking()

// 5, 6.1 y 6.2
let vehicleList = [Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date().adding(minutes: -125), discountCard: "DISCOUNT_CARD_001"),
                   Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002"),
                   Vehicle(plate: "B222BBB", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "DD444DD", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002"),
                   Vehicle(plate: "AA111BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003"),
                   Vehicle(plate: "B222CCC", type: VehicleType.moto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_004"),
                   Vehicle(plate: "CC333DD", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "DD444EE", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_005"),
                   Vehicle(plate: "AA111CC", type: VehicleType.car, checkInTime: Date().adding(minutes: -193), discountCard: nil),
                   Vehicle(plate: "B222DDD", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333EE", type: VehicleType.miniBus, checkInTime: Date().adding(minutes: -150), discountCard: nil),
                   Vehicle(plate: "DD444GG", type: VehicleType.bus, checkInTime: Date().adding(minutes: -60), discountCard: "DISCOUNT_CARD_006"),
                   Vehicle(plate: "AA111DD", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_007"),
                   Vehicle(plate: "B222EEE", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333AA", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333BB", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333DD", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333EE", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333GG", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333HH", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333II", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333JJ", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333KK", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333LL", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333MM", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
                   Vehicle(plate: "CC333MM", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
                   ]

print("")
print("*** Add to parking object ***\n")
// 6.3
vehicleList.forEach{ vehicle in
    alkemiParking.checkInVehicle(vehicle) { result in
        if (result) { // true
            print("Welcome to AlkeParking!\n")
        } else { // false
            print("Sorry, the check-in failed\n")
        }
    }
}

print("\n*** Check Out Vehicle ***\n")
// menos 2h:5m
alkemiParking.checkOutVehicle("AA111AA", onSuccess: messageCheckOutSuccess, onError: messageCheckOutFailed)
alkemiParking.checkOutVehicle("AA111AT", onSuccess: messageCheckOutSuccess, onError: messageCheckOutFailed)
// menos 1h:0m:
alkemiParking.checkOutVehicle("DD444GG", onSuccess: messageCheckOutSuccess, onError: messageCheckOutFailed)
// menos 2h:30m
alkemiParking.checkOutVehicle("CC333EE", onSuccess: messageCheckOutSuccess, onError: messageCheckOutFailed)
// menos 3h:13m
alkemiParking.checkOutVehicle("AA111CC", onSuccess: messageCheckOutSuccess, onError: messageCheckOutFailed)

print("\n*** Total Earnings ***\n")
alkemiParking.totalEarnings()

print("\n*** the vehicles that are in the parking lot ***\n")
alkemiParking.vehicleList()
