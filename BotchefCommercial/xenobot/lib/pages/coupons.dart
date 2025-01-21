import 'package:flutter/material.dart';
import 'package:xenobot/db/coupons.dart';
import 'package:xenobot/models/coupon.dart';

import '../commons.dart';
import 'coupon.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  @override
  void didChangeDependencies() {
    getCoupon();
    super.didChangeDependencies();
  }

  List<CouponModel> coupons = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coupons"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: MaterialButton(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: elementsC,
                onPressed: () {
                  navigate(
                      type: PageType.replace,
                      context: context,
                      page: const NewCouponsPage());
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Add Coupons",
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
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: coupons.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: ListTile(
                          onTap: () {
                            navigate(
                                type: PageType.replace,
                                context: context,
                                page: NewCouponsPage(
                                  coupon: coupons[index],
                                ));
                          },
                          tileColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          leading: Text(
                            "₹${coupons[index].value}",
                            softWrap: true,
                          ),
                          title: Text(
                            coupons[index].name,
                            softWrap: true,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              CouponServices().delete(id: coupons[index].id);
                              coupons.removeAt(index);
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  getCoupon() async {
    coupons = await CouponServices().getAll();
    debugPrint(coupons[0].id);
    setState(() {});
  }
}
