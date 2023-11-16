import 'package:equatable/equatable.dart';
import 'package:solarisdemo/models/documents/document.dart';
import 'package:solarisdemo/models/documents/documents_error_type.dart';
import 'package:solarisdemo/redux/documents/documents_state.dart';
import 'package:solarisdemo/redux/documents/download/download_document_state.dart';

class DocumentsPresenter {
  static DocumentsViewModel present({
    required DocumentsState documentsState,
    required DownloadDocumentState downloadDocumentState,
  }) {
    if (documentsState is DocumentsFetchedState) {
      if (downloadDocumentState is DocumentDownloadingState) {
        return DocumentDownloadingViewModel(
          downloadingDocument: downloadDocumentState.document,
          documents: documentsState.documents,
        );
      }

      return DocumentsFetchedViewModel(documents: documentsState.documents);
    } else if (documentsState is DocumentsErrorState) {
      return DocumentsErrorViewModel(errorType: documentsState.errorType);
    }

    return DocumentsLoadingViewModel();
  }
}

abstract class DocumentsViewModel extends Equatable {
  @override
  List<Object?> get props => [];
}

class DocumentsLoadingViewModel extends DocumentsViewModel {}

class DocumentsFetchedViewModel extends DocumentsViewModel {
  final List<Document> documents;

  DocumentsFetchedViewModel({required this.documents});

  @override
  List<Object?> get props => [documents];
}

class DocumentDownloadingViewModel extends DocumentsFetchedViewModel {
  final Document downloadingDocument;

  DocumentDownloadingViewModel({
    required this.downloadingDocument,
    required super.documents,
  });

  @override
  List<Object?> get props => [downloadingDocument, documents];
}

class DocumentsErrorViewModel extends DocumentsViewModel {
  final DocumentsErrorType errorType;

  DocumentsErrorViewModel({required this.errorType});

  @override
  List<Object?> get props => [errorType];
}
