test SinglePromise [main=TestWithSinglePromise]:
  assert PromiseResultNeverChangesOnceSet, PendingPromisesAreEventuallySettled in
  (union Promise, Worker, Client, { TestWithSinglePromise });