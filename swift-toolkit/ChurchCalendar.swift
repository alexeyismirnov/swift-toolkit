
import UIKit

public enum FeastType: Int {
    case none=0, noSign, sixVerse, doxology, polyeleos, vigil, great
}

public enum NameOfDay: Int {
    case startOfYear=0, pascha, pentecost, ascension, palmSunday, eveOfNativityOfGod, nativityOfGod, circumcision, eveOfTheophany, theophany, meetingOfLord, annunciation, nativityOfJohn, peterAndPaul, transfiguration, dormition, beheadingOfJohn, nativityOfTheotokos, exaltationOfCross, veilOfTheotokos, entryIntoTemple, stNicholas, sundayOfPublicianAndPharisee, sundayOfProdigalSon, sundayOfDreadJudgement, cheesefareSunday, beginningOfGreatLent, beginningOfDormitionFast, beginningOfNativityFast, beginningOfApostlesFast, sundayOfForefathers, sundayBeforeNativity, sundayAfterExaltation, saturdayAfterExaltation, saturdayBeforeExaltation, sundayBeforeExaltation, saturdayBeforeNativity, saturdayAfterNativity, sundayAfterNativity, saturdayBeforeTheophany, sundayBeforeTheophany, saturdayAfterTheophany, sundayAfterTheophany, sunday2AfterPascha, sunday3AfterPascha, sunday4AfterPascha, sunday5AfterPascha, sunday6AfterPascha, sunday7AfterPascha, lazarusSaturday, newMartyrsConfessorsOfRussia, demetriusSaturday, radonitsa, killedInAction, josephBetrothed, synaxisTheotokos, holyFathersSixCouncils, holyFathersSeventhCouncil, allRussianSaints,  synaxisMoscowSaints, synaxisNizhnyNovgorodSaints, saturdayOfFathers, synaxisForerunner, saturdayTrinity, saturdayOfDeparted, endOfYear
}

public enum DayOfWeek: Int  {
    case sunday=1, monday, tuesday, wednesday, thursday, friday, saturday
}

struct DateCache : Hashable {
    let code : NameOfDay
    let year : Int
    init(_ code: NameOfDay, _ year: Int) {
        self.code = code
        self.year = year
    }
    var hashValue: Int {
        return code.hashValue ^ year.hashValue
    }
}

// MARK: Equatable

func == (lhs: DateCache, rhs: DateCache) -> Bool {
    return lhs.code == rhs.code && lhs.year == rhs.year
}

public struct ChurchCalendar {
    static var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static public var currentDate: Date!
    static public var currentYear: Int!
    static public var currentWeekday: DayOfWeek = .monday
    
    static public var isLeapYear: Bool {
        get { return (currentYear % 400) == 0 || ((currentYear%4 == 0) && (currentYear%100 != 0)) }
    }
    
    static public var leapStart: Date {
        get { return Date(29, 2, currentYear) }
    }
    
    static public var leapEnd: Date {
        get { return Date(13, 3, currentYear) }
    }
    
    static var feastDates = [Date: [NameOfDay]]()
    static var dCache = [DateCache:Date]()

    static var dateFeastDescr = [Date: [(FeastType, String)]]()

