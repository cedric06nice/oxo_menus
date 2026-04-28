int computeGridColumns(double width) {
  if (width < 400) return 1;
  if (width <= 900) return 2;
  return 3;
}
