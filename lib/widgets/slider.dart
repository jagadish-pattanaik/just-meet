import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final bool isWeb;
  const CustomSlider({
    Key key,
  this.isWeb}) : super(key: key);

  @override
  _SliderState createState() => _SliderState();
}

class _SliderState extends State<CustomSlider> {
  double currentPage = 0.0;
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 20,
      ),
      CarouselSlider(
        carouselController: buttonCarouselController,
        options: CarouselOptions(
          height: 432,
          aspectRatio: 2,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration:
          Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          pageSnapping: true,
          enlargeStrategy:
          CenterPageEnlargeStrategy.scale,
          disableCenter: true,
          onPageChanged: (int index,
              CarouselPageChangedReason changeReason) {
            setState(() {
              currentPage = index.toDouble();
            });
          },
          scrollDirection: Axis.horizontal,
        ),
        items: scrolls.toList(),
      ),
      SizedBox(
        height: 10,
      ),
      DotsIndicator(
        dotsCount: scrolls.length,
        position: currentPage,
        decorator: DotsDecorator(
          size: const Size.square(9.0),
          activeSize: const Size(18.0, 9.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)),
        ),
      )
    ]);
  }
}


final List<Widget> scrolls = [
  Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Connect with Friends',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Start or join meeting on the go',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
        Image.asset(
          'assets/images/startjoin.jpg',
          height: 380,
        ),
      ],
    ),
  ),
  Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Chat With Your Team',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Chat while on meeting and share your content',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
        Image.asset(
          'assets/images/chat.jpg',
          height: 380,
        ),
      ],
    ),
  ),
  Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Unlimited time and participants',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'No more restrictions on long and group talks',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
        Image.asset(
          'assets/images/unlimited.jpg',
          height: 380,
        ),
      ],
    ),
  ),
  Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Low Bandwidth Mode',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Low Internet speed? no problem, Just Meet',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
        Image.asset(
          'assets/images/lowmode.jpg',
          height: 380,
        ),
      ],
    ),
  ),
  Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Enhanced Encryption and Security',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Your data is safe and encrypted',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
        Image.asset(
          'assets/images/secured.jpg',
          height: 380,
        ),
      ],
    ),
  ),
];