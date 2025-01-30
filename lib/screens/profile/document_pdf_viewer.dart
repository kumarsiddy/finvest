import 'dart:io';

import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class DocumentPdfViewer extends StatefulWidget {
  const DocumentPdfViewer(
      {super.key, required this.documentId, required this.date});

  final String documentId;
  final String date;

  @override
  State<DocumentPdfViewer> createState() => _DocumentPdfViewerState();
}

class _DocumentPdfViewerState extends State<DocumentPdfViewer> {
  File? _documentPdf;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  void _loadPageData() {
    context.read<HomeBloc>().add(GetDocumentByIdEvent(widget.documentId));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              FocusScope.of(context).unfocus();
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            } else if (state.status == HomeStateStatus.loading) {
              EasyLoading.show();
            } else {
              EasyLoading.dismiss();
            }
            if (state is GetDocumentByIdSuccessState) {
              _documentPdf = state.documentPdf;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.date,
                style: AppTheme.profileText,
                textAlign: TextAlign.center,
              ),
              backgroundColor: AppTheme.backgroundColor,
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  EasyLoading.dismiss();
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  color: AppTheme.actionButton,
                  size: 22,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        AppTheme.actionButton, BlendMode.srcIn),
                    child: (Theme.of(context).platform == TargetPlatform.iOS)
                        ? const Icon(CupertinoIcons.share)
                        : const Icon(Icons.share),
                  ),
                  onPressed: () async {
                    if (_documentPdf != null) {
                      final xFile = XFile(_documentPdf!.path);
                      await Share.shareXFiles([xFile]);
                    }
                  },
                ),
              ],
            ),
            body: _documentPdf != null
                ? AbsorbPointer(
                    absorbing: state.status == HomeStateStatus.loading,
                    child: PDFView(
                      filePath: _documentPdf!.path,
                      onError: (error) {
                        print(error.toString());
                      },
                    ))
                : const SizedBox.shrink(),
          ));
    });
  }
}
