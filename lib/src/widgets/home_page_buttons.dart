import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickgui/src/model/operating_system.dart';
import 'package:quickgui/src/model/version.dart';
import 'package:quickgui/src/pages/operating_system_selection.dart';
import 'package:quickgui/src/pages/version_selection.dart';
import 'package:quickgui/src/widgets/home_page_button.dart';

class HomePageButtons extends StatefulWidget {
  const HomePageButtons({Key? key}) : super(key: key);

  @override
  State<HomePageButtons> createState() => _HomePageButtonsState();
}

class _HomePageButtonsState extends State<HomePageButtons> {
  @override
  Widget build(BuildContext context) {
    OperatingSystem? _selectedOperatingSystem;
    Version? _selectedVersion;
    return Row(
      children: [
        HomePageButton(
          label: "Operating system",
          text: _selectedOperatingSystem?.name ?? 'Select...',
          onPressed: () {
            Navigator.of(context)
                .push<OperatingSystem>(MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => const OperatingSystemSelection()))
                .then((selection) {
              if (selection != null) {
                setState(() {
                  _selectedOperatingSystem = selection;
                  _selectedVersion = null;
                });
              }
            });
          },
        ),
        HomePageButton(
          label: "Version",
          text: _selectedVersion?.name ?? 'Select...',
          onPressed: (_selectedOperatingSystem != null)
              ? () {
                  Navigator.of(context)
                      .push<Version>(MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => VersionSelection(
                        operatingSystem: _selectedOperatingSystem!),
                  ))
                      .then((selection) {
                    if (selection != null) {
                      setState(() {
                        _selectedVersion = selection;
                      });
                    }
                  });
                }
              : null,
        ),
        HomePageButton(
          label: 'Download',
          text: 'Download',
          onPressed: (_selectedVersion == null)
              ? null
              : () async {
                  showLoadingIndicator(text: 'Downloading');
                  await Process.run('quickget', [
                    _selectedOperatingSystem!.code!,
                    _selectedVersion!.code!
                  ]);
                  hideLoadingIndicator();
                  showDoneDialog(
                      operatingSystem: _selectedOperatingSystem!.code!,
                      version: _selectedVersion!.code!);
                },
        ),
      ],
    );
    ;
  }

  void showLoadingIndicator({String text = ''}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          backgroundColor: Colors.black87,
          content: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text('Downloading...',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: Colors.white)),
                ),
                const CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Target : ${Directory.current.absolute.path}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void hideLoadingIndicator() {
    Navigator.of(context).pop();
  }

  void showDoneDialog(
      {required String operatingSystem, required String version}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          backgroundColor: Colors.black87,
          content: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text('Done !',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: Colors.white)),
                ),
                Text(
                    'Now run "quickemu --vm $operatingSystem-$version" to start the VM',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(color: Colors.white)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Dismiss',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}