
class ChordDefinition {
  final String name;
  final String difficulty;
  final Map<int, int> fingerFrets;
  final Map<int, String> fingerLabels;
  final List<int> openStrings; // Indices of open strings (0-5)
  final List<String> stringStates; // For UI: 'X', 'O', or empty
  final List<double> targetFrequencies;

  const ChordDefinition({
    required this.name,
    this.difficulty = "Easy",
    required this.fingerFrets,
    required this.fingerLabels,
    required this.openStrings,
    required this.stringStates,
    required this.targetFrequencies,
  });
}

final List<ChordDefinition> allChordDefinitions = [
  ChordDefinition(
    name: "C Major",
    fingerFrets: {1: 3, 2: 2, 4: 1},
    fingerLabels: {1: "3", 2: "2", 4: "1"},
    openStrings: [1, 3, 5],
    stringStates: ['X', 'O', '', '', 'O', 'O'],
    targetFrequencies: [130.81, 164.81, 196.00, 261.63, 329.63],
  ),
  ChordDefinition(
    name: "G Major",
    fingerFrets: {0: 3, 1: 2, 5: 3},
    fingerLabels: {0: "3", 1: "2", 5: "4"},
    openStrings: [2, 3, 4],
    stringStates: ['', '', 'O', 'O', 'O', ''],
    targetFrequencies: [98.00, 123.47, 146.83, 196.00, 246.94, 392.00],
  ),
  ChordDefinition(
    name: "D Major",
    fingerFrets: {3: 2, 4: 3, 5: 2},
    fingerLabels: {3: "1", 4: "3", 5: "2"},
    openStrings: [2],
    stringStates: ['X', 'X', 'O', '', '', ''],
    targetFrequencies: [146.83, 220.00, 293.66, 369.99],
  ),
  ChordDefinition(
    name: "A Major",
    fingerFrets: {2: 2, 3: 2, 4: 2},
    fingerLabels: {2: "1", 3: "2", 4: "3"},
    openStrings: [1, 5],
    stringStates: ['X', 'O', '', '', '', 'O'],
    targetFrequencies: [110.00, 164.81, 220.00, 277.18, 329.63],
  ),
  ChordDefinition(
    name: "A Minor",
    fingerFrets: {2: 2, 3: 2, 4: 1},
    fingerLabels: {2: "2", 3: "3", 4: "1"},
    openStrings: [1, 5],
    stringStates: ['X', 'O', '', '', '', 'O'],
    targetFrequencies: [110.00, 164.81, 220.00, 261.63, 329.63],
  ),
  ChordDefinition(
    name: "E Minor",
    fingerFrets: {1: 2, 2: 2},
    fingerLabels: {1: "2", 2: "3"},
    openStrings: [0, 3, 4, 5],
    stringStates: ['O', '', '', 'O', 'O', 'O'],
    targetFrequencies: [82.41, 123.47, 164.81, 196.00, 246.94, 329.63],
  ),
  ChordDefinition(
    name: "D Minor",
    fingerFrets: {3: 2, 4: 3, 5: 1},
    fingerLabels: {3: "2", 4: "3", 5: "1"},
    openStrings: [2],
    stringStates: ['X', 'X', 'O', '', '', ''],
    targetFrequencies: [146.83, 220.00, 293.66, 349.23],
  ),
  ChordDefinition(
    name: "F# Minor",
    fingerFrets: {0: 2, 1: 4, 2: 4, 3: 2, 4: 2, 5: 2},
    fingerLabels: {0: "1", 1: "3", 2: "4", 3: "1", 4: "1", 5: "1"},
    openStrings: [],
    stringStates: ['', '', '', '', '', ''],
    targetFrequencies: [92.50, 138.59, 185.00, 277.18, 369.99],
  ),
  ChordDefinition(
    name: "B Minor",
    fingerFrets: {1: 2, 2: 4, 3: 4, 4: 3},
    fingerLabels: {1: "1", 2: "3", 3: "4", 4: "2"},
    openStrings: [],
    stringStates: ['X', '', '', '', '', ''],
    targetFrequencies: [123.47, 185.00, 246.94, 369.99, 493.88],
  ),
  ChordDefinition(
    name: "E Major",
    fingerFrets: {1: 2, 2: 2, 3: 1},
    fingerLabels: {1: "2", 2: "3", 3: "1"},
    openStrings: [0, 4, 5],
    stringStates: ['O', '', '', '', 'O', 'O'],
    targetFrequencies: [82.41, 123.47, 164.81, 207.65, 246.94, 329.63],
  ),
  ChordDefinition(
    name: "F# Major",
    fingerFrets: {0: 2, 1: 4, 2: 4, 3: 3},
    fingerLabels: {0: "1", 1: "3", 2: "4", 3: "2"},
    openStrings: [],
    stringStates: ['', '', '', '', '', ''],
    targetFrequencies: [92.50, 138.59, 185.00, 277.18, 369.99],
  ),
];
