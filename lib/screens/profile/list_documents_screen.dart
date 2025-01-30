import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/enums/document_subtype.dart';
import 'package:bondgrid/enums/document_type.dart';
import 'package:bondgrid/models/document_list.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/profile/document_pdf_viewer.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ListDocumentsScreen extends StatefulWidget {
  const ListDocumentsScreen(
      {super.key,
      required this.documentType,
      required this.documentSubType,
      required this.title});

  final DocumentType documentType;
  final DocumentSubType documentSubType;
  final String title;

  @override
  State<ListDocumentsScreen> createState() => _ListDocumentsScreenState();
}

class _ListDocumentsScreenState extends State<ListDocumentsScreen> {
  DocumentList? _documentList;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPageData() {
    context
        .read<HomeBloc>()
        .add(GetDocumentListEvent(widget.documentType, widget.documentSubType));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              FocusScope.of(context).unfocus();
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }
            if (state is GetDocumentListSuccessState) {
              _documentList = state.documentList;
            }
          },
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
              body: _documentList != null
                  ? AbsorbPointer(
                      absorbing: state.status == HomeStateStatus.loading,
                      child: listDocuments(context))
                  : const SizedBox.shrink()),
        );
      },
    );
  }

  Widget listDocuments(BuildContext context) {
    return _documentList!.documents.isEmpty
        ? Center(
            child: Text(
              "Nothing to show here",
              style: AppTheme.subBodyNormal,
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SingleChildScrollView(
              child: Column(
                children: _documentList!.documents.map((document) {
                  return (document.id != null && document.date != null)
                      ? InkWell(
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
                                        child: DocumentPdfViewer(
                                          documentId: document.id!,
                                          date: document.date!,
                                        ),
                                      ),
                                    )
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) =>
                                            HomeBloc(HomeRepo()),
                                        child: DocumentPdfViewer(
                                          documentId: document.id!,
                                          date: document.date!,
                                        ),
                                      ),
                                    ),
                            ).then((_) {
                              EasyLoading.dismiss();
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(children: [
                                Expanded(
                                    child: Text(
                                  '${document.date}',
                                  style: AppTheme.bodyNormal,
                                )),
                                Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 26,
                                  color: Colors.grey[600]!.withOpacity(0.4),
                                ),
                              ]),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(),
                            ],
                          ))
                      : const SizedBox.shrink();
                }).toList(),
              ),
            ),
          );
  }
}
