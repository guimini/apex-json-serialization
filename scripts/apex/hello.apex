List<ApexTestQueueItem> atqis = [
  SELECT id, status
  FROM apextestqueueitem
  WHERE status NOT IN ('Completed', 'Failed', 'Aborted')
];
for (ApexTestQueueItem atqi : atqis) {
  atqi.status = 'Aborted';
}

update atqis;
