import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/firebase_options.dart';
import 'package:grade_up/game/game_editing_view.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/views/create_assignment_view.dart';
import 'package:grade_up/game/game_options.dart';
import 'package:grade_up/game/game_page.dart';
import 'package:grade_up/views/login_view.dart';
import 'package:grade_up/views/register_view.dart';
import 'package:grade_up/views/student_progress_view.dart';
import 'package:grade_up/views/student_view.dart';
import 'package:grade_up/views/teacher_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Teacher teacher;
  teacher = Teacher(
    teacherId: '',
    name: '',
    assignedLessons: [],
  );

  runApp(
    MaterialApp(
        title: 'Grade_Up',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          studentviewRoute: (context) => const StudentMainView(),
          teachertviewRoute: (context) => const TeacherMainView(),
          gameRoute: (context) => const GamePage(
                lesson: '',
              ),
          gameoptionsRoute: (context) => const GameOptionsPage(),
          studentgameprogressRoute: (context) => const StudentProgressView(),
          gameeditRoute: (context) => const GameEditingView(),
          createassignmentviewRoute: (context) => CreateAssignmentView(
                teacher: teacher,
              ),
        }),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return const LoginView();
          default:
            return const CircularProgressIndicator.adaptive();
        }
      },
    );
  }
}
