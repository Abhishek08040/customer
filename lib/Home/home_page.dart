import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/Home/order.dart';
import 'package:customer/Home/view_product_details.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

import 'global.dart' as global_variables;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Query products = FirebaseFirestore
      .instance
      .collection('Products');

  List<Product> listOfProducts = [];

  final TextEditingController _searchQueryTextEditingController = TextEditingController();
  String searchQuery = '';

  final BottomBarWithSheetController _bottomBarController = BottomBarWithSheetController(initialIndex: 0);

  String sortBy = '';

  String filterByColor = '';
  String filterByRating = '';
  SfRangeValues filterByPriceRange = const SfRangeValues(50, 1000);

  final List<SelectedListItem> filterByRatingsList = [
    SelectedListItem(name: "5 ★ ", isSelected: false),
    SelectedListItem(name: "4 ★ ", isSelected: false),
    SelectedListItem(name: "3 ★ ", isSelected: false),
  ];

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    global_variables.listOfCart.clear();

    List<String> listOfFavourites = [];
    Map<String, dynamic> listOfCart = {};

    CollectionReference products = FirebaseFirestore
        .instance
        .collection('Products');

    FirebaseFirestore
        .instance
        .collection('Customers')
        .doc(user?.email!)
        .get()
        .then((value)
    {
      Map item = value.data()!;
      listOfFavourites = (item['Favourites'] as List).map((e) =>
      e as String).toList();

      listOfCart = item['Cart'];
      global_variables.userLocation = item['Location'];

      for (var element in listOfFavourites)
      {
        products.doc(element).get().then((product)
        {
          Map item = product.data()! as Map<String, dynamic>;

          global_variables.listOfFavourites.add(FavouriteProducts(
            element,
            item['Picture'].split('?')[0],
            item['Name'],
          ));
        });
      }

      for (var element in listOfCart.keysList())
      {
        products.doc(element).get().then((product)
        {
          Map item = product.data()! as Map<String, dynamic>;

          global_variables.listOfCart.add(CartProducts(
            element,
            item['Picture'].split('?')[0],
            item['Name'],
            item['UnitPrice'],
            listOfCart[element],

          ));
        });
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.paused:

        Map listOfAddedItems = {};
        for (var element in global_variables.listOfCart) {
          listOfAddedItems[element.productID] = element.productQuantity;
        }

        List<String> listOfFavourites = [];
        for (var element in global_variables.listOfFavourites) {
          listOfFavourites.add(element.productID);
        }

        FirebaseFirestore.instance.collection('Customers')
            .doc(user?.email!)
            .update({'Cart': listOfAddedItems});

        FirebaseFirestore.instance.collection('Customers')
            .doc(user?.email!)
            .update({'Favourites': listOfFavourites});

        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 244, 240, 1),

      body: Container(
        padding: const EdgeInsets.only(left: 15, right: 15),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 15,),

            AnimSearchBar(
              width: 400,
              onSuffixTap: () {
                setState(() {
                  _searchQueryTextEditingController.clear();
                  searchQuery = '';
                });
              },

              textController: _searchQueryTextEditingController,
              onSubmitted: (String query)
              {
                setState(() {
                  searchQuery = query;
                });
                getProductsFromSearch(query);
              },
            ),

            Row(
              children: [

                ElevatedButton.icon(
                  onPressed: () async
                  {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) =>
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  const SizedBox(height: 14,),

                                  Text("Sort",
                                    style: GoogleFonts.andikaNewBasic(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),

                                  CustomRadioButton(
                                    defaultSelected: sortBy != ''
                                        ? sortBy
                                        : null,
                                    elevation: 0,
                                    horizontal: true,
                                    absoluteZeroSpacing: false,
                                    height: 39,
                                    enableShape: true,

                                    buttonLables: const [
                                      'Name A-Z',
                                      'Price Low-High',
                                      'Price High-Low',
                                      'Ratings',
                                    ],

                                    buttonValues: const [
                                      'Name A-Z',
                                      'Price Low-High',
                                      'Price High-Low',
                                      'Ratings',
                                    ],

                                    buttonTextStyle: const ButtonTextStyle(
                                      textStyle: TextStyle(fontSize: 14,),
                                    ),

                                    radioButtonValue: (value) {
                                      setState(() {
                                        sortBy = value.toString();
                                      });
                                    },

                                    selectedColor: Colors.pink,
                                    unSelectedColor: Colors.white,
                                    unSelectedBorderColor: Colors.grey,
                                    selectedBorderColor: Colors.pink,
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,

                                    children: [

                                      FloatingActionButton.extended(
                                        onPressed: () {
                                          setState(() {
                                            sortBy = '';
                                          });
                                          Navigator.pop(ctx);
                                          getProductsFromSearch(searchQuery);
                                        },
                                        icon: const Icon(Icons.clear_all),
                                        label: const Text("Clear"),
                                      ),

                                      FloatingActionButton.extended(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          getProductsFromSearch(searchQuery);
                                        },
                                        icon: const Icon(Icons.done),
                                        label: const Text("Apply"),
                                      ),

                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                ],
                              ).px32();
                            },
                          ),

                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(32),
                            topLeft: Radius.circular(32),
                          )
                      ),
                    );
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
                  icon: const Icon(Icons.sort),
                  label: Text("Sort", style: GoogleFonts.andikaNewBasic(),),
                ).px12(),

                ElevatedButton.icon(
                  onPressed: () async
                  {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) =>
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  const SizedBox(height: 14),

                                  Text("Filters",
                                    style: GoogleFonts.andikaNewBasic(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),

                                  Text("Price range:",
                                    style: GoogleFonts.andikaNewBasic(),),

                                  SfRangeSlider(
                                    min: 50.0,
                                    max: 1000.0,
                                    values: filterByPriceRange,
                                    stepSize: 50,
                                    interval: 950,
                                    showTicks: false,
                                    showLabels: true,
                                    enableTooltip: true,
                                    activeColor: Vx.blue900,
                                    inactiveColor: Colors.grey,
                                    onChanged: (SfRangeValues values) {
                                      setState(() {
                                        filterByPriceRange = values;
                                      });
                                    },
                                  ),

                                  Text("Color:",
                                    style: GoogleFonts.andikaNewBasic(),),

                                  Row(
                                    children: [
                                      FloatingActionButton.small(
                                        backgroundColor: Colors.red,
                                        onPressed: () {
                                          setState(() {
                                            filterByColor = 'red';
                                          });
                                        },
                                        child: Container(),
                                      ),
                                      FloatingActionButton.small(
                                        backgroundColor: Colors.yellow,
                                        onPressed: () {
                                          setState(() {
                                            filterByColor = 'yellow';
                                          });
                                        },
                                        child: Container(),
                                      ),
                                      FloatingActionButton.small(
                                        backgroundColor: Colors.green,
                                        onPressed: () {
                                          setState(() {
                                            filterByColor = 'green';
                                          });
                                        },
                                        child: Container(),
                                      ),
                                      FloatingActionButton.small(
                                        backgroundColor: Colors.blue,
                                        onPressed: () {
                                          setState(() {
                                            filterByColor = 'blue';
                                          });
                                        },
                                        child: Container(),
                                      ),
                                      FloatingActionButton.small(
                                        backgroundColor: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            filterByColor = 'white';
                                          });
                                        },
                                        child: Container(),
                                      ),
                                      FloatingActionButton.small(
                                        backgroundColor: Colors.black,
                                        onPressed: () {
                                          setState(() {
                                            filterByColor = 'black';
                                          });
                                        },
                                        child: Container(),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8,),

                                  Text("Ratings",
                                    style: GoogleFonts.andikaNewBasic(),),

                                  TextFormField(
                                    readOnly: true,

                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      labelText: filterByRating == '' ?
                                      'Select a rating' : filterByRating
                                          .toString(),
                                    ),

                                    onTap: () {
                                      DropDownState(
                                        DropDown(
                                            isSearchVisible: false,
                                            bottomSheetTitle: Text(
                                              "Choose a rating",
                                              style: GoogleFonts.andikaNewBasic(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 20,
                                              ),
                                            ).px32().py12(),
                                            data: filterByRatingsList,
                                            selectedItems: (
                                                List<dynamic> selectedList) {
                                              setState(() {
                                                filterByRating =
                                                    selectedList[0].name
                                                        .toString();
                                              });
                                            }),
                                      ).showModal(context);
                                    },
                                  ),

                                  const SizedBox(height: 15),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,

                                    children: [

                                      FloatingActionButton.extended(
                                        onPressed: () {
                                          setState(() {
                                            filterByRating = '';
                                            filterByColor = '';
                                            filterByPriceRange =
                                            const SfRangeValues(50, 1000);
                                          });
                                          Navigator.pop(ctx);
                                          getProductsFromSearch(searchQuery);
                                        },
                                        icon: const Icon(Icons.clear_all),
                                        label: const Text("Clear"),
                                      ),

                                      FloatingActionButton.extended(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          getProductsFromSearch(searchQuery);
                                        },
                                        icon: const Icon(Icons.done),
                                        label: const Text("Apply"),
                                      ),

                                    ],
                                  ),

                                ],
                              ).px32();
                            },
                          ),

                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(32),
                            topLeft: Radius.circular(32),
                          )
                      ),
                    ).then((value) {
                      setState(() {});
                    });
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
                  icon: const Icon(Icons.filter_list),
                  label: Text("Filter", style: GoogleFonts.andikaNewBasic(),),
                ).px12(),

              ],
            ),

            Expanded(
              child: listOfProducts.isEmpty ?

              Text(
                "No products found!",
                style: GoogleFonts.andikaNewBasic(
                    fontSize: 15, fontWeight: FontWeight.w400),).px16().py20() :

              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                children: List.generate(listOfProducts.length, (index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Center(
                        child: Stack(
                          children: [

                            InkWell(

                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetails(
                                        productID: listOfProducts[index]
                                            .productID,
                                      ),
                                )).then((value) {
                                  setState(() {});
                                });
                              },

                              child: VxBox(
                                child: Image.network(
                                  listOfProducts[index].productPicture,
                                ),
                              ).rounded.white
                                  .square(140)
                                  .p16
                                  .make(),
                            ),
                          ],
                        ),
                      ),


                      Text(listOfProducts[index].productName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.andikaNewBasic(
                            fontSize: 18, fontWeight: FontWeight.w800
                        ),),


                      Text(listOfProducts[index].productDescription,
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                        style: GoogleFonts.andikaNewBasic(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),),


                      Row(
                        children: [
                          for (int i = 0; i <
                              listOfProducts[index].productRating; i++)
                            Text(' ★ ', style: GoogleFonts.andikaNewBasic(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(58, 1, 92, 1),
                            ),),
                        ],
                      ),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text("₹ ${listOfProducts[index].productPrice}",
                            style: GoogleFonts.andikaNewBasic(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Vx.blue900
                            ),).px2(),

                          Row(
                            children: [
                              ProductInFavourite(
                                productID: listOfProducts[index].productID, 
                                productPicture: listOfProducts[index].productPicture, 
                                productName: listOfProducts[index].productName,
                                
                              ),

                              const SizedBox(width: 10),

                              ProductInCart(
                                productID: listOfProducts[index].productID,
                                productPicture: listOfProducts[index].productPicture,
                                productName: listOfProducts[index].productName,
                                productPrice: listOfProducts[index].productPrice,

                              ),

                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 5,),

                    ],
                  ).px16();
                },),
              ),
            ),

          ],
        ),
      ),

      bottomNavigationBar: BottomBarWithSheet(
        controller: _bottomBarController,

        bottomBarTheme: const BottomBarTheme(
          decoration: BoxDecoration(
            color: Color.fromRGBO(250, 244, 240, 1),
          ),

          itemIconColor: Colors.black,
          selectedItemIconColor: Colors.pink,
          heightOpened: 475,
          heightClosed: 70,
          mainButtonPosition: MainButtonPosition.right,

        ),

        mainActionButtonTheme: const MainActionButtonTheme(
          color: Color.fromRGBO(237, 37, 78, 1.0),
        ),

        sheetChild: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState)
            {
              num totalPrice = 0;
              for (int i = 0; i < global_variables.listOfCart.length; i++)
                {
                  totalPrice += global_variables.listOfCart[i].productPrice *
                      global_variables.listOfCart[i].productQuantity;
                }

              return _bottomBarController.selectedIndex == 0 ?

              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text("Cart",
                      style: GoogleFonts.andikaNewBasic(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ).px16(),

                    const SizedBox(height: 20,),

                    for (int i = 0; i < global_variables.listOfCart.length; i++)...
                    [

                      InkWell(

                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                ProductDetails(
                                  productID: global_variables.listOfCart[i].productID,
                                ),
                          )).then((value) {
                            setState(() {});
                          });
                        },

                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 22,
                              child: Text((i+1).toString() , style: GoogleFonts.poppins(
                                fontSize: 18,
                              )),
                            ),


                            VxBox(
                              child: Hero(
                                tag: 'Product details',
                                child: Image.network(
                                  global_variables.listOfCart[i].productPicture,
                                ),
                              ),
                            ).rounded.white
                                .square(100)
                                .py12
                                .make(),

                            const SizedBox(width: 10,),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(global_variables.listOfCart[i].productName,
                                    style: GoogleFonts.poppins(fontSize: 15,),
                                    maxLines:3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(height: 2,),

                                Text("Total ₹ ${global_variables.listOfCart[i].productQuantity *
                                    global_variables.listOfCart[i].productPrice}",

                                  style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),),

                              ],
                            ),

                            SizedBox(
                              width: 50,

                              child: ElevatedButton(
                                style: ButtonStyle(

                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                  ),),

                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetails(
                                          productID: global_variables.listOfCart[i].productID,
                                        ),
                                  )).then((value) {
                                    setState(() {});
                                  });
                                },

                                child: Text(global_variables.listOfCart[i].productQuantity.toString(),
                                    style: GoogleFonts.poppins(
                                    fontSize: 18,
                                      color: Vx.blue900,
                                )),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 20,),

                    ],

                    Align(
                      alignment: Alignment.centerRight,
                      child: FloatingActionButton.extended(
                        onPressed: ()
                        {
                          if (global_variables.listOfCart.isNotEmpty)
                            {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => const OrderProducts(),
                              )).then((value) {
                                setState(() {});
                              });
                            }
                        },

                        icon: const Icon(Icons.shopping_cart),
                        label: Text("₹ $totalPrice", style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).p12(),

                  ],
                ),
              ) :

              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text("Favourites",
                      style: GoogleFonts.andikaNewBasic(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ).px16(),

                    const SizedBox(height: 20,),

                    for (int i = 0; i < global_variables.listOfFavourites.length; i++)...
                    [

                      Row(
                        children: [
                          const SizedBox(width: 5),
                          Text((i+1).toString() , style: GoogleFonts.poppins(
                            fontSize: 24,
                          )),

                          const SizedBox(width: 20,),

                          InkWell(

                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetails(
                                      productID: global_variables.listOfFavourites[i].productID,
                                    ),
                              )).then((value) {
                                setState(() {});
                              });
                            },

                            child: VxBox(
                              child: Hero(
                                tag: 'Product details',
                                child: Image.network(
                                  global_variables.listOfFavourites[i].productPicture,
                                ),
                              ),
                            ).rounded.white
                                .square(100)
                                .py12
                                .make(),
                          ),



                          const SizedBox(width: 10,),
                          SizedBox(
                            width: 130,
                            child: Text(global_variables.listOfFavourites[i].productName,
                              style: GoogleFonts.poppins(fontSize: 15,),
                              maxLines:4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          IconButton(
                            onPressed: ()
                            {
                              global_variables.listOfFavourites.removeAt(i);
                              setState((){});
                              getProductsFromSearch(searchQuery);
                            },
                            icon: const Icon(Icons.favorite, color: Colors.pink,),
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),

                    ],

                  ],
                ),
              );

            },
        ) ,

        onSelectItem: (index)
        {
          setState(() {});
        },


        items: const [
          BottomBarWithSheetItem(icon: Icons.shopping_cart_outlined),
          BottomBarWithSheetItem(icon: Icons.favorite_outline),
        ],
      ),

    );
  }


  void getProductsFromSearch(String searchQuery) {
    products = FirebaseFirestore
        .instance
        .collection('Products')
        .where('SearchQueries', arrayContainsAny: searchQuery.split(' '));


    products.get().then((QuerySnapshot snapshot) {
      listOfProducts.clear();
      for (var doc in snapshot.docs) {
        Map item = doc.data()! as Map<String, dynamic>;
        listOfProducts.add(Product(
          doc.id.toString(),
          item['Picture'].split('?')[0],
          item['Name'],
          item['UnitPrice'],
          item['Ratings'] ?? 3,
          item['Description'],
          item['Color'] ?? '',
        ));
      }


      if (sortBy == 'Name A-Z') {
        listOfProducts.sort((a, b) => a.productName.compareTo(b.productName));
      }
      else if (sortBy == 'Price Low-High') {
        listOfProducts.sort((a, b) => a.productPrice.compareTo(b.productPrice));
      }
      else if (sortBy == 'Price High-Low') {
        listOfProducts.sort((a, b) => b.productPrice.compareTo(a.productPrice));
      }
      else if (sortBy == 'Ratings') {

      }

      if (filterByColor != '') {
        listOfProducts =
            listOfProducts.where((i) => i.productColor == filterByColor)
                .toList();
      }

      if (filterByRating != '') {
        listOfProducts = listOfProducts
            .where((i) =>
        i.productRating ==
            int.parse(filterByRating.text.toString().substring(0, 1)))
            .toList();
      }

      listOfProducts = listOfProducts.where((i) =>
      i.productPrice > filterByPriceRange.start &&
          i.productPrice < filterByPriceRange.end
      ).toList();


      setState(() {

      });
    });
  }

}

