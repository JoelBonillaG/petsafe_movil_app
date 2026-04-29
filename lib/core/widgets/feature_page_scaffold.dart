import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/global_header_actions.dart';

class FeaturePageScaffold extends StatelessWidget {
  const FeaturePageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBarActions = const <Widget>[],
    this.includeGlobalHeaderActions = true,
  });

  final String title;
  final Widget body;
  final List<Widget> appBarActions;
  final bool includeGlobalHeaderActions;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      ...appBarActions,
      if (includeGlobalHeaderActions) ...buildGlobalHeaderActions(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
    );
  }
}

