import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/db/coupons.dart';
import 'package:xenobot/db/kiosks.dart';
import 'package:xenobot/db/orders.dart';
import 'package:xenobot/db/users.dart';
import 'package:xenobot/models/kiosk.dart';
import 'package:xenobot/models/recipe.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/providers/kiosk_provide.dart';
import 'package:xenobot/providers/user_provider.dart';

import 'order_preparing.dart';

class CheckoutPage extends StatefulWidget {
  final int price;
  final String name;
  final String image;
  final List bases;
  final List flavours;
  final List sweetners;
  final RecipeModel recipe;
  const CheckoutPage({
    super.key,
    required this.price,
    required this.name,
    required this.image,
    required this.sweetners,
    required this.flavours,
    required this.bases,
    required this.recipe,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    tax = widget.price * (5 / 100);
    total = (widget.price + tax) - discount;
  }

  TextEditingController couponName = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Razorpay razorpay = Razorpay();
  double discount = 0;
  double tax = 0.0;
  double total = 0.0;
  bool start = true;

  @override
  Widget build(BuildContext context) {
    if (start) {
      var user = Provider.of<UserProvider>(context);
      user.updateUserData();
      start = false;
    }
    return Scaffold(
      backgroundColor: bgC,
      appBar: appbar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: TextFormField(
                controller: couponName,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff6f2f2),
                  label: const Text(
                    "Coupon",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              trailing: MaterialButton(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: elementsC,
                onPressed: () async {
                  int discountValue =
                      await CouponServices().getByName(couponName.text);
                  if (discountValue != 0) {
                    setState(() {
                      discount = discountValue.toDouble();
                      couponName.clear();
                    });
                    Fluttertoast.showToast(
                        msg: "Coupon Applied Successfully",
                        backgroundColor: Colors.green);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Coupon Not Found", backgroundColor: Colors.red);
                    setState(() {
                      couponName.clear();
                    });
                  }
                },
                child: Text(
                  "Apply",
                  style: TextStyle(
                    color: elementsC.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-6.0, -6.0),
                      blurRadius: 16.0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(6.0, 6.0),
                      blurRadius: 16.0,
                    ),
                  ],
                  color: const Color(0xFFEFEEEE),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Payment Details\n\n",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const TextSpan(
                          text: "Subtotal: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: "₹${widget.price}/-\n",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        const TextSpan(
                          text: "Tax(5%): ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: "₹$tax/-\n",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        const TextSpan(
                          text: "Discount: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: "₹$discount/-\n",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        const TextSpan(
                          text: "---------------------------\n",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const TextSpan(
                          text: "Total: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: "₹$total/-\n",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MaterialButton(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: elementsC,
                onPressed: () {
                  var user = Provider.of<UserProvider>(context, listen: false);
                  var kiosk =
                      Provider.of<KioskProvider>(context, listen: false);
                  if (user.userModel.paymentMethod == PaymentMethod.online) {
                    var options = {
                      'key': 'rzp_test_2Eh5LSk1v3ujdn',
                      'amount': "${total.toString()}00",
                      'name': user.userModel.name,
                      'description': widget.name,
                      'prefill': {
                        'email': user.userModel.email,
                      }
                    };
                    razorpay.open(options);
                  } else if (user.userModel.paymentMethod ==
                          PaymentMethod.wallet &&
                      user.userModel.wallet > total) {
                    OrderServices().create(
                      uid: user.userModel.id,
                      itemImage: widget.image,
                      itemName: widget.name,
                      total: total,
                      tax: tax,
                      discount: discount.toDouble(),
                      subtotal: widget.price.toDouble(),
                      status: OrderStatus.success.name,
                      paymentMethod: PaymentMethod.wallet,
                      context: context,
                    );
                    List basesList = [];
                    List sweetnersList = [];
                    List flavoursList = [];
                    KioskModel kioskModel = kiosk.kioskModel;
                    for (int i = 0; i < kioskModel.bases.length; i++) {
                      basesList.add(kioskModel.bases[i] - widget.bases[i]);
                    }
                    for (int i = 0; i < kioskModel.sweetners.length; i++) {
                      sweetnersList
                          .add(kioskModel.sweetners[i] - widget.sweetners[i]);
                    }
                    for (int i = 0; i < kioskModel.flavours.length; i++) {
                      flavoursList
                          .add(kioskModel.flavours[i] - widget.flavours[i]);
                    }
                    KioskServices().updateIngredients(
                        id: kioskModel.id,
                        bases: basesList,
                        flavours: flavoursList,
                        sweetners: sweetnersList);
                    navigate(
                        type: PageType.replace,
                        context: context,
                        page: OrderPreparingPage(
                          recipe: widget.recipe,
                        ));
                    user.updateUserData();
                  } else {
                    debugPrint(total.toStringAsFixed(2).replaceAll(".", ""));
                    var options = {
                      'key': 'rzp_test_2Eh5LSk1v3ujdn',
                      'amount': total.toStringAsFixed(2).replaceAll(".", ""),
                      'name': user.userModel.name,
                      'description': widget.name,
                      'prefill': {
                        'email': user.userModel.email,
                      }
                    };
                    Fluttertoast.showToast(
                        msg:
                            "Insufficient wallet balance. Switching to online payment method.",
                        backgroundColor: Colors.red);
                    razorpay.open(options);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10, bottom: 10),
                  child: Text(
                    "Buy Now",
                    style: TextStyle(
                      fontSize: 20,
                      color: elementsC.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    var user = Provider.of<UserProvider>(context, listen: false);
    OrderServices().create(
      uid: user.userModel.id,
      itemImage: widget.image,
      itemName: widget.name,
      total: total,
      tax: tax,
      discount: discount.toDouble(),
      subtotal: widget.price.toDouble(),
      status: OrderStatus.success.name,
      paymentMethod: PaymentMethod.online,
      context: context,
    );
    final kiosk = Provider.of<KioskProvider>(context, listen: false);
    List basesList = [];
    List sweetnersList = [];
    List flavoursList = [];
    KioskModel kioskModel = kiosk.kioskModel;
    for (int i = 0; i < kioskModel.bases.length; i++) {
      basesList.add(widget.bases[i] - kioskModel.bases[i]);
    }
    for (int i = 0; i < kioskModel.sweetners.length; i++) {
      sweetnersList.add(widget.sweetners[i] - kioskModel.sweetners[i]);
    }
    for (int i = 0; i < kioskModel.flavours.length; i++) {
      flavoursList.add(widget.flavours[i] - kioskModel.flavours[i]);
    }
    KioskServices().updateIngredients(
        id: kioskModel.id,
        bases: kioskModel.bases,
        flavours: kioskModel.flavours,
        sweetners: kioskModel.sweetners);
    navigate(
        type: PageType.replace,
        context: context,
        page: OrderPreparingPage(
          recipe: widget.recipe,
        ));
  }

  void handlePaymentError(PaymentFailureResponse response) {
    var user = Provider.of<UserProvider>(context, listen: true);
    OrderServices().create(
        uid: user.userModel.id,
        itemImage: widget.image,
        itemName: widget.name,
        total: total,
        tax: tax,
        discount: discount.toDouble(),
        subtotal: widget.price.toDouble(),
        status: OrderStatus.success.name,
        paymentMethod: PaymentMethod.online,
        context: context);
    navigate(
        type: PageType.replace,
        context: context,
        page: OrderPreparingPage(recipe: widget.recipe));
    Fluttertoast.showToast(
        msg: "Paymtment Failed", backgroundColor: Colors.red);
  }
}
