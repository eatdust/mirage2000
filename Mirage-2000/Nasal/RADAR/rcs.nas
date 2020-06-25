#
# Radar Cross-section calculation for radars
# 
# Main author: Pinto
#
# License: GPL 2
#
# The file vector.nas needs to be available in namespace 'vector'.
#

var test = func (echoHeading, echoPitch, echoRoll, bearing, frontRCS) {
  var myCoord = geo.aircraft_position();
  var echoCoord = geo.Coord.new(myCoord);
  echoCoord.apply_course_distance(bearing, 1000);#1km away
  echoCoord.set_alt(echoCoord.alt()+1000);#1km higher than me
  print("RCS final: "~getRCS(echoCoord, echoHeading, echoPitch, echoRoll, myCoord, frontRCS));
};

var rcs_database = {
    #REVISION: 2020/06/25
    "default":                  150,    #default value if target's model isn't listed
    #OPRF Fleet and related
    "A-10":                     23.5,
    "A-10-model":               23.5,
    "A-10-modelB":              23.5,
    "B-1B":                     10,
    "f-14b":                    12,     #guess
    "F-14D":                    12,     #guess
    "f-14b-bs":                 0.0001, #low so it doesn't show up on radar
    "F-15C":                    10,     #low end of sources
    "F-15D":                    11,     #low end of sources
    "f15-bs":                   0.0001, #low so it doesn't show up on radar
    "YF-16":                    5,      #higher because earlier blocks had larger RCS
    "F-16":                     2,      #average
    "F-16CJ":                   2,      #average
    "f16":                      2,      #average
    "JA37-Viggen":              3,      #close to actual
    "AJ37-Viggen":              3,      #close to actual
    "AJS37-Viggen":             3,      #close to actual
    "JA37Di-Viggen":            3,      #close to actual
    "MiG-29":                   6,      #guess
    "Mig-29":                   6,      #guess
    "m2000-5":                  1.5,    #average
    "m2000-5B":                 1.5,    #average
    "m2000-5B-backseat":        0.0001, low so it doesn't show up on radar
    "SU-27":                    15,     #some data shows 22
    "J-11A":                    15,     #same as Su-27
    "Jaguar-GR1":               6,      #guess
    "Jaguar-GR3":               6,      #guess
    "jaguar":                   6,      #guess
    "Blackbird-SR71A":          0.25,
    "Blackbird-SR71B":          0.30,
    "Blackbird-SR71A-BigTail":  0.30,
    "MiG-21bis":                3.5,
    "MiG-21MF-75":              3.5,
    "MiG-21Bison":              3.5,
    "MQ-9":                     0.5,    #guess
    "KC-137R":                  90,     #guess
    "KC-137R-RT":               90,     #guess
    "C-137R":                   85,     #guess
    "RC-137R":                  95,     #guess
    "EC-137R":                  100,    #guess
    "E-8R":                     95,     #guess
    "KC-10A":                   90,     #guess
    "KC-10A-GE":                90,     #guess
    "KC-30A":                   75,     #guess
    "Voyager-KC":               75,     #guess
    "707":                      85,     #guess
    "707-TT":                   90,     #guess
    "EC-137D":                  100,    #guess
    "onox-tanker":              90,     #guess
    #OPRF Assets
    "depot":                    170,    #estimated with blender
    "struct":                   170,    #estimated with blender
    "rig":                      500,    #guess
    "point":                    120,    #guess
    "buk-m2":                   7,      #estimated with blender
    "s-300":                    17,     
    "truck":                    1.5,    #estimated with blender
    "missile_frigate":          450,    #estimated with blender
    "frigate":                  450,    #estimated with blender
    "USS-NORMANDY":             450,    #estimated with blender
    "USS-LakeChamplain":        450,    #estimated with blender
    "USS-OliverPerry":          450,    #estimated with blender
    "USS-SanAntonio":           450,    #estimated with blender
    "tower":                    60,     #estimated with blender
    "gci":                      50,     #guess
    "QF-4E":                    2,      #actual: 6
    #Helicopters
    "ch53e":                    25,     #guess
    "Mil-Mi-8":                 30,     #guess
    "CH47":                     20,     #guess
    "mi24":                     25,     #guess
    "SH-60J":                   10,     #guess
    "UH-60J":                   10,     #guess
    "uh60_Blackhawk":           10,     #guess
    "tigre":                    5,      #guess
    "uh1":                      16,     #guess
    "212-TwinHuey":             14,     #guess
    "412-Griffin":              14,     #guess
    "AH-1W":                    7,      #guess
    "rah-66":                   0.8,    #wild guess
    #Stealth
    "b2-spirit":                0.001,  #actual: 0.0001
    "B-2A":                     0.001,  #actual: 0.0001
    "F-22-Raptor":              0.001,  #actual: 0.0001
    "F-35A":                    0.0005,
    "F-35B":                    0.0005,
    "F-35C":                    0.0005,
    "F-117":                    0.003,
    "T-50":                     0.5,    #low end of sources
    "u-2s":                     0.01,
    "U-2S-model":               0.01,
    #Misc
    "Typhoon":                  0.5,
    "EF2000":                   0.5,
    "brsq":                     1.5,    #average (multiple sources)
    "FA-18C_Hornet":            3.5,    #later Blocks have 1
    "FA-18D_Hornet":            3.5,
    "daVinci_SU-34":            8,      #should be less
    "Su-34":                    8,      #should be less
    "SU-37":                    8,      #wild guess
    "F-5E-TigerII":             4,      #close to actual
    "F-5ENinja":                4,      #close to actual
    "f-20A":                    2.5,    #low end of sources
    "f-20C":                    2.5,
    "f-20prototype":            2.5,
    "f-20bmw":                  2.5,
    "f-20-dutchdemo":           2.5,
    "MiG-15bis":                6,     #guess
    "G91-R1B":                  6,     #guess
    "Su-25":                    7,     #guess
    "c130":                     70,     #guess
};

