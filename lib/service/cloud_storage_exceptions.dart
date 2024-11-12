class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotFindQuestionException extends CloudStorageException {}

class NoMoreQuestionsAvailableException extends CloudStorageException {}

class ErrorFetchingQuestionsException extends CloudStorageException {}

class ErrorUpdatingUserProgressException extends CloudStorageException {}

class ErrorFetchingUserProgressException extends CloudStorageException {}

class UserProgressNotFoundException extends CloudStorageException {}

class FailedToAddQuestionException extends CloudStorageException {}

class ErrorFetchingAssignedLessonsException extends CloudStorageException {}

class ErrorFetchingLessonsException extends CloudStorageException {}
