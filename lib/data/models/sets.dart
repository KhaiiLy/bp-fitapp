class Sets {
  final String reps;
  final String weight;
  final bool completed;

  Sets({required this.reps, required this.weight, this.completed = false});

  Map<String, dynamic> toMap() => {
        'reps': reps,
        'weight': weight,
        'completed': completed,
      };

  factory Sets.fromMap(Map<String, dynamic> data) => Sets(
        reps: data['reps'] ?? '',
        weight: data['weight'] ?? '',
        completed: data['completed'] ?? '',
      );
}
