pragma circom  2.1.6;

include "./circuits/queryIdentity.circom";

component main { public [eventID, 
                        eventData, 
                        idStateRoot, 
                        selector,
                        currentDate,
                        timestampLowerbound,
                        timestampUpperbound,
                        identityCounterLowerbound,
                        identityCounterUpperbound,
                        birthDateLowerbound,
                        birthDateUpperbound,
                        expirationDateLowerbound,
                        expirationDateUpperbound,
                        citizenshipMask
                        ] } = QueryIdentity(80);