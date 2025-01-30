import 'package:bondgrid/enums/document_subtype.dart';
import 'package:bondgrid/enums/document_type.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/profile/documents_subtypes_screen.dart';
import 'package:bondgrid/screens/profile/list_documents_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {},
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Documents',
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
                child: ListView(
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
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child:
                                                const DocumentsSubTypesScreen(
                                                    documentType:
                                                        DocumentType.STATEMENT,
                                                    title: 'Statements'),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child:
                                                const DocumentsSubTypesScreen(
                                                    documentType:
                                                        DocumentType.STATEMENT,
                                                    title: 'Statements'),
                                          )));
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            'Statements',
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
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const ListDocumentsScreen(
                                                documentType: DocumentType
                                                    .TRADE_CONFIRMATION,
                                                documentSubType: DocumentSubType
                                                    .TRADE_CONFIRMATION,
                                                title: 'Trade Confirmations'),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const ListDocumentsScreen(
                                                documentType: DocumentType
                                                    .TRADE_CONFIRMATION,
                                                documentSubType: DocumentSubType
                                                    .TRADE_CONFIRMATION,
                                                title: 'Trade Confirmations'),
                                          )));
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            'Trade Confirmations',
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
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const ListDocumentsScreen(
                                                documentType:
                                                    DocumentType.TAX_STATEMENT,
                                                documentSubType: DocumentSubType
                                                    .TAX_FORM_1099,
                                                title: 'Tax Statements'),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const ListDocumentsScreen(
                                                documentType:
                                                    DocumentType.TAX_STATEMENT,
                                                documentSubType: DocumentSubType
                                                    .TAX_FORM_1099,
                                                title: 'Tax Statements'),
                                          )));
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            'Tax Statements',
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
                )),
          ),
        );
      },
    );
  }
}
