import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webhole/widgets/hole_details.dart';
import 'package:webhole/widgets/markdown.dart';

import '../config.dart';
import '../utils.dart';

class PostWidget extends StatelessWidget {
  final dynamic postInfo;
  final bool isDetailMode;

  PostWidget(this.postInfo, {this.isDetailMode: false});

  @override
  Widget build(BuildContext context) {
    String idText = "#" + postInfo["pid"].toString();
    String type = postInfo["cid"] == null ? "pid" : "cid";
    if (type == "cid") {
      // is comment
      idText = "#" + postInfo["cid"].toString();
    }
    return Hero(
      tag: HoleTypeExtension(postInfo["holeType"]).name() + type + idText,
      child: Material(
        // Use material to make Hero take effect.
        color: backgroundColor,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: this.isDetailMode ? double.infinity : 1000),
            child: Card(
              elevation: 8.0,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              margin: EdgeInsets.only(bottom: 20, left: 16.0, right: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: InkWell(
                splashColor: secondaryColor,
                onTap: () {
                  print('Card tapped.');
                  if (!this.isDetailMode)
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return HoleDetails(info: postInfo);
                    }));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: new BoxDecoration(color: postInfo["color"]),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 0),
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
                          postInfo["tag"] != null
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4.0),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Container(
                                          color: secondaryColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(postInfo["tag"]),
                                          ))),
                                )
                              : Container(),
                          postInfo["reply"] > 0
                              ? const Icon(
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
                              ? const Icon(
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
//                              child: Text(postInfo["text"].toString()),
                                child: getMarkdown(context, isDetailMode,
                                    postInfo["text"].toString())))
                        : Container(),
                    postInfo["type"] == "image"
                        ? Center(
                            child: CachedNetworkImage(
                              imageUrl: getImageBase(postInfo["holeType"]) +
                                  postInfo["url"].toString(),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.yellowAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48.0,
                                        color: Colors.black,
                                      ),
                                      Text("图片加载失败")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
