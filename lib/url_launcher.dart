// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web';
import 'package:flutter/material.dart';

class EffectiveGateAdBanner extends StatelessWidget {
  final String viewType;
  const EffectiveGateAdBanner({super.key, required this.viewType});

  @override
  Widget build(BuildContext context) {
    const String viewType = 'effective-gate-ad';

    platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final adDiv = html.DivElement()
        ..id = 'effective-gate-container'
        ..style.width = '300px'
        ..style.height = '250px'
        ..setInnerHtml(
          '''
          <script type='text/javascript' src='//pl26807941.effectivegatecpm.com/df/69/e1/df69e140d9c5f168b2dd245385daa680.js'></script>
          ''',
          validator: html.NodeValidatorBuilder()
            ..allowElement('script', attributes: ['type', 'src'])
            ..allowHtml5(),
        );
      return adDiv;
    });

    return const SizedBox(
      height: 250,
      width: 300,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
