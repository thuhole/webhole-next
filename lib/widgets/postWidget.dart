import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:webhole/widgets/hole_details.dart';

import '../config.dart';
import '../utils.dart';

class PostWidget extends StatelessWidget {
  final dynamic postInfo;

  PostWidget(this.postInfo);

  @override
  Widget build(BuildContext context) {
    String idText = "#" + postInfo["pid"].toString();
    String type = "pid";
    if (postInfo["reply"] == null) {
      // is comment
      postInfo["reply"] = 0;
      postInfo["likenum"] = 0;
      idText = "#" + postInfo["cid"].toString();
      type = "cid";
    }
    return Center(
      child: Card(
        elevation: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
//          borderRadius: BorderRadius.only(
//              topRight: Radius.circular(15.0),
//              bottomLeft: Radius.circular(15.0),
//              bottomRight: Radius.circular(15.0)),
        ),
        child: InkWell(
          splashColor: secondaryColor,
          onTap: () {
            print('Card tapped.');
            if (postInfo["notClickable"] == null && type == "pid")
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return HoleDetails(postInfo);
              }));
          },
          child: Hero(
            tag: type + idText,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: new BoxDecoration(
                      color: type == "cid" ? secondaryColor : primaryColor),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                        child: Text(idText +
                            "  " +
                            getDateDiff((new DateTime.now()
                                        .toUtc()
                                        .microsecondsSinceEpoch ~/
                                    1000000) -
                                postInfo["timestamp"])),
                      ),
                      Spacer(),
                      postInfo["reply"] > 0
                          ? Icon(
                              Icons.comment,
                              size: 20,
                            )
                          : Container(),
                      postInfo["reply"] > 0
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(postInfo["reply"].toString()),
                            )
                          : Container(),
                      postInfo["likenum"] > 0
                          ? Icon(
                              Icons.star,
                              size: 20,
                            )
                          : Container(),
                      postInfo["likenum"] > 0
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(postInfo["likenum"].toString()),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 0,
                ),
                postInfo["text"].toString().length > 0
                    ? Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 16.0),
                          child: Text(postInfo["text"].toString()),
                        ),
                      )
                    : Container(),
                postInfo["type"] == "image"
                    ? Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          Center(
                            child: FadeInImage.memoryNetwork(
                              fadeInDuration: const Duration(milliseconds: 300),
                              placeholder: kTransparentImage,
                              image: THUHOLE_IMAGE_BASE +
                                  postInfo["url"].toString(),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
