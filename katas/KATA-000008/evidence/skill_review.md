# OBS-009 — meaningful missing entities in rankings

Status: local complete; independent remote CI not yet confirmed.

A nullable participant does not necessarily represent an ignorable record. In this domain, an autonomous car consumes its finish position, so simply filtering null entries before assigning points changes every following competitor's score. Tests should encode business meaning before normalizing data.

Tie ranking semantics and point tables must be independently specified, not guessed from incidental collection order. Swift Optionals make the nil status explicit but do not decide its domain interpretation.

This is an original leaderboard exercise; it does not reproduce an external legacy starter's hidden behavior. One locally verified implementation cannot prove that a Ninja skill version improves performance on unseen challenges.
