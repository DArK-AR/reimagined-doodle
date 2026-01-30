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
<script async="async" data-cfasync="false" src="https://pl28173098.effectivegatecpm.com/21102189b35ebd0d457674c3afc9cd4f/invoke.js"></script>
<div id="container-21102189b35ebd0d457674c3afc9cd4f"></div>
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
