import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);


  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>
{
  @override
  Widget build(BuildContext context)
  {
    return Page1();
  }
}

class Page1 extends StatefulWidget
{
  const Page1({Key? key}) : super(key: key);

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1>
{
  GlobalKey<FormState> _sign_up_key1 = GlobalKey<FormState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = new TextEditingController();
  TextEditingController _otp = new TextEditingController();
  late File display_photo;
  bool isImageUploaded = false;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        leading: BackButton(),
      ),

      body: SingleChildScrollView(

        child: Container(
          width: MediaQuery.of(context).size.width,

          padding: const EdgeInsets.symmetric(horizontal: 15),
          margin: const EdgeInsets.all(25),

          child: Center(

            child: Form(
              key: _sign_up_key1,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text("Create an Account", style: GoogleFonts.comfortaa(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 30,
                  ),),

                  const SizedBox(height: 20,),

                  Center(
                    child: Container(

                      margin: EdgeInsets.all(25),
                      padding: EdgeInsets.all(30),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(width: 2, color: Colors.pinkAccent),
                      ),

                      child: InkWell(

                        onTap: ()
                        async
                        {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                          );

                          if (result != null)
                          {
                            setState(()
                            {
                              display_photo = File(result.files.single.path!);
                              isImageUploaded = true;
                            });
                          }
                        },

                        child: isImageUploaded ? Image.file(display_photo, height: 80, width: 80,) :
                        Icon(Icons.add_a_photo, size: 45, color: Colors.pink,),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20,),

                  Text("Enter your Name:", style: GoogleFonts.andikaNewBasic(),),

                  TextFormField(
                    keyboardType: TextInputType.name,

                    controller: _name,

                    validator: (value)
                    {
                      if (value!.isEmpty)
                      {
                        return "Please enter your name";
                      }
                    },

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),


                  ),

                  const SizedBox(height: 20,),

                  Row(

                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      SizedBox(
                        width: (MediaQuery.of(context).size.width)/2,

                        child: Column(
                          children: [

                            Text("Enter your phone number:", style: GoogleFonts.andikaNewBasic(),),

                            TextFormField(
                              keyboardType: TextInputType.phone,

                              controller: _phone,

                              validator: (value)
                              {
                                if (value!.isEmpty)
                                {
                                  return "Empty field";
                                }
                                else if (!RegExp(r'^([+0][1-9])?[0-9]{10,12}$').hasMatch(value))
                                {
                                  return "Invalid phone number";
                                }
                              },

                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),

                          ],
                        ),
                      ),

                      SizedBox(
                        width: (MediaQuery.of(context).size.width)/5,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text("OTP:", style: GoogleFonts.andikaNewBasic(),),

                            TextFormField(
                              keyboardType: TextInputType.number,

                              controller: _otp,

                              validator: (value)
                              {
                                if (value!.isEmpty)
                                {
                                  return "Empty \nfield";
                                }
                                // OTP
                              },

                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50,),

                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async
        {
          if (_sign_up_key1.currentState!.validate())
            {
              // Go to next page
              Navigator.push(context, MaterialPageRoute(builder: (context)
              {
                return Page2(
                  name : _name,
                  phone : _phone,
                  display_photo : isImageUploaded ? display_photo : null,
                );
              }));

            }
        },

        icon: Icon(Icons.arrow_forward_ios_outlined),
        backgroundColor: Colors.pink,
        hoverColor: Vx.pink600,
        elevation: 10.0,
        label: Text("Next", style: GoogleFonts.openSans(),),
      ),

    );
  }
}


class Page2 extends StatefulWidget
{
  final name;
  final phone;
  final display_photo;

  const Page2({Key? key, this.name, this.phone, this.display_photo}) : super(key: key);


  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2>
{
  GlobalKey<FormState> _sign_up_key2 = GlobalKey<FormState>();

  TextEditingController _email = TextEditingController();
  TextEditingController _password = new TextEditingController();

  String signUpMessage = '';

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),

      body: Form(

        key: _sign_up_key2,

        child: SingleChildScrollView(
          child: Container(

            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.all(25),

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Welcome ${widget.name.text.toString()}", style: GoogleFonts.comfortaa(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 30,
                  ),),

                  const SizedBox(height: 20,),

                  Text("Enter your email:", style: GoogleFonts.andikaNewBasic(),),

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,

                    controller: _email,

                    validator: (value)
                    {
                      if (value!.isEmpty)
                      {
                        return "Please enter your email address";
                      }

                      else if (!isEmail(value))
                      {
                        return "Please enter a valid email address";
                      }

                    },

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20,),

                  Text("Choose a password:", style: GoogleFonts.andikaNewBasic(),),

                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,

                    obscureText: true,

                    controller: _password,

                    validator: (value)
                    {
                      if (value!.isEmpty)
                      {
                        return "Please enter a password";
                      }
                    },

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),


                  ),

                  const SizedBox(height: 20,),

                  Text("Confirm your password:", style: GoogleFonts.andikaNewBasic(),),

                  TextFormField(
                    obscureText: true,

                    validator: (value)
                    {
                      if (value != _password.text.toString())
                      {
                        return "Passwords do not match";
                      }
                    },

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),


                  ),

                  const SizedBox(height: 20,),

                  Text(signUpMessage, style: GoogleFonts.andikaNewBasic(color: Colors.red),),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async
        {
          final storageRef = FirebaseStorage
              .instance
              .ref('customer data/${_email.text.toString()}');

          if (_sign_up_key2.currentState!.validate())
          {

            String profilePictureURL;
            if (widget.display_photo != null)
              {
                final imageRef = storageRef.child('display photo.png');
                imageRef.putFile(widget.display_photo, SettableMetadata(
                  contentType: "image/jpeg",
                ));
                profilePictureURL = await imageRef.getDownloadURL();
                profilePictureURL = profilePictureURL.substring(0, profilePictureURL.length-43);
              }
            else
              {
                profilePictureURL = "https://cdn-icons-png.flaticon.com/128/3135/3135715.png";
              }


            Map <String, dynamic> newCustomer =
            {
              "Name" : widget.name.text.toString(),
              "Profile Picture" : profilePictureURL.toString(),
              "Phone" : widget.phone.text.toString(),
              "Email" : _email.text.toString(),
            };

            try
            {
              UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: _email.text.toString(),
                password: _password.text.toString(),
              );


              FirebaseFirestore.instance.collection('Customers')
                  .doc(_email.text.toString())
                  .set(newCustomer);


              MotionToast snackbar = MotionToast.success(
                title:  const Text("Account created successfully!"),
                description:  const Text("Your account has been created successfully!"),
              );

              WidgetsBinding.instance.addPostFrameCallback((timeStamp)
              {
                snackbar.show(context);
              });

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('customer name', widget.name.text.toString());

              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

            }

            on FirebaseAuthException catch (e)
            {
              if (e.code == 'weak-password')
              {
                signUpMessage = 'The password provided is too weak.';
              }
              else if (e.code == 'email-already-in-use')
              {
                signUpMessage = 'The account already exists for that email.';
              }
            }

            catch (e)
            {

            }

            setState(() {

            });

          }
        },

        icon: Icon(Icons.done_outlined),
        backgroundColor: Colors.pink,
        hoverColor: Vx.pink600,
        elevation: 10.0,
        label: Text("Done", style: GoogleFonts.openSans(),),
      ),

    );
  }
}