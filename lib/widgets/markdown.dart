import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:webhole/config.dart';

import '../utils.dart';
import 'holeDetails.dart';

Widget getMarkdown(BuildContext context, String text, HoleType type) {
//  MarkdownStyleSheet defaultStyle = MarkdownStyleSheet();
  return MarkdownBody(
    selectable: false,
    data: text,
    onTapLink: (url) {
      _launchURL(context, url, type);
    },
//    styleSheet: MarkdownStyleSheet(
//      h1: defaultStyle.h3,
//      h2: defaultStyle.h3,
//      h3: defaultStyle.h3,
//    ),
    extensionSet:
        md.ExtensionSet(md.ExtensionSet.gitHubFlavored.blockSyntaxes, [
      MyLineBreakSyntax(),
      MyLinkSyntax(type),
      ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
    ]),
  );
}

class MyLineBreakSyntax extends md.InlineSyntax {
  MyLineBreakSyntax() : super(r'(\n)+');

  /// Create a void <br> element.
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('br'));
    return true;
  }
}

class MyLinkSyntax extends md.InlineSyntax {
  HoleType type;

  MyLinkSyntax(this.type)
      : super(type == HoleType.t ? r'#\d{1,7}' : r'[2-9]\d{4,5}|1\d{4,6}');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    String str = match.group(0);
    String dest = (type == HoleType.t ? "#" : "##") + str;
    md.Element elm = md.Element.withTag('a');
    elm.children.add(md.Text(str));
    elm.attributes["href"] = dest;
    parser.addNode(elm);
    return true;
  }
}

void _launchURL(BuildContext context, String url, HoleType type) async {
  if (url.startsWith('##')) {
    Map<String, dynamic> info = {};
    info["pid"] = int.parse(url.substring(2));
    info["holeType"] = type;

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return HoleDetails(info: info);
    }));
    return;
  }
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showErrorToast('Failed to open $url');
  }
}