    static public  let codeFeastDescr : [NameOfDay: (FeastType, String)] = [
        .pascha:                    (.great, "PASCHA. The Bright and Glorious Resurrection of our Lord, God, and Saviour Jesus Christ"),
        .pentecost:                 (.great, "Pentecost. Sunday of the Holy Trinity. Descent of the Holy Spirit on the Apostles"),
        .ascension:                 (.great, "Ascension of our Lord, God, and Saviour Jesus Christ"),
        .palmSunday:                (.great, "Palm Sunday. Entrance of our Lord into Jerusalem"),
        .eveOfNativityOfGod:        (.noSign, "Eve of the Nativity of Christ"),
        .nativityOfGod:             (.great, "The Nativity of our Lord God and Savior Jesus Christ"),
        .circumcision:              (.great, "Circumcision of our Lord"),
        .eveOfTheophany:            (.noSign, "Eve of Theophany"),
        .theophany:                 (.great, "Holy Theophany: the Baptism of Our Lord, God, and Saviour Jesus Christ"),
        .meetingOfLord:             (.great, "The Meeting of our Lord, God, and Saviour Jesus Christ in the Temple"),
        .annunciation:              (.great, "The Annunciation of our Most Holy Lady, Theotokos and Ever-Virgin Mary"),
        .nativityOfJohn:            (.great, "Nativity of the Holy Glorious Prophet, Forerunner, and Baptist of the Lord, John"),
        .peterAndPaul:              (.great, "The Holy Glorious and All-Praised Leaders of the Apostles, Peter and Paul"),
        .transfiguration:           (.great, "The Holy Transfiguration of Our Lord God and Saviour Jesus Christ"),
        .dormition:                 (.great, "The Dormition (Repose) of our Most Holy Lady Theotokos and Ever-Virgin Mary"),
        .beheadingOfJohn:           (.great, "The Beheading of the Holy Glorious Prophet, Forerunner and Baptist of the Lord, John"),
        .nativityOfTheotokos:       (.great, "Nativity of Our Most Holy Lady Theotokos and Ever-Virgin Mary"),
        .exaltationOfCross:         (.great, "The Universal Exaltation of the Precious and Life-Giving Cross"),
        .veilOfTheotokos:           (.great, "Protection of Our Most Holy Lady Theotokos and Ever-Virgin Mary"),
        .entryIntoTemple:           (.great, "Entry into the Temple of our Most Holy Lady Theotokos and Ever-Virgin Mary"),
        .beginningOfGreatLent:      (.none, "Beginning of Great Lent"),
        .beginningOfDormitionFast:  (.none, "Beginning of Dormition fast"),
        .beginningOfNativityFast:   (.none, "Beginning of Nativity fast"),
        .beginningOfApostlesFast:  (.none, "Beginning of Apostles' fast"),
        .sundayOfForefathers:       (.none, "Sunday of the Holy Forefathers"),
        .sundayAfterExaltation:     (.none, "Sunday after the Exaltation"),
        .saturdayAfterExaltation:   (.none, "Saturday after the Exaltation"),
        .saturdayBeforeExaltation:  (.none, "Saturday before the Exaltation"),
        .sundayBeforeExaltation:    (.none, "Sunday before the Exaltation"),
        .saturdayBeforeNativity:    (.none, "Saturday before the Nativity of Christ"),
        .sundayBeforeNativity:      (.none, "Sunday before the Nativity of Christ, of the Fathers"),
        .saturdayAfterNativity:     (.none, "Saturday after the Nativity of Christ"),
        .sundayAfterNativity:       (.none, "Sunday after Nativity"),
        .josephBetrothed:           (.noSign, "Saints Joseph the Betrothed, David the King, and James the Brother of the Lord"),
        .saturdayBeforeTheophany:   (.none, "Saturday before Theophany"),
        .sundayBeforeTheophany:     (.none, "Sunday before Theophany"),
        .saturdayAfterTheophany:    (.none, "Saturday after Theophany"),
        .sundayAfterTheophany:      (.none, "Sunday after Theophany"),
        .newMartyrsConfessorsOfRussia: (.vigil, "Holy New Martyrs and Confessors of Russia"),
        .allRussianSaints:          (.none,   "All Saints who have shown forth in the land of Russia"),
        .holyFathersSixCouncils:    (.none, "Commemoration of the Holy Fathers of the First Six Councils"),
        .holyFathersSeventhCouncil: (.none, "Commemoration of the Holy Fathers of the Seventh Ecumenical Council"),
        .synaxisMoscowSaints:       (.none, "Synaxis of all saints of Moscow"),
        .synaxisNizhnyNovgorodSaints:       (.none, "Synaxis of all saints of Nizhny Novgorod"),
        .saturdayOfFathers:         (.noSign, "Commemoration of all the saints, who showed forth in asceticism"),
        .lazarusSaturday:           (.none, "Saturday of Palms (Lazarus Saturday)"),
        .saturdayTrinity:           (.none, "Trinity Saturday; Commemoration of the Departed"),
        .saturdayOfDeparted:        (.none, "The Saturday of the Dead"),
        .demetriusSaturday:         (.none, "Demetrius Saturday: Commemoration of the Departed"),
        .radonitsa:                 (.none, "Radonitsa (Day of Rejoicing)"),
        .killedInAction:            (.none, "Commemoration of Fallen Soldiers"),
        .sundayOfPublicianAndPharisee:  (.none, "Sunday of the Publican and the Pharisee"),
        .sundayOfProdigalSon:           (.none, "Sunday of the Prodigal Son"),
        .sundayOfDreadJudgement:        (.none, "Sunday of the Dread Judgement"),
        .cheesefareSunday:              (.none, "Cheesefare Sunday (Forgiveness Sunday): Commemoration of the Expulsion of Adam from Paradise"),
        .sunday2AfterPascha:            (.none, "Second Sunday after Pascha. Thomas Sunday, or Antipascha"),
        .sunday3AfterPascha:            (.none, "Third Sunday after Pascha. Sunday of the Myrrhbearing Women"),
        .sunday4AfterPascha:            (.none, "Fourth Sunday after Pascha. Sunday of the Paralytic"),
        .sunday5AfterPascha:            (.none, "Fifth Sunday after Pascha. Sunday of the Samaritan Woman"),
        .sunday6AfterPascha:            (.none, "Sixth Sunday after Pascha. Sunday of the Blind Man"),
        .sunday7AfterPascha:            (.none, "Seventh Sunday after Pascha. Commemoration of the 318 Holy Fathers of the First Ecumenical Council (325)"),
    ]

