import 'package:handy_home_app/customwidget/app_image.dart';
import 'package:flutter/material.dart';
import 'package:handy_home_app/presentation/view/home/HomeComponents/stare_rating_widget.dart';

import '../../../resources/style_manager.dart';

class CustomerCommentWidget extends StatelessWidget {
  const CustomerCommentWidget({
    Key? key,
    required this.name,
    required this.image,
    required this.comment,
    required this.rating,
  }) : super(key: key);
  final String name;
  final String image;
  final String comment;
  final int rating;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              margin: const EdgeInsetsDirectional.only(end: 10),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: AppImage(
                imageUrl: image,
                fit: BoxFit.cover,
              ),
              clipBehavior: Clip.antiAlias,
            ),
            Text(
              name.length < 3 ? 'اسم افتراضي' : name,
              style: StyleManger.headline1(fontSize: 14),
            ),
            const Spacer(),
            StareRatingWidget(ratingNumber: rating.toString())
          ],
        ),
        Text(
          comment,
          style: StyleManger.headline2(),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
