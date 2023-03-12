import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderSuccessful extends StatefulWidget
{
  final String invoiceNo;
  const OrderSuccessful({Key? key, required this.invoiceNo}) : super(key: key);

  @override
  State<OrderSuccessful> createState() => _OrderSuccessfulState();
}

class _OrderSuccessfulState extends State<OrderSuccessful>
{
  @override
  Widget build(BuildContext context)
  {
    return WillPopScope(

      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return true;
      },

      child: Material(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          margin: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20,),

              Text("Order Successful", style: GoogleFonts.comfortaa(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 30,
              ),),

              const SizedBox(height: 20,),

              Text("Your invoice no. is: ${widget.invoiceNo}", style: GoogleFonts.andikaNewBasic(),),

            ],
          ).p12(),

        )
      ),
    );
  }
}
