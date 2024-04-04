pragma circom  2.1.6;

include "./circuits/queryIdentity.circom";

component main { public [eventID, idStateRoot, selector, pkPassportHash] } = QueryIdentity(80);