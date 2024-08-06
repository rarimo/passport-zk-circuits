pragma circom  2.1.6;

include "./circuits/participationProof.circom";

// Public signals:
// [0] challangedNullifier
// [1] nullifiersTreeRoot
// [2] participationEventId
// [3] challengedEventId

component main {public [nullifiersTreeRoot, participationEventId, challengedEventId]} = ParticipationProof(40);