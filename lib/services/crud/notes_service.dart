// import 'dart:async';

// import 'package:flutter/foundation.dart' show immutable;
// import 'package:mynotes/extensions/filter.dart';
// import 'package:mynotes/services/crud/crud_exceptions.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// // Columns
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';

// // Database
// const dbName = 'notes.db';
// const noteTable = 'note';
// const userTable = 'user';

// // Create tables
// const createUserTable =
//     '''CREATE TABLE IF NOT EXISTS $userTable (
//         $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
//         $emailColumn TEXT NOT NULL UNIQUE
//       )''';

// const createNoteTable =
//     '''CREATE TABLE IF NOT EXISTS $noteTable (
//         $idColumn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
//         $userIdColumn INTEGER NOT NULL,
//         $textColumn TEXT NOT NULL,
//         $isSyncedWithCloudColumn INTEGER NOT NULL,
//         FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
//       )''';

// class NotesService {
//   Database? _db;

//   DatabaseUser? _user;

//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }

//   static final NotesService _shared = NotesService._sharedInstance();

//   factory NotesService() => _shared;

//   List<DatabaseNote> _notes = [];
//   // final _notesStreamController =
//   //     StreamController<List<DatabaseNote>>.broadcast();

//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes {
//     return _notesStreamController.stream.filter((note) {
//       final currentUser = _user;
//       if (currentUser != null) {
//         return note.userId == currentUser.id;
//       } else {
//         throw UserShouldBeSetBeforeReadingNotes();
//       }
//     });
//   }

//   Future<void> _ensureDBIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       // Nothing to do
//     }
//   }

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes;
//     _notesStreamController.add(_notes);
//   }

//   Database _getDatabaseOrThrow() {
//     if (_db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       return _db!;
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       _db = await openDatabase(dbPath);
//       // Create tables
//       await _db?.execute(createUserTable);
//       await _db?.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectoryException();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> close() async {
//     if (_db == null) {
//       throw DatabaseIsNotOpenException();
//     }
//     await _db?.close();
//     _db = null;
//   }

//   // Users
//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     }

//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<void> updateUser({required DatabaseUser user}) async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();
//     final updatesCount = await db.update(
//       userTable,
//       {emailColumn: user.email},
//       where: 'id = ?',
//       whereArgs: [user.id],
//     );
//     if (updatesCount == 0) {
//       throw CouldNotUpdateUserException();
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result == 0) {
//       throw CouldNotDeleteUserException();
//     }
//   }

//   // Notes
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();

//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }

//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: '',
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: '',
//       isSyncedWithCloud: true,
//     );

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (results.isEmpty) {
//       throw CouldNotFindNoteException();
//     } else {
//       final note = DatabaseNote.fromRow(results.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<List<DatabaseNote>> getAllNotes() async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable);
//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow)).toList();
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);
//     final updatesCount = await db.update(
//       noteTable,
//       {textColumn: text, isSyncedWithCloudColumn: 0},
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );

//     if (updatesCount == 0) {
//       throw CouldNotUpdateNoteException();
//     }
//     final updatedNote = await getNote(id: note.id);
//     _notes.removeWhere((note) => note.id == updatedNote.id);
//     _notes.add(updatedNote);
//     _notesStreamController.add(_notes);
//     return updatedNote;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();
//     final count = await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
//     if (count == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDBIsOpen();

//     final db = _getDatabaseOrThrow();

//     //delete all notes, but not the table, return the number of deleted rows
//     final numberOfDeletion = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletion;
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({required this.id, required this.email});

//   DatabaseUser.fromRow(Map<String, Object?> map)
//     : id = map[idColumn] as int,
//       email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//     : id = map[idColumn] as int,
//       userId = map[userIdColumn] as int,
//       text = map[textColumn] as String,
//       isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1;

//   @override
//   bool operator ==(covariant DatabaseNote other) => other.id == id;

//   @override
//   int get hashCode => id;

//   @override
//   String toString() =>
//       'Note, ID = $id, userId = $userId, text = $text, isSyncedWithCloud = $isSyncedWithCloud';
// }