    static public let feastIcon : [FeastType: String] = [
        .noSign: "nosign",
        .sixVerse: "sixverse",
        .doxology: "doxology",
        .polyeleos: "polyeleos",
        .vigil: "vigil",
        .great: "great"
    ]

    static let greatFeastCodes : [NameOfDay] = [.palmSunday, .pascha, .ascension, .pentecost, .nativityOfGod, .circumcision, .theophany, .meetingOfLord, .annunciation, .nativityOfJohn, .peterAndPaul, .transfiguration, .dormition, .beheadingOfJohn, .nativityOfTheotokos, .exaltationOfCross, .veilOfTheotokos, .entryIntoTemple]

    static func saveFeastDate(_ code: NameOfDay, _ year:Int) {
        if (code == .sundayBeforeNativity || code == .saturdayBeforeNativity) {
            // it is possible that there will be 2 Sundays or Saturdays before Nativity in a given year
            return;
        }
        
        var res = feastDates.compactMap() { (date, codes) in
            return codes.contains(code) && DateComponents(date:date).year == year ? date : nil
        }
        
        if res.count > 0 {
            dCache[DateCache(code, year)] = res[0]
        }
    }
    
    static public func d(_ code: NameOfDay) -> Date {
        return dCache[DateCache(code, currentYear)]!
    }
    
    static public func setDate(_ date: Date) {
        let dateComponents = DateComponents(date: date)
        currentYear = dateComponents.year
        currentWeekday = DayOfWeek(rawValue: dateComponents.weekday!)!
        currentDate = date
        
        if dCache[DateCache(.pascha, currentYear)] == nil {
            generateFeastDates(currentYear)
            generateFeastDescription(currentYear)
        }
    }

    static public func paschaDay(_ year: Int) -> Date {
        // http://calendar.lenacom.spb.ru/index.php
        let a = (19*(year%19) + 15) % 30
        let b = (2*(year%4) + 4*(year%7) + 6*a + 6) % 7

        return  ((a+b > 10) ? Date(a+b-9, 4, year) : Date(22+a+b, 3, year)) + 13.days
    }
    