class ProductInFavourite extends StatefulWidget
{
  final String productID;
  final String productPicture;
  final String productName;
  
  const ProductInFavourite({Key? key,
    required this.productID,
    required this.productPicture,
    required this.productName,
  }) : super(key: key);

  @override
  State<ProductInFavourite> createState() => _ProductInFavouriteState();
}

class _ProductInFavouriteState extends State<ProductInFavourite>
{
  @override
  Widget build(BuildContext context)
  {
    bool isProductAdded = global_variables.listOfFavourites.where(
            (element) => element.productID == widget.productID).isNotEmpty;

    return InkWell(

      child:  isProductAdded?
      const Icon(Icons.favorite, color: Colors.pink,) :
      const Icon(Icons.favorite_outline),

      onTap: ()
      {
        if (isProductAdded)
        {
          global_variables.listOfFavourites.removeWhere((element) => element.productID == widget.productID);
        }
        else
        {
          global_variables.listOfFavourites.add(FavouriteProducts(
              widget.productID,
              widget.productPicture,
              widget.productName,
          )
          );
        }

        setState(() {

        });
      },
    );
  }
}

class ProductInCart extends StatefulWidget
{
  final String productID;
  final String productPicture;
  final String productName;
  final num productPrice;


  const ProductInCart({Key? key,
    required this.productID,
    required this.productPicture,
    required this.productName,
    required this.productPrice,
  }) : super(key: key);

