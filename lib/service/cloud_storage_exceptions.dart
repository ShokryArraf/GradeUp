class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotFindQuestionException extends CloudStorageException {}

class NoMoreQuestionsAvailableException extends CloudStorageException {}