    static func generateFeastDescription(_ year: Int) {
        let pascha = paschaDay(year)
        let greatLentStart = pascha-48.days
        let pentecost = d(.pentecost)
        
        var miscFeasts = [Date: [(FeastType, String)]]()
            
        miscFeasts += [
            greatLentStart+5.days:  [(.noSign, "Great Martyr Theodore the Recruit († c. 306)")],
            greatLentStart+6.days:  [(.none,   "Triumph of Orthodoxy")],
            greatLentStart+12.days: [(.none,   "Commemoration of the Departed")],
            greatLentStart+13.days: [(.noSign, "Saint Gregory Palamas, Archbishop of Thessalonica († c. 1360)"),
                                     (.none,   "Synaxis of all Venerable Fathers of the Kiev Caves")],
            greatLentStart+19.days: [(.none,   "Commemoration of the Departed")],
            greatLentStart+20.days: [(.none,   "Veneration of the Precious Cross")],
            greatLentStart+26.days: [(.none,   "Commemoration of the Departed")],
            greatLentStart+27.days: [(.noSign, "Venerable John Climacus of Sinai, Author of “the Ladder” († 649)")],
            greatLentStart+31.days: [(.none,   "Thursday of the Great Canon, with the Life of St. Mary of Egypt")],
            greatLentStart+33.days: [(.none,   "Saturday of the Akathist; Laudation of the Most Holy Theotokos")],
            greatLentStart+34.days: [(.none,   "Venerable Mary of Egypt")],
            pascha-6.days:          [(.none,   "Great Monday")],
            pascha-5.days:          [(.none,   "Great Tuesday")],
            pascha-4.days:          [(.none,   "Great Wednesday")],
            pascha-3.days:          [(.none,   "Great Thursday")],
            pascha-2.days:          [(.none,   "Great Friday")],
            pascha-1.days:          [(.none,   "Great Saturday")],
            pascha+2.days:          [(.noSign, "Iveron Icon of the Most Holy Theotokos (9th c.)")],
            pascha+5.days:          [(.none,   "Feast of the Life-Giving Spring of the Mother of God")],
            pascha+14.days:         [(.noSign, "St Joseph of Arimathea, and Nicodemus"),
                                     (.noSign, "Right-believing Tamara, Queen of Georgia († 1213)")],
            pascha+21.days:         [(.noSign, "Holy Martyr Abraham the Bulgar, Wonderworker of Vladimir († 1229)"),
                                     (.noSign, "Righteous Tabitha of Joppa (1st C)")],
            pascha+24.days:         [(.none,   "Mid-Pentecost"),
                                     (.none,   "Mozdok and Dubensky-Krasnohorská (17th C) Icons of the Mother of God")],
            pascha+27.days:         [(.none,   "Synaxis of New Martyrs of Butovo")],
            pascha+42.days:         [(.none,   "Chelnskoy and Pskov-Kiev Caves called “Tenderness” icons of the Mother of God")],
            pentecost+1.days:       [(.none,   "Day of the Holy Spirit"),
                                     (.none,   "Icons of the Mother of God “Tupichevsk” (1847) and “Cypriot” (392)")],
            pentecost+4.days:       [(.none,   "Icon of the Mother of God “Surety of Sinners” in Korets (1622)")],
            pentecost+7.days:       [(.none,   "Feast of All Saints"),
                                     (.none,   "Icons of the Mother of God: “the Softener of evil hearts” and “the Indestructible Wall”")],
            pentecost+14.days:      [(.none,   "All Saints of the Holy Mount Athos")],
        ]
        
        var beforeAfterFeasts :[Date: [(FeastType, String)]] = [
            pascha+38.days:         [(.none,   "Apodosis of Pascha")],
            pascha+40.days:         [(.none,   "Afterfeast of the Ascension")],
            pascha+41.days:         [(.none,   "Afterfeast of the Ascension")],
            pascha+42.days:         [(.none,   "Afterfeast of the Ascension")],
            pascha+43.days:         [(.none,   "Afterfeast of the Ascension")],
            pascha+44.days:         [(.none,   "Afterfeast of the Ascension")],
            pascha+45.days:         [(.none,   "Afterfeast of the Ascension")],
            pascha+46.days:         [(.none,   "Afterfeast of the Ascension")],
            pascha+47.days:         [(.none,   "Apodosis of the Ascension")],
            pentecost+6.days:       [(.none,   "Apodosis of Pentecost")]]
        
        beforeAfterFeasts += [
            Date(2, 1, year): [(.noSign, "Forefeast of the Nativity")],
            Date(3, 1, year): [(.noSign, "Forefeast of the Nativity")],
            Date(4, 1, year): [(.noSign, "Forefeast of the Nativity")],
            Date(5, 1, year): [(.noSign, "Forefeast of the Nativity")],
            Date(8, 1, year): [(.noSign, "Afterfeast of the Nativity of Our Lord")],
            Date(9, 1, year): [(.noSign, "Afterfeast of the Nativity of Our Lord")],
            Date(10, 1, year): [(.noSign, "Afterfeast of the Nativity of Our Lord")],
            Date(11, 1, year): [(.noSign, "Afterfeast of the Nativity of Our Lord")],
            Date(12, 1, year): [(.noSign, "Afterfeast of the Nativity of Our Lord")],
            Date(13, 1, year): [(.doxology, "Apodosis of the Nativity of Christ")],
            Date(15, 1, year): [(.noSign, "Forefeast of Theophany")],
            Date(16, 1, year): [(.noSign, "Forefeast of Theophany")],
            Date(17, 1, year): [(.noSign, "Forefeast of Theophany")],
            Date(20, 1, year): [(.noSign, "Afterfeast of the Theophany")],
            Date(21, 1, year): [(.noSign, "Afterfeast of the Theophany")],
            Date(22, 1, year): [(.noSign, "Afterfeast of the Theophany")],
            Date(23, 1, year): [(.noSign, "Afterfeast of the Theophany")],
            Date(24, 1, year): [(.noSign, "Afterfeast of the Theophany")],
            Date(25, 1, year): [(.noSign, "Afterfeast of the Theophany")],
            Date(26, 1, year): [(.noSign, "Afterfeast of the Theophany")],
            Date(27, 1, year): [(.noSign, "Apodosis of the Theophany")]]
        
        beforeAfterFeasts += [
            Date(18, 8, year): [(.sixVerse, "Forefeast of the Transfiguration of the Lord")],
            Date(20, 8, year): [(.noSign, "Afterfeast of the Transfiguration of the Lord")],
            Date(21, 8, year): [(.noSign, "Afterfeast of the Transfiguration of the Lord")],
            Date(22, 8, year): [(.noSign, "Afterfeast of the Transfiguration of the Lord")],
            Date(23, 8, year): [(.noSign, "Afterfeast of the Transfiguration of the Lord")],
            Date(24, 8, year): [(.noSign, "Afterfeast of the Transfiguration of the Lord")],
            Date(25, 8, year): [(.noSign, "Afterfeast of the Transfiguration of the Lord")],
            Date(26, 8, year): [(.doxology, "Apodosis of the Transfiguration of the Lord")],
            Date(27, 8, year): [(.sixVerse, "Forefeast of the Dormition of the Mother of God")],
            Date(29, 8, year): [(.noSign, "Afterfeast of the Dormition")],
            Date(30, 8, year): [(.noSign, "Afterfeast of the Dormition")],
            Date(31, 8, year): [(.noSign, "Afterfeast of the Dormition")],
            Date(1, 9, year): [(.noSign, "Afterfeast of the Dormition")],
            Date(2, 9, year): [(.noSign, "Afterfeast of the Dormition")],
            Date(3, 9, year): [(.noSign, "Afterfeast of the Dormition")],
            Date(4, 9, year): [(.noSign, "Afterfeast of the Dormition")],
            Date(5, 9, year): [(.doxology, "Apodosis of the Dormition")]]
        
        beforeAfterFeasts += [
            Date(20, 9, year): [(.sixVerse, "Forefeast of the Nativity of the Theotokos")],
            Date(22, 9, year): [(.noSign, "Afterfeast of the Nativity of the Theotokos")],
            Date(23, 9, year): [(.noSign, "Afterfeast of the Nativity of the Theotokos")],
            Date(24, 9, year): [(.noSign, "Afterfeast of the Nativity of the Theotokos")],
            Date(25, 9, year): [(.doxology, "Apodosis of the Nativity of the Theotokos")],
            Date(26, 9, year): [(.noSign, "Forefeast of the Exaltation of the Cross")],
            Date(28, 9, year): [(.noSign, "Afterfeast of the Exaltation of the Cross")],
            Date(29, 9, year): [(.noSign, "Afterfeast of the Exaltation of the Cross")],
            Date(30, 9, year): [(.noSign, "Afterfeast of the Exaltation of the Cross")],
            Date(1, 10, year): [(.noSign, "Afterfeast of the Exaltation of the Cross")],
            Date(2, 10, year): [(.noSign, "Afterfeast of the Exaltation of the Cross")],
            Date(3, 10, year): [(.noSign, "Afterfeast of the Exaltation of the Cross")],
            Date(4, 10, year): [(.doxology, "Apodosis of the Exaltation of the Cross")],
            Date(3, 12, year): [(.noSign, "Forefeast of the Entry of the Theotokos")],
            Date(5, 12, year): [(.noSign, "Afterfeast of the Entry of the Theotokos")],
            Date(6, 12, year): [(.noSign, "Afterfeast of the Entry of the Theotokos")],
            Date(7, 12, year): [(.noSign, "Afterfeast of the Entry of the Theotokos")],
            Date(8, 12, year): [(.doxology, "Apodosis of the Entry of the Theotokos")],
        ]
        
        dateFeastDescr += miscFeasts
        dateFeastDescr += beforeAfterFeasts
        
        // Sources: 
        // http://azbyka.ru/days/p-tablica-dnej-predprazdnstv-poprazdnstv-i-otdanij-dvunadesjatyh-nepodvizhnyh-i-podvizhnyh-gospodskih-prazdnikov
        
        let annunciation = Date(7,  4, year)
        var annunciationFeasts = [Date: [(FeastType, String)]]()
        
        switch (annunciation) {
        case d(.startOfYear) ..< d(.lazarusSaturday):
            annunciationFeasts = [
                annunciation-1.days: [(.sixVerse, "Forefeast of the Annunciation")],
                annunciation+1.days: [(.doxology, "Apodosis of the Annunciation")],
            ]
        case d(.lazarusSaturday):
            annunciationFeasts = [
                annunciation-1.days: [(.sixVerse, "Forefeast of the Annunciation")],
            ]

        default:
            break
        }
        
        dateFeastDescr += annunciationFeasts

        // АРХИМАНДРИТ ИОАНН (МАСЛОВ). КОНСПЕКТ ПО ЛИТУРГИКЕ ДЛЯ 3-го класса
        // Глава: СРЕТЕНИЕ ГОСПОДНЕ (2 февраля)

        let meetingOfLord = Date(15, 2, year)
        var meetingOfLordFeasts = [Date: [(FeastType, String)]]()
        
        meetingOfLordFeasts = [
            meetingOfLord-1.days: [(.sixVerse, "Forefeast of the Meeting of the Lord")],
        ]
        
        var lastDay = meetingOfLord
        
        switch (meetingOfLord) {
        case d(.startOfYear) ..< d(.sundayOfProdigalSon)-1.days:
            lastDay = meetingOfLord+7.days

        case d(.sundayOfProdigalSon)-1.days ... d(.sundayOfProdigalSon)+2.days:
            lastDay = d(.sundayOfProdigalSon)+5.days

        case d(.sundayOfProdigalSon)+3.days ..< d(.sundayOfDreadJudgement):
            lastDay = d(.sundayOfDreadJudgement) + 2.days
            
        case d(.sundayOfDreadJudgement) ... d(.sundayOfDreadJudgement)+1.days:
            lastDay = d(.sundayOfDreadJudgement) + 4.days

        case d(.sundayOfDreadJudgement)+2.days ... d(.sundayOfDreadJudgement)+3.days:
            lastDay = d(.sundayOfDreadJudgement) + 6.days

        case d(.sundayOfDreadJudgement)+4.days ... d(.sundayOfDreadJudgement)+6.days:
            lastDay = d(.cheesefareSunday)

        default:
            break
        }

        if (lastDay != meetingOfLord) {
            for afterfeastDay in DateRange(meetingOfLord+1.days, lastDay-1.days) {
                meetingOfLordFeasts += [
                    afterfeastDay: [(.noSign, "Afterfeast of the Meeting of the Lord")],
                ]
            }
            meetingOfLordFeasts += [
                lastDay: [(.doxology, "Apodosis of the Meeting of the Lord")]
            ]
        }

        dateFeastDescr += meetingOfLordFeasts

    }
    
