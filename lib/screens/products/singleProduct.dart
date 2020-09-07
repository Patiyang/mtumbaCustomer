import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodDelivery/models/products.dart';
import 'package:foodDelivery/provider/productsProvider.dart';
import 'package:foodDelivery/service/productsService.dart';
import 'package:foodDelivery/widgets/customText.dart';
import 'package:foodDelivery/widgets/textField.dart';
import 'package:provider/provider.dart';

import '../../styling.dart';

class SingleProduct extends StatefulWidget {
  final ProductsModel productsModel;

  const SingleProduct({Key key, this.productsModel}) : super(key: key);
  @override
  _SingleProductState createState() => _SingleProductState();
}

class _SingleProductState extends State<SingleProduct> {
  List<DropdownMenuItem<String>> sizesList = <DropdownMenuItem<String>>[];
  final TextEditingController quantityController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String currentSize = '';
  @override
  void initState() {
    sizesList = getDropDownItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(context);

    var singleProduct = widget.productsModel;
    var carousel = Carousel(
      dotBgColor: Colors.transparent,
      indicatorBgPadding: 5,
      overlayShadow: false,
      borderRadius: false,
      dotSize: 3,
      animationCurve: Curves.easeOutQuart,
      autoplay: false,
      animationDuration: Duration(milliseconds: 1000),
      images: [
        for (int i = 0; i < singleProduct.images.length; i++)
          Container(
            child: Image.network(singleProduct.images[i], fit: BoxFit.cover),
            foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [black.withOpacity(.1), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            )),
          ),
      ],
    );
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Hero(
          tag: '${singleProduct.id}',
          child: Text(singleProduct.name),
        ),
        actions: [
          IconButton(icon: Icon(Icons.map), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: null)
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .5,
                  width: MediaQuery.of(context).size.width,
                  child: GridTile(
                    child: Stack(
                      children: [
                        carousel,
                      ],
                    ),
                    footer: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      color: black.withOpacity(.6),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            size: 17,
                            text: singleProduct.name,
                            color: white,
                            fontWeight: FontWeight.w500,
                          ),
                          CustomText(
                            text: 'Ksh: ${singleProduct.price}',
                            color: orange,
                            fontWeight: FontWeight.bold,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: 'Remaining: ',
                          style: TextStyle(
                            color: black,
                          )),
                      TextSpan(text: '${singleProduct.quantity}', style: TextStyle(color: orange, fontWeight: FontWeight.bold))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: 'Delivery: ',
                          style: TextStyle(
                            color: black,
                          )),
                      TextSpan(
                          text: singleProduct.delivery == 'Free' ? '${singleProduct.delivery}' : 'Ksh ${singleProduct.delivery}',
                          style: TextStyle(color: orange, fontWeight: FontWeight.bold))
                    ])),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: 'Select Size: '),
                  DropdownButton(
                    hint: Text('Sizes'),
                    icon: Icon(Icons.branding_watermark),
                    iconSize: 12,
                    style: TextStyle(color: black),
                    items: sizesList,
                    onChanged: changeSelectedSize,
                    value: currentSize,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: CustomTextField(
                  validator: (v) {
                    if (int.parse(quantityController.text) > singleProduct.quantity) return 'the size picked is out of range';
                  },
                  controller: quantityController,
                  radius: 17,
                  containerColor: grey[200],
                  hint: 'Quantity',
                ),
              ),

              Divider(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: CustomText(text: '${singleProduct.description}', maxLines: 20),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: FlatButton.icon(
                        color: orange[200],
                        icon: Icon(Icons.add_shopping_cart, color: black, size: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            productProvider.addToCart(productItem: singleProduct, size: currentSize);
                            final snackBar = SnackBar(content: Text('Product added to cart', textAlign: TextAlign.center,));
                            scaffoldKey.currentState.showSnackBar(snackBar);
                          } else {
                            Fluttertoast.showToast(msg: 'failed to add product');
                          }
                        },
                        label: CustomText(text: 'add to cart'),
                      ),
                    ),
                    Divider(
                      color: black,
                    ),
                    Container(
                      child: FlatButton.icon(
                        color: orange[200],
                        icon: Icon(Icons.favorite_border, color: black, size: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        onPressed: () {},
                        label: CustomText(
                          maxLines: 2,
                          text: 'Remove From Favorites',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: 'Vendor: ', style: TextStyle(color: black, fontSize: 16)),
                TextSpan(
                    text: '${singleProduct.shopName}', style: TextStyle(color: black, fontSize: 19, fontWeight: FontWeight.bold))
              ])),
              Divider(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                // width: MediaQuery.of(context).size.width - 16,
                child: Row(
                  children: <Widget>[
                    CustomText(
                      text: 'Similar Products',
                      size: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    Spacer(),
                    // GestureDetector(child: Icon(Icons.arrow_forward_ios))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getDropDownItems() {
    List<DropdownMenuItem<String>> items = new List();
    var singleProduct = widget.productsModel;
    for (int i = 0; i < singleProduct.sizes.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
              child: Text(singleProduct.sizes[i]),
              value: singleProduct.sizes[i],
            ));
        currentSize = singleProduct.sizes[i];
      });
    }
    sizesList = items;
    return items;
  }

  changeSelectedSize(String value) {
    setState(() {
      currentSize = value;
      print(currentSize);
    });
  }

  // addtoCart() {
  //   if (formKey.currentState.validate()) {
  //   } else {
  //     print('shit');
  //   }
  // }
}
