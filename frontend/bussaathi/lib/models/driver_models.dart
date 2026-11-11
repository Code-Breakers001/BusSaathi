class PinAhead {
  final String stop;
  final int count;
  const PinAhead(this.stop, this.count);
}

class LostItem {
  final String description;
  String status; // Reported, Found or Not found
  LostItem(this.description, [this.status = 'Reported']);
}