  @override
  State<ProductInCart> createState() => _ProductInCartState();
}

class _ProductInCartState extends State<ProductInCart>
{
  @override
  Widget build(BuildContext context)
  {
    bool isProductAddedToCart = global_variables.listOfCart.where(
            (element) => element.productID == widget.productID).isNotEmpty;


    return InkWell(

      child: isProductAddedToCart ?

      Text(global_variables.listOfCart.singleWhere((element) =>
      element.productID == widget.productID)
          .productQuantity.toString(),

        style: GoogleFonts.andikaNewBasic(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),) :

      const Icon(Icons.shopping_cart_outlined),


      onTap: ()
      {
        if (!isProductAddedToCart)
          {
            setState(() {
              global_variables.listOfCart.add(CartProducts(
                  widget.productID,
                  widget.productPicture,
                  widget.productName,
                  widget.productPrice,
                  1,
              ));
            });
          }
        else
          {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ProductDetails(
                productID: widget.productID,
              ),
            )).then((value) { setState(() {});});
          }

      },
    );
  }
}


class Product
{
  final String productID;
  final String productPicture;
  final String productName;
  final num productPrice;
  final num productRating;
  final String productDescription;
  final String productColor;

  Product(this.productID, this.productPicture, this.productName, this.productPrice, this.productRating, this.productDescription, this.productColor);
}

class FavouriteProducts
{
  final String productID;
  final String productPicture;
  final String productName;

  FavouriteProducts(this.productID, this.productPicture, this.productName);
}

class CartProducts
{
  final String productID;
  final String productPicture;
  final String productName;
  final num productPrice;
  num productQuantity;

  CartProducts(this.productID, this.productPicture, this.productName, this.productPrice, this.productQuantity,);
}
