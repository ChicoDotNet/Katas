# OBS-030 — Validate relational integrity before structural assembly

Before building a hierarchy from unsorted records, assert dense unique IDs and constraints guaranteeing a single acyclic rooted tree, then order siblings explicitly. A different bottom-up assembly model makes a useful reference for recursive adjacency construction. Negative fixtures must actually be invalid; deleting the largest record can leave a perfectly legal shorter hierarchy. Local observation, not a demonstration of universal transfer gains.
