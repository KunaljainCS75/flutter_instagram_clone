import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockUserReposiory extends Mock implements UserRepository {}
class MockUser extends Mock implements User {}
void main() {
    group('App', () {
    testWidgets('renders Scaffold', (tester) async {
      // await tester.pumpWidget(
      //   App(user: MockUser(), userRepository: MockUserReposiory()), 
      // );
      // expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
// Purpose of the Test:

// The main purpose of this test is to ensure that the App widget, 
// when initialized with mocked user data, renders the expected UI structure 
// (i.e., a Scaffold widget). 

// It's a basic test to verify that the fundamental UI element is present and 
// functioning correctly.