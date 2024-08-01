pragma circom  2.1.6;

include "./circuits/auth.circom";


// Public signals order
// [0] - nullifier
// [1] - pkIdentityHash
// [2] - eventID
// [3] - eventData
// [4] - revealPkIdentityHash

// Inputs
// private: skIdentity
// public: eventID, eventData, revealPkIdentityHash


component main {public [eventID, eventData]} = Auth();