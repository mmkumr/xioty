import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xenobot/db/coupons.dart';
import 'package:xenobot/models/coupon.dart';
import 'package:xenobot/pages/coupons.dart';

import '../commons.dart';

class NewCouponsPage extends StatefulWidget {
  final CouponModel? coupon;
  const NewCouponsPage({super.key, this.coupon});

  @override
  State<NewCouponsPage> createState() => _NewCouponsPageState();
}

class _NewCouponsPageState extends State<NewCouponsPage> {
  @override
  void initState() {
    if (widget.coupon != null) {
      couponName.text = widget.coupon!.name;
      couponValue.text = widget.coupon!.value.toString();
      setState(() {});
    }
    super.initState();
  }

  TextEditingController couponName = TextEditingController();
  TextEditingController couponValue = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: const Text("New Coupons"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  controller: couponName,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xfff6f2f2),
                    label: const Text(
                      "Coupon Text",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: couponValue,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xfff6f2f2),
                    label: const Text(
                      "value in ₹",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    return null;
                  },
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
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      CouponServices couponServices = CouponServices();
                      if (widget.coupon != null) {
                        await couponServices.update(
                            name: couponName.text,
                            value: int.parse(couponValue.text),
                            id: widget.coupon!.id);
                      } else {
                        await couponServices.create(
                          name: couponName.text,
                          value: int.parse(couponValue.text),
                        );
                      }
                      if (!context.mounted) return;
                      navigate(
                          type: PageType.replace,
                          context: context,
                          page: const CouponsPage());
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10, bottom: 10),
                    child: Text(
                      "Save",
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
      ),
    );
  }
}
