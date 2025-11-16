// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web'; // for platformViewRegistry
import 'package:flutter/material.dart';

class AdsRunner extends StatefulWidget {
  final String viewType; // accept dynamic viewType

  const AdsRunner({super.key, required this.viewType});

  @override
  State<AdsRunner> createState() => _AdsRunnerState();
}

class _AdsRunnerState extends State<AdsRunner> {
  static const String viewType = 'effective-gate-adsRunner';

  @override
  Widget build(BuildContext context) {
    // Register the HTML view factory once
    platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final adDiv = html.DivElement()
        ..id = viewType
        ..style.width = '300px'
        ..style.height = '250px'
        ..setInnerHtml(
          '''
          <script type='text/javascript' src='//pl25423823.effectivegatecpm.com/33/1e/84/331e84e97e8075f644772bbef7209266.js'></script>
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
