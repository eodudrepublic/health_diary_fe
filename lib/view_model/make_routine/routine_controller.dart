import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../service/workout_service.dart';

class RoutineController extends GetxController {
  /// 서버에서 받아온 운동 리스트
  RxList<dynamic> exercises = <dynamic>[].obs;

  /// 사용자가 선택한 운동들의 id (또는 name 등으로 관리해도 무방)
  RxList<int> selectedExerciseIds = <int>[].obs;

  /// 검색 기능을 위해 사용할 검색어
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExercises();
  }

  /// 운동 리스트 서버에서 불러오기
  void fetchExercises() async {
    try {
      final data = await WorkoutService.fetchExercises();
      exercises.assignAll(data);
      Log.info('운동 리스트: $exercises');
    } catch (e) {
      Log.error('fetchExercises error: $e');
    }
  }

  /// 운동 선택 토글
  void toggleExerciseSelection(int id) {
    if (selectedExerciseIds.contains(id)) {
      Log.trace("운동 선택 해제: $id");
      selectedExerciseIds.remove(id);
    } else {
      Log.trace("운동 선택: $id");
      selectedExerciseIds.add(id);
    }
  }

  /// 검색창에 문자열 입력 시 검색어를 업데이트
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// 검색어가 있을 때만 필터링된 운동 리스트 반환
  List<dynamic> get filteredExercises {
    if (searchQuery.value.isEmpty) {
      return exercises;
    } else {
      return exercises.where((exercise) {
        // 운동 이름 혹은 타겟 부위 등에서 검색
        final name = exercise['name'] ?? '';
        final target = exercise['target_area'] ?? '';
        return name.contains(searchQuery.value) ||
            target.contains(searchQuery.value);
      }).toList();
    }
  }

  /// 선택된 운동들을 콘솔에 출력
  void printSelectedExercises() {
    final selected = exercises
        .where((exercise) => selectedExerciseIds.contains(exercise['id']))
        .toList();
    Log.info('선택된 운동 리스트: $selected');
  }
}
