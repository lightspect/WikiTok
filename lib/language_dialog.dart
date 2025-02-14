import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikitok/language.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key, required this.selectedLanguage});

  final String selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select language'),
      content: Container(
        alignment: Alignment.center,
        height: 200,
        width: 300,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: Language.values.length,
          itemBuilder: (context, index) {
            final language = Language.values[index];
            return ListTile(
              leading: SvgPicture.network(
                width: 32,
                language.flag,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.language),
              ),
              title: Text(language.name),
              trailing: language == Language.fromId(selectedLanguage)
                  ? Icon(Icons.check)
                  : null,
              onTap: () {
                Navigator.pop(context, language.id);
              },
            );
          },
        ),
      ),
    );
  }
}
