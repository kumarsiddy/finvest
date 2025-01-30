import 'package:bondgrid/enums/document_subtype.dart';
import 'package:bondgrid/enums/document_type.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/profile/list_documents_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentsSubTypesScreen extends StatefulWidget {
  const DocumentsSubTypesScreen(
      {Key? key, required this.documentType, required this.title})
      : super(key: key);

  final DocumentType documentType;
  final String title;

  @override
  State<DocumentsSubTypesScreen> createState() =>
      _DocumentsSubTypesScreenState();
}

class _DocumentsSubTypesScreenState extends State<DocumentsSubTypesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {},
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.title,
                  style: AppTheme.profileText,
                  textAlign: TextAlign.center,
                ),
                backgroundColor: AppTheme.backgroundColor,
                automaticallyImplyLeading: false,
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left_rounded,
                    color: AppTheme.actionButton,
                    size: 22,
                  ),
                ),
              ),
              body: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: documentSubTypes(context, widget.documentType))),
        );
      },
    );
  }

  // documentType.TAX_STATEMENT does not have a sub type screen since it is only tax_form_1099
  // documentType.TRADE_CONFIRMATION does not have a sub type screen since it is only trade_confirmation
  Widget documentSubTypes(BuildContext context, DocumentType documentType) {
    // return document sub types for documentType.STATEMENT by default
    return ListView(
      children: [
        const SizedBox(
          height: 20,
        ),
        InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  (Theme.of(context).platform == TargetPlatform.iOS)
                      ? CupertinoPageRoute(
                          builder: (context) => BlocProvider(
                                create: (context) => HomeBloc(HomeRepo()),
                                child: const ListDocumentsScreen(
                                    documentType: DocumentType.STATEMENT,
                                    documentSubType:
                                        DocumentSubType.MONTHLY_STATEMENT,
                                    title: 'Monthly Statements'),
                              ))
                      : MaterialPageRoute(
                          builder: (context) => BlocProvider(
                                create: (context) => HomeBloc(HomeRepo()),
                                child: const ListDocumentsScreen(
                                    documentType: DocumentType.STATEMENT,
                                    documentSubType:
                                        DocumentSubType.MONTHLY_STATEMENT,
                                    title: 'Monthly Statements'),
                              )));
            },
            child: Row(children: [
              Expanded(
                  child: Text(
                'Monthly Statements',
                style: AppTheme.bodyNormal,
              )),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 26,
                color: Colors.grey[600]!.withOpacity(0.4),
              ),
            ])),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  (Theme.of(context).platform == TargetPlatform.iOS)
                      ? CupertinoPageRoute(
                          builder: (context) => BlocProvider(
                                create: (context) => HomeBloc(HomeRepo()),
                                child: const ListDocumentsScreen(
                                    documentType: DocumentType.STATEMENT,
                                    documentSubType:
                                        DocumentSubType.QUARTERLY_CONFIRMATION,
                                    title: 'Quarterly Confirmations'),
                              ))
                      : MaterialPageRoute(
                          builder: (context) => BlocProvider(
                                create: (context) => HomeBloc(HomeRepo()),
                                child: const ListDocumentsScreen(
                                  documentType: DocumentType.STATEMENT,
                                  documentSubType:
                                      DocumentSubType.QUARTERLY_CONFIRMATION,
                                  title: 'Quarterly Confirmations',
                                ),
                              )));
            },
            child: Row(children: [
              Expanded(
                  child: Text(
                'Quarterly Confirmations',
                style: AppTheme.bodyNormal,
              )),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 26,
                color: Colors.grey[600]!.withOpacity(0.4),
              ),
            ])),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
      ],
    );
  }
}