    static public func nearestSundayAfter(_ date: Date) -> Date {
        let weekday = DateComponents(date:date).weekday!
        let sunOffset = (weekday == 1) ? 0 : 8-weekday
        return date + sunOffset.days
    }

    static public func nearestSundayBefore(_ date: Date) -> Date {
        let weekday = DateComponents(date:date).weekday!
        let sunOffset = (weekday == 1) ? 0 : weekday-1
        return date - sunOffset.days
    }
    
    static public func nearestSunday(_ date: Date) -> Date {
        let weekday = DayOfWeek(rawValue: DateComponents(date:date).weekday!)!
        
        switch (weekday) {
        case .sunday:
            return date
            
        case .monday, .tuesday, .wednesday:
            return nearestSundayBefore(date)
            
        default:
            return nearestSundayAfter(date)
        }
    }

    static func generateFeastDates(_ year: Int) {
        let pascha = paschaDay(year)
        let greatLentStart = pascha-48.days
        var movingFeasts = [Date: [NameOfDay]]()

        movingFeasts += [
            greatLentStart-22.days:                   [.sundayOfPublicianAndPharisee],
            greatLentStart-15.days:                   [.sundayOfProdigalSon],
            greatLentStart-9.days:                    [.saturdayOfDeparted],
            greatLentStart-8.days:                    [.sundayOfDreadJudgement],
            greatLentStart-2.days:                    [.saturdayOfFathers],
            greatLentStart-1.days:                    [.cheesefareSunday],
            greatLentStart:                           [.beginningOfGreatLent],
            pascha-8.days:                            [.lazarusSaturday],
            pascha-7.days:                            [.palmSunday],
            pascha:                                   [.pascha],
            pascha+7.days:                            [.sunday2AfterPascha],
            pascha+9.days:                            [.radonitsa],
            pascha+14.days:                           [.sunday3AfterPascha],
            pascha+21.days:                           [.sunday4AfterPascha],
            pascha+28.days:                           [.sunday5AfterPascha],
            pascha+35.days:                           [.sunday6AfterPascha],
            pascha+42.days:                           [.sunday7AfterPascha],
            pascha+39.days:                           [.ascension],
            pascha+48.days:                           [.saturdayTrinity],
            pascha+49.days:                           [.pentecost],
            pascha+57.days:                           [.beginningOfApostlesFast],
            pascha+63.days:                           [.allRussianSaints],
        ]
    
        var fixedFeasts : [Date: [NameOfDay]] = [
            Date(1,  1, year):   [.startOfYear],
            Date(6,  1, year):   [.eveOfNativityOfGod],
            Date(7,  1, year):   [.nativityOfGod],
            Date(8,  1, year):   [.synaxisTheotokos],
            Date(14, 1, year):   [.circumcision],
            Date(18, 1, year):   [.eveOfTheophany],
            Date(19, 1, year):   [.theophany],
            Date(20, 1, year):   [.synaxisForerunner],
            Date(15, 2, year):   [.meetingOfLord],
            Date(7,  4, year):   [.annunciation],
            Date(7,  7, year):   [.nativityOfJohn],
            Date(12, 7, year):   [.peterAndPaul],
            Date(14, 8, year):   [.beginningOfDormitionFast],
            Date(19, 8, year):   [.transfiguration],
            Date(28, 8, year):   [.dormition],
            Date(11, 9, year):   [.beheadingOfJohn],
            Date(21, 9, year):   [.nativityOfTheotokos],
            Date(27, 9, year):   [.exaltationOfCross],
            Date(14, 10, year):  [.veilOfTheotokos],
            Date(28, 11, year):  [.beginningOfNativityFast],
            Date(4,  12, year):  [.entryIntoTemple],
            Date(19, 12, year):  [.stNicholas],
            Date(31, 12, year):  [.endOfYear],
        ];
        
        fixedFeasts += [Date(9,  5, year): [.killedInAction]]

        feastDates += movingFeasts
        feastDates += fixedFeasts
        
        let exaltation = Date(27, 9, year)
        let exaltationWeekday = DateComponents(date: exaltation).weekday!
        feastDates += [exaltation + (8-exaltationWeekday).days: [.sundayAfterExaltation]]

        let exaltationSatOffset = (exaltationWeekday == 7) ? 7 : 7-exaltationWeekday
        feastDates += [exaltation + exaltationSatOffset.days: [.saturdayAfterExaltation]]
        
        let exaltationSunOffset = (exaltationWeekday == 1) ? 7 : exaltationWeekday-1
        feastDates += [exaltation - exaltationSunOffset.days: [.sundayBeforeExaltation]]

        feastDates += [exaltation - exaltationWeekday.days: [.saturdayBeforeExaltation]]

        let nativity = Date(7, 1, year)
        let nativityWeekday = DateComponents(date:nativity).weekday!
        let nativitySunOffset = (nativityWeekday == 1) ? 7 : (nativityWeekday-1)
        if nativitySunOffset != 7 {
            feastDates += [nativity - nativitySunOffset.days: [.sundayBeforeNativity]]
        }

        if nativityWeekday != 7 {
            feastDates += [nativity - nativityWeekday.days: [.saturdayBeforeNativity]]
        }

        feastDates += [nativity + (8-nativityWeekday).days: [.sundayAfterNativity]]
        
        if nativityWeekday == 1 {
            feastDates += [nativity + 1.days: [.josephBetrothed]]

        } else {
            feastDates += [nativity + (8-nativityWeekday).days: [.josephBetrothed]]
        }
        
        let nativitySatOffset = (nativityWeekday == 7) ? 7 : 7-nativityWeekday
        feastDates += [nativity + nativitySatOffset.days: [.saturdayAfterNativity]]
        
        let nativityNextYear = Date(7, 1, year+1)
        let nativityNextYearWeekday = DateComponents(date:nativityNextYear).weekday!
        var nativityNextYearSunOffset = (nativityNextYearWeekday == 1) ? 7 : (nativityNextYearWeekday-1)

        if nativityNextYearSunOffset == 7 {
            feastDates += [Date(31, 12, year): [.sundayBeforeNativity]]
        }
        
        if nativityNextYearWeekday == 7 {
            feastDates += [Date(31, 12, year): [.saturdayBeforeNativity]]
        }
        
        nativityNextYearSunOffset += 7
        feastDates += [nativityNextYear - nativityNextYearSunOffset.days: [.sundayOfForefathers]]
        
        let theophany = Date(19, 1, year)
        let theophanyWeekday = DateComponents(date:theophany).weekday!

        let theophanySunOffset = (theophanyWeekday == 1) ?  7 : (theophanyWeekday-1)
        let theophanySatOffset = (theophanyWeekday == 7) ? 7 : 7-theophanyWeekday

        feastDates += [theophany - theophanySunOffset.days: [.sundayBeforeTheophany]]
        feastDates += [theophany - theophanyWeekday.days: [.saturdayBeforeTheophany]]
        feastDates += [theophany + (8-theophanyWeekday).days: [.sundayAfterTheophany]]
        feastDates += [theophany + theophanySatOffset.days: [.saturdayAfterTheophany]]
        
        let demetrius = Date(8, 11, year)
        let demetriusWeekday = DateComponents(date: demetrius).weekday!
        
        feastDates += [demetrius - demetriusWeekday.days: [.demetriusSaturday]]
        feastDates += [nearestSunday(Date(7,2,year)): [.newMartyrsConfessorsOfRussia]]
        feastDates += [nearestSunday(Date(29, 7, year)): [.holyFathersSixCouncils]]
        feastDates += [nearestSunday(Date(24, 10, year)): [.holyFathersSeventhCouncil]]

        if Translate.language == "ru" {
            feastDates += [nearestSundayBefore(Date(8, 9, year)): [.synaxisMoscowSaints]]
            feastDates += [nearestSundayAfter(Date(8, 9, year)):  [.synaxisNizhnyNovgorodSaints]]
        }
        
        let start: Int = NameOfDay.startOfYear.rawValue
        let end: Int = NameOfDay.endOfYear.rawValue
        
        for index in start...end {
            let code = NameOfDay(rawValue: index)
            saveFeastDate(code!, year)
        }

    }