var prevVisible = {};

var inRadarRange = func (contact, myRadarDistance_nm, myRadarStrength_rcs) {
    return rand() < 0.05?rcs.isInRadarRange(contact, myRadarDistance_nm, myRadarStrength_rcs) == 1:rcs.wasInRadarRange(contact, myRadarDistance_nm, myRadarStrength_rcs);
}

var wasInRadarRange = func (contact, myRadarDistance_nm, myRadarStrength_rcs) {
    var sign = contact.get_Callsign();
    if (sign != nil and contains(prevVisible, sign)) {
        return prevVisible[sign];
    } else {
        return isInRadarRange(contact, myRadarDistance_nm, myRadarStrength_rcs);
    }
}

var isInRadarRange = func (contact, myRadarDistance_nm, myRadarStrength_rcs) {
    if (contact != nil and contact.get_Coord() != nil) {
        var value = 1;
        call(func {value = targetRCSSignal(contact.get_Coord(), contact.get_model(), contact.get_heading(), contact.get_Pitch(), contact.get_Roll(), geo.aircraft_position(), myRadarDistance_nm*NM2M, myRadarStrength_rcs)},nil, var err = []);
        if (size(err)) {
            foreach(line;err) {
                print(line);
            }
            # open radar for one will make this happen.
            return value;
        }
        prevVisible[contact.get_Callsign()] = value;
        return value;
    }
    return 0;
};

#most detection ranges are for a target that has an rcs of 5m^2, so leave that at default if not specified by source material

var targetRCSSignal = func(targetCoord, targetModel, targetHeading, targetPitch, targetRoll, myCoord, myRadarDistance_m, myRadarStrength_rcs = 5) {
    #print(targetModel);
    var target_front_rcs = nil;
    if ( contains(rcs_database,targetModel) ) {
        target_front_rcs = rcs_database[targetModel];
    } else {
        return 1;
        target_front_rcs = rcs_database["default"];
    }
    var target_rcs = getRCS(targetCoord, targetHeading, targetPitch, targetRoll, myCoord, target_front_rcs);
    var target_distance = myCoord.direct_distance_to(targetCoord);

    # standard formula
    var currMaxDist = myRadarDistance_m/math.pow(myRadarStrength_rcs/target_rcs, 1/4);
    return currMaxDist > target_distance;
}

var getRCS = func (echoCoord, echoHeading, echoPitch, echoRoll, myCoord, frontRCS) {
    var sideRCSFactor  = 2.50;
    var rearRCSFactor  = 1.75;
    var bellyRCSFactor = 3.50;
    #first we calculate the 2D RCS:
    var vectorToEcho   = vector.Math.eulerToCartesian2(myCoord.course_to(echoCoord), vector.Math.getPitch(myCoord,echoCoord));
    var vectorEchoNose = vector.Math.eulerToCartesian3X(echoHeading, echoPitch, echoRoll);
    var vectorEchoTop  = vector.Math.eulerToCartesian3Z(echoHeading, echoPitch, echoRoll);
    var view2D         = vector.Math.projVectorOnPlane(vectorEchoTop,vectorToEcho);
    #print("top  "~vector.Math.format(vectorEchoTop));
    #print("nose "~vector.Math.format(vectorEchoNose));
    #print("view "~vector.Math.format(vectorToEcho));
    #print("view2D "~vector.Math.format(view2D));
    var angleToNose    = geo.normdeg180(vector.Math.angleBetweenVectors(vectorEchoNose, view2D)+180);
    #print("horz aspect "~angleToNose);
    var horzRCS = 0;
    if (math.abs(angleToNose) <= 90) {
      horzRCS = extrapolate(math.abs(angleToNose), 0, 90, frontRCS, sideRCSFactor*frontRCS);
    } else {
      horzRCS = extrapolate(math.abs(angleToNose), 90, 180, sideRCSFactor*frontRCS, rearRCSFactor*frontRCS);
    }
    #print("RCS horz "~horzRCS);
    #next we calculate the 3D RCS:
    var angleToBelly    = geo.normdeg180(vector.Math.angleBetweenVectors(vectorEchoTop, vectorToEcho));
    #print("angle to belly "~angleToBelly);
    var realRCS = 0;
    if (math.abs(angleToBelly) <= 90) {
      realRCS = extrapolate(math.abs(angleToBelly),  0,  90, bellyRCSFactor*frontRCS, horzRCS);
    } else {
      realRCS = extrapolate(math.abs(angleToBelly), 90, 180, horzRCS, bellyRCSFactor*frontRCS);
    }
    return realRCS;
};

var extrapolate = func (x, x1, x2, y1, y2) {
    return y1 + ((x - x1) / (x2 - x1)) * (y2 - y1);
};

var getAspect = func (echoCoord, myCoord, echoHeading) {# ended up not using this
    # angle 0 deg = view of front
    var course = echoCoord.course_to(myCoord);
    var heading_offset = course - echoHeading;
    return geo.normdeg180(heading_offset);
};
