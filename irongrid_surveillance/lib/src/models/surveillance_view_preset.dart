enum SurveillanceViewPreset {
  single(1, '1'),
  dual(2, '2'),
  quad(4, '4'),
  octa(8, '8');

  const SurveillanceViewPreset(this.panelCount, this.label);

  final int panelCount;
  final String label;

  int crossAxisCount(double width) {
    switch (this) {
      case SurveillanceViewPreset.single:
        return 1;
      case SurveillanceViewPreset.dual:
        return width >= 720 ? 2 : 2;
      case SurveillanceViewPreset.quad:
        return width >= 960 ? 4 : 2;
      case SurveillanceViewPreset.octa:
        return width >= 1280 ? 4 : 2;
    }
  }

  double mainAxisExtent(double width) {
    switch (this) {
      case SurveillanceViewPreset.single:
        return width >= 820 ? 430 : 390;
      case SurveillanceViewPreset.dual:
        return width >= 820 ? 330 : 290;
      case SurveillanceViewPreset.quad:
        return width >= 960 ? 275 : 250;
      case SurveillanceViewPreset.octa:
        return width >= 1280 ? 235 : 220;
    }
  }
}
