extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter (bool Function(T) fil) => map((items) => items.where(fil).toList());
}