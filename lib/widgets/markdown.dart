import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

Widget getMarkdown(BuildContext context, bool selectable, String text) {
  MarkdownStyleSheet defaultStyle = MarkdownStyleSheet();
  return MarkdownBody(
    selectable: selectable,
    data: text,
    styleSheet: MarkdownStyleSheet(
      h1: defaultStyle.h3,
      h2: defaultStyle.h3,
      h3: defaultStyle.h3,
    ),
    extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes, [
      MyLineBreakSyntax(),
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
