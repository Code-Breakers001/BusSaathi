import '../models/driver_models.dart';

// Still fake: these tables do not exist yet (pins, lost items).
// Replace when Ephraim adds them.

const fakePinsAhead = [
  PinAhead('Stop A', 2),
  PinAhead('Stop B', 1),
  PinAhead('Stop C', 3),
];

List<LostItem> makeLostItems() => [
      LostItem('Black umbrella left on seat 4'),
      LostItem('Blue water bottle'),
      LostItem('Student ID card'),
    ];
