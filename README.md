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

Passport data is separated into *DataGroups*. The hashes of these datagroups are stored in **SOD** *(Security Object of the Document)*. All neccesary data is stored in *Data Group 1 (DG1)*. Currently, **SHA1** and **SHA256** hashes are supported (```passportDG1VerificationSHA256``` and ```passportDG1VerificationSHA256```).

### Testing

To run tests enter ***tests*** directory and run:

```mocha -p -r ts-node/register 'passportTests.js'```

Inputs are not provided, as they contain personal data. May be mocked later.

To test query circuits:
```mocha -p -r ts-node/register 'queryIdentityTests.js'```

To test identity registration circuits:
```mocha -p -r ts-node/register 'registerIdentityTests'.js'```

### Identity platform

To enhance user experience and eliminate the repetitive need for passport rescanning, we have implemented a user identity management platform. This platform streamlines the process, making it easier and more efficient for users to verify their identity.

The core concept involves linking a unique identity key pair to each passport. This allows users to utilize these identity keys to swiftly and securely verify their information without the need for constant passport rescanning.

![Identity management](./imgs/IdentityManagement.png)

The Sparce Merkle Tree, containing the ***identity state*** (which identity connected to which passport) in stored on-chain, allowing to generate ZK proofs.

#### Register Identity Circuit

To link an identity with a passport, we utilize the ***registerIdentity*** circuits. At present, we employ the ***registerIdentityUniversal*** circuit. This mechanism enables the complete passport verification process and establishes that a specific active authentication public key is associated with a valid passport, all while maintaining the confidentiality of the passport owner's personal information.

***registerIdentityUniversal*** circuit is compiled with different parameters in order to support different signing algorithms. Currently we support ```RSA 2048``` and ```RSA 4096``` bits.

Passports from different countries often vary in structure, and even within the same country, not all passports are identical. This variability can pose a challenge, as the verification circuits rely on a strict and precise algorithm. Even a minor discrepancy, such as a shift by a single byte, can disrupt the entire verification process, rendering it ineffective.

To address these challenges, we employ a combination of verification flow and padded data hashing. 

##### Padded data hashing

Padded data hashing enables the data padding to be handled outside the circuit. This approach offers several benefits:

- ***Reduced Complexity***: By performing the padding outside the circuit, we reduce the number of constraints the circuit must manage.
- ***Increased Flexibility***: This method allows for accommodating variations in passport structure without disrupting the strict verification process.  

To illustrate, let's consider the need to hash **2688** bits of data using the SHA-256 algorithm. If we directly use `SHA256(2688)`, it will only process exactly **2688** bits. However, if we need to hash **2704** bits, we would have to instantiate a new function, `SHA256(2704)`, leading to a significant increase in constraints.

`SHA` hashing functions operates by dividing data into blocks (`512-bit` for `SHA256`) and applying padding to complete any remaining bits. So both **2688** bits and **2704** bits will be hashed as **512 bits * 6 blocks = 3072 bits**. We used `sha256NoPadding.circom` which is not adding padding to inputs. With this approach both cases can be handled with the same circuit, which allows us to handle small changes in passport structure without adding a lot of new constraints.

##### Passport Verification Flows

