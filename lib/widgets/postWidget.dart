import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webhole/widgets/holeDetails.dart';
import 'package:webhole/widgets/markdown.dart';

import '../config.dart';
import '../utils.dart';

class PostWidget extends StatelessWidget {
  final dynamic postInfo;
  final void Function(dynamic) replyCallback;
  final bool isDetailMode;

  PostWidget(this.postInfo, {this.isDetailMode: false, this.replyCallback});

  @override
  Widget build(BuildContext context) {
    String idText = "#" + postInfo["pid"].toString();
    String type = postInfo["cid"] == null ? "pid" : "cid";
    if (type == "cid") {
      // is comment
      idText = "#" + postInfo["cid"].toString();
    }

    bool needFold = FOLD_TAGS.indexOf(postInfo["tag"]) > -1 && !isDetailMode;
    return Hero(
      tag: HoleTypeExtension(postInfo["holeType"]).name() +
          type +
          (idText == "#0" ? (Random().nextInt(Int32Max)).toString() : idText),
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
                onDoubleTap: () {
                  print("TODO: show copiable text");
                },
                onTap: () {
                  print('Card tapped.');
                  if (!this.isDetailMode)
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return HoleDetails(info: postInfo);
                    }));
                  else if (replyCallback != null) replyCallback(postInfo);
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
                            child: Text(
                              idText +
                                  "  " +
                                  getDateDiff((new DateTime.now()
                                              .toUtc()
                                              .microsecondsSinceEpoch ~/
                                          1000000) -
                                      postInfo["timestamp"]),
                              style: TextStyle(
                                  color: getTextColor(postInfo["color"])),
                            ),
                          ),
                          Spacer(),
                          postInfo["tag"] != null && postInfo["tag"] != '折叠'
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Card(
                                      margin: EdgeInsets.all(0.0),
                                      elevation: 8.0,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Container(
                                          color: backgroundColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(postInfo["tag"]),
                                          ))),
                                )
                              : Container(),
                          postInfo["reply"] > 0
                              ? Icon(
                                  Icons.comment,
                                  size: 20,
                                  color: getTextColor(postInfo["color"]),
                                )
                              : Container(),
                          postInfo["reply"] > 0
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    postInfo["reply"].toString(),
                                    style: TextStyle(
                                        color: getTextColor(postInfo["color"])),
                                  ),
                                )
                              : Container(),
                          postInfo["likenum"] > 0
                              ? Icon(
                                  Icons.star,
                                  size: 20,
                                  color: getTextColor(postInfo["color"]),
                                )
                              : Container(),
                          postInfo["likenum"] > 0
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    postInfo["likenum"].toString(),
                                    style: TextStyle(
                                        color: getTextColor(postInfo["color"])),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    !needFold
                        ? Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 0,
                          )
                        : Container(),
                    postInfo["text"].toString().length > 0 && !needFold
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 16.0),
//                              child: Text(postInfo["text"].toString()),
                                child: getMarkdown(
                                    context,
                                    postInfo["text"].toString(),
                                    postInfo["holeType"])))
                        : Container(),
                    postInfo["rawImage"] != null
                        ? Image.memory(postInfo["rawImage"])
                        : Container(),
                    postInfo["type"] == "image" && !needFold
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
