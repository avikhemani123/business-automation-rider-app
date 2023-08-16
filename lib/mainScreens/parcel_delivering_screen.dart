import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riders_app2/mainScreens/home_screen.dart';
import '../assistantMethods/get_current_location.dart';
import '../global/global.dart';
import '../maps/map_utils.dart';
import '../splashScreen/splash_screen.dart';


class ParcelDeliveringScreen extends StatefulWidget
{
  String? purchaserId;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? sellerId;
  String? getOrderId;

  ParcelDeliveringScreen({
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.sellerId,
    this.getOrderId,
  });


  @override
  _ParcelDeliveringScreenState createState() => _ParcelDeliveringScreenState();
}




class _ParcelDeliveringScreenState extends State<ParcelDeliveringScreen>
{
  String orderTotalAmount = "";

  confirmParcelHasBeenDelivered(getOrderId, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {
    String riderNewTotalEarningAmount = (double.parse(previousRiderEarnings) + double.parse(perParcelDeliveryAmount)).toString();

    // String riderNewTotalEarningAmount = ((double.parse(previousRiderEarnings)) + (double.parse(perParcelDeliveryAmount)));

    // String riderNewTotalEarningAmount = previousEarnings +  perParcelDeliveryAmount;

    // double riderNewTotalEarningAmount = 90;


    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderId).update({
      "status": "ended",
      "address": completeAddress,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "earnings": perParcelDeliveryAmount, //pay per parcel delivery amount
    }).then((value)
    {
      // FirebaseFirestore.instance.collection("riders")
      // .doc(sharedPreferences!.getString("uid"))
      // .get()
      // .then((value) => {
      //   print(value);
      //
      //
      //
      //
      // })

      print("riderNewTotalEarningAmount$riderNewTotalEarningAmount\t\t previousRiderEarnings$previousRiderEarnings\t\t\t perParcelDeliveryAmount$perParcelDeliveryAmount");
      // print(perParcelDeliveryAmount);
      // print(previousRiderEarnings);


      FirebaseFirestore.instance
          .collection("riders")
          .doc(sharedPreferences!.getString("uid"))
          .update(
          {
            "earnings": riderNewTotalEarningAmount, //total earnings amount of rider
          });
    }).then((value)
    {
      print("previousEarnings$previousEarnings\t\t orderTotalAmount$orderTotalAmount\t\t\t perParcelDeliveryAmount$perParcelDeliveryAmount");
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerId)
          .update(
          {
            // "earnings":800,
            "earnings": (double.parse(orderTotalAmount) + double.parse(previousEarnings)).toString(), //total earnings amount of seller
          });
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("users")
          .doc(purchaserId)
          .collection("orders")
          .doc(getOrderId).update(
          {
            "status": "ended",
            "riderUID": sharedPreferences!.getString("uid"),
          });
    });


    Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));

  }

  getOrderTotalAmount()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.getOrderId)
        .get()
        .then((snap)
    {
      orderTotalAmount = snap.data()!["totalAmount"].toString();
      widget.sellerId = snap.data()!["sellerUID"].toString();
    }).then((value)
    {
      getSellerData();
    });
  }

  getSellerData()
  {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerId)
        .get().then((snap)
    {
      previousEarnings = snap.data()!["earnings"].toString();
      // print(previousEarnings ,"okokokokokok");
      print("previousEarnings$previousEarnings");

    });
  }

  @override
  void initState() {
    super.initState();

    //rider location update
    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();

    getOrderTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            "images/confirm2.png",
          ),

          const SizedBox(height: 5,),

          GestureDetector(
            onTap: ()
            {
              //show location from rider current location towards seller location
              print("position!.latitude$position.latitude\t\t position!.longitude$position!.longitude\t\t\t widget.purchaserLat$widget.purchaserLat");

              // MapUtils.lauchMapFromSourceToDestination(position!.latitude, position!.longitude, widget.purchaserLat, widget.purchaserLng);
              MapUtils.buildGoogleMapsURL(position!.latitude, position!.longitude, widget.purchaserLat, widget.purchaserLng);

            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  'images/restaurant.png',
                  width: 50,
                ),

                const SizedBox(width: 7,),

                Column(
                  children: const [
                    SizedBox(height: 12,),

                    Text(
                      "Show Delivery Drop-off Location",
                      style: TextStyle(
                        fontFamily: "Signatra",
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

          const SizedBox(height: 40,),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: ()
                {
                  //rider location update
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from seller
                  confirmParcelHasBeenDelivered(
                      widget.getOrderId,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan,
                          Colors.amber,
                        ],
                        begin:  FractionalOffset(0.0, 0.0),
                        end:  FractionalOffset(1.0, 0.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      )
                  ),
                  width: MediaQuery.of(context).size.width - 90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Order has been Delivered - Confirm",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