    static public func getGreatFeast(_ date: Date) -> NameOfDay? {
        if let feastCodes = feastDates[date] {
            for code in feastCodes {
                if greatFeastCodes.contains(code) {
                    return code
                }
            }
        }
        return nil
    }
    
    static public func getDayDescription(_ date: Date) -> [(FeastType, String)] {
        var result = [(FeastType, String)]()
        
        setDate(date)

        if let codes = feastDates[date] {
            for code in codes {
                if let feast = codeFeastDescr[code] {
                    result.append((feast.0, Translate.s(feast.1)))
                }
            }
        }

        result.sort { $0.0.rawValue < $1.0.rawValue }

        if let feasts = dateFeastDescr[date] {
            for feast in feasts {
                result.append((feast.0, Translate.s(feast.1)))
            }
        }
        
        return result
    }
    
    static public func getWeekDescription(_ date: Date) -> String? {
        setDate(date)

        let dayOfWeek = (currentWeekday == .sunday) ? "Sunday" : "Week"
        
        switch (date) {
        case d(.startOfYear) ..< d(.sundayOfPublicianAndPharisee):
            return  String(format: Translate.s("\(dayOfWeek) %@ after Pentecost"), Translate.stringFromNumber(((paschaDay(currentYear-1)+50.days) >> date)/7+1))
            
        case d(.sundayOfPublicianAndPharisee)+1.days ..< d(.sundayOfProdigalSon):
            return Translate.s("Week of the Publican and the Pharisee")

        case d(.sundayOfProdigalSon)+1.days ..< d(.sundayOfDreadJudgement):
            return Translate.s("Week of the Prodigal Son")

        case d(.sundayOfDreadJudgement)+1.days ..< d(.cheesefareSunday):
            return Translate.s("Week of the Dread Judgement")

        case d(.beginningOfGreatLent) ..< d(.palmSunday):
            return  String(format: Translate.s("\(dayOfWeek) %@ of Great Lent"), Translate.stringFromNumber((d(.beginningOfGreatLent) >> date)/7+1))
        
        case d(.palmSunday)+1.days ..< d(.pascha):
            return Translate.s("Holy Week")
            
        case d(.pascha)+1.days ..< d(.pascha)+7.days:
            return Translate.s("Bright Week")
            
        case d(.pascha)+8.days ..< d(.pentecost):
            let weekNum = (d(.pascha) >> date)/7+1
            return (currentWeekday == .sunday) ? nil : String(format: Translate.s("Week %@ after Pascha"), Translate.stringFromNumber(weekNum))
            
        case d(.pentecost)+1.days ... d(.endOfYear):
            return  String(format: Translate.s("\(dayOfWeek) %@ after Pentecost"), Translate.stringFromNumber(((d(.pentecost)+1.days) >> date)/7+1))
            
        default: return nil
        }
        
    }
    
    static public func getTone(_ date: Date) -> Int? {
        func tone(dayNum: Int) -> Int {
            let reminder = (dayNum/7) % 8
            return (reminder == 0) ? 8 : reminder
        }
        
        setDate(date)
        
        switch (date) {
        case d(.startOfYear) ..< d(.palmSunday):
            return tone(dayNum: paschaDay(currentYear-1) >> date)
            
        case d(.pascha)+7.days ... d(.endOfYear):
            return tone(dayNum: d(.pascha) >> date)
            
        default: return nil
        }
    }
    
    static public func getToneDescription(_ date: Date) -> String? {
        if let tone = getTone(date) {
            return String(format: Translate.s("Tone %@"), Translate.stringFromNumber(tone))

        } else {
            return nil
        }
    }
}

public typealias Cal = ChurchCalendar

