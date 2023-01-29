import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order>
{

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _location = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context)
  {
    return Material(
      child: Form(
        key: _key,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text("Thank you for \nmaking a purchase", style: GoogleFonts.comfortaa(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 30,
            ),),

            const SizedBox(height: 25,),

            Text("Enter your Location:", style: GoogleFonts.andikaNewBasic(),),

            const SizedBox(height: 5,),

            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              minLines: 3,

              controller: _location,

              validator: (value)
              {
                if (value!.isEmpty)
                {
                  return "Please enter your location";
                }
                return null;
              },

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),


            ),

            const SizedBox(height: 20,),

            Align(
              alignment: Alignment.centerRight,

              child: SizedBox(
                height: 40,
                child: IconButton(
                  onPressed: () async
                  {
                    if (_key.currentState!.validate())
                    {

                      Map <String, dynamic> location =
                      {
                        "Location" : _location.text.toString(),
                      };

                       FirebaseFirestore.instance.collection('Customers')
                           .doc(user?.email!)
                           .update(location);



                    }

                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Vx.blue900,
                    ),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),

                  icon: Image.network('https://cdn-icons-png.flaticon.com/128/3007/3007303.png',),

                ),
              ),
            ),


          ],
        ).p24().py32(),
      ),

    );
  }
}
