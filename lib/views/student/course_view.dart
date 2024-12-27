// import 'package:flutter/material.dart';
// import 'package:grade_up/models/student.dart';
// import 'package:grade_up/utilities/show_error_dialog.dart';
// import 'package:grade_up/views/student/assignment_view.dart';
// import 'package:grade_up/views/student/material_view.dart';
// import 'package:grade_up/service/student_courses_service.dart';

// class CourseView extends StatefulWidget {
//   final Student student;
//   final String lesson;

//   const CourseView({super.key, required this.student, required this.lesson});

//   @override
//   State<CourseView> createState() => _CourseViewState();
// }

// class _CourseViewState extends State<CourseView> with TickerProviderStateMixin {
//   final _coursesService = StudentCoursesService();
//   List<Map<String, dynamic>> _materials = []; // List to hold fetched materials
//   bool _isLoading = true; // Loading state
//   late TabController _tabController; // TabController for tab selection

//   @override
//   void initState() {
//     super.initState();
//     _fetchAndSetMaterials();
//     _tabController = TabController(
//         length: 2, vsync: this); // Two tabs: Materials & Assignments
//   }

//   Future<void> _fetchAndSetMaterials() async {
//     try {
//       final materials = await _coursesService.fetchMaterials(
//         lessonName: widget.lesson,
//         student: widget.student,
//       );
//       setState(() {
//         _materials = materials.reversed.toList(); // Save materials to the list
//         _isLoading = false; // Set loading to false
//       });
//     } catch (error) {
//       // Handle error
//       showErrorDialog(context, 'Error fetching materials');
//       setState(() {
//         _isLoading = false; // Stop loading even if there is an error
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Course Overview'),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Materials'),
//             Tab(text: 'Assignments'),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator()) // Show spinner while loading
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 // Materials Tab
//                 ListView(
//                   children: [
//                     // Dynamic list of materials
//                     ..._materials.map((material) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8.0, horizontal: 16.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => MaterialView(
//                                   student: widget.student,
//                                   lesson: widget.lesson,
//                                   materialID: material['id'],
//                                   materialTitle: material['title'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: Colors.teal.shade200,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.3),
//                                   spreadRadius: 2,
//                                   blurRadius: 5,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Center(
//                               child: Text(
//                                 material['title'] ??
//                                     'No Title', // Display material title
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//                 // Assignments Tab
//                 AssignmentsView(
//                   student: widget.student,
//                   lesson: widget.lesson,
//                 ),
//               ],
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/student/assignment_view.dart';
import 'package:grade_up/views/student/material_view.dart';
import 'package:grade_up/service/student_courses_service.dart';

class CourseView extends StatefulWidget {
  final Student student;
  final String lesson;

  const CourseView({super.key, required this.student, required this.lesson});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> with TickerProviderStateMixin {
  final _coursesService = StudentCoursesService();
  List<Map<String, dynamic>> _materials = []; // List to hold fetched materials
  bool _isLoading = true; // Loading state
  late TabController _tabController; // TabController for tab selection

  @override
  void initState() {
    super.initState();
    _fetchAndSetMaterials();
    _tabController = TabController(
        length: 2, vsync: this); // Two tabs: Materials & Assignments
  }

  Future<void> _fetchAndSetMaterials() async {
    try {
      final materials = await _coursesService.fetchMaterials(
        lessonName: widget.lesson,
        student: widget.student,
      );
      setState(() {
        _materials = materials.reversed.toList(); // Save materials to the list
        _isLoading = false; // Set loading to false
      });
    } catch (error) {
      // Handle error
      showErrorDialog(context, 'Error fetching materials');
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Overview'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Materials'),
            Tab(text: 'Assignments'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show spinner while loading
          : TabBarView(
              controller: _tabController,
              children: [
                // Materials Tab
                _materials.isEmpty
                    ? Center(
                        child: Text(
                          'No materials available yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView(
                        children: [
                          // Dynamic list of materials
                          ..._materials.map((material) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MaterialView(
                                        student: widget.student,
                                        lesson: widget.lesson,
                                        materialID: material['id'],
                                        materialTitle: material['title'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      material['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                // Assignments Tab
                AssignmentsView(
                  student: widget.student,
                  lesson: widget.lesson,
                ),
              ],
            ),
    );
  }
}
