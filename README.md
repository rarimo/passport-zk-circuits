# passport-zk-circuits

Circuits for a voting system based on the passport scanning

Install the `circomlib` package before running the circuits.

```console
npm install circomlib
```

**scripts** directory contains scripts to simplify interaction with circuits.

- ***compile-circuit*** - compiles circom circuit (receive *R1CS*, *WASM* & *CPP* for witness generation);  Usage: ```compile-circuit <circuit_name>```
  
- ***trusted-setup*** - *Powers-of-Tau* ceremony for trusted setup generation. Usage: ```trusted-setup <power>```
  
- ***export-keys*** - generates proving and verification keys. Do not forget to perform a trusted setup first. Usage: ```export-keys <circuit_name> <power>```

- ***gen-witness*** - generates witness. Can be done without a trusted setup. Do not forget to compile circuit first. Usage: ```gen-witness <circuit_name> <inputs>```

- ***prove*** - generates witness and proof. Do not forget to compile the circuit and export keys first. Usage: ```prove <circuit_name> <inputs>```

- ***verify*** - verifies the proof. Usage: ```verify <circuit_name>```

## Circuits

### Voting circuits

Voting circuits are used to prove that the user has registered for the voting. Technically, it is used to prove that the user knows the preimage of the leaf in the Merkle Tree.

The Merkle Tree is built upon participants registration. After proving that the user is eligible to vote, `commitment` is added to the tree.

*commitment = Poseidon(nullifier, secret)*.

By using the knowledge of the commitment preimage and generating the corresponding proof, users can express their votes.

#### Circuit parameter

**depth** - depth of a Merkle Tree used to prove leaf inclusion.

#### Inputs

- ***root***: *public*; Poseidon Hash is used for tree hashing;

- ***nullifierHash***: *public*; Poseidon Hash is used for the *nullifier* hashing;

- ***vote***: *public*; not taking part in any computations; binds the vote to the proof

- ***nullifier***: *private*

- ***secret***: *private*

- ***pathElements[levels]***: *private*; Merkle Branch

- ***pathIndices[levels]***: *private*; `0` - left, `1` - right

### Passport Verification circuits

Passport Verification circuits are used to prove that user is eligible to vote. Currently following checks are made:

- Date of passport expiracy is less than the current date;

- Current date is after date of birth + **18** years; (for now **18** years is a constant);

- Passport issuer code is used as an output signal;

### Circuit public inputs

- **currentDateYear**

- **currentDateMonth**

- **currentDateDay**

- **credValidYear**

- **credValidMonth**

- **credValidDay**

- **ageLowerbound** - age limit for voting rights. The circuit verifies that the passport owner is older than *ageLowerbound* years at the *currentDate*.

### Circuits private inputs

- **in** - passport **DG1** serialized in binary.

The current date is needed to timestamp the date of proof generation. The circuit proves that at this date, the user is eligible to vote (and will be eligible by the protocol rules at least until the credValid date).

Passport data is separated into *DataGroups*. The hashes of these datagroups are stored in **SOD** *(Security Object of the Document)*. All neccesary data is stored in *Data Group 1 (DG1)*. Currently, **SHA1** and **SHA256** hashes are supported.

### Testing

To run tests enter ***tests*** directory and run:

```mocha -p -r ts-node/register '../tests/passportTests.js'```