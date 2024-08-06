// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract passportDG1VerificationSHA256Verifier {
    /// @dev Base field size
    uint256 public constant BASE_FIELD_SIZE =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /// @dev Verification Key data
    uint256 public constant ALPHA_X =
        20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 public constant ALPHA_Y =
        9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 public constant BETA_X1 =
        4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 public constant BETA_X2 =
        6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 public constant BETA_Y1 =
        21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 public constant BETA_Y2 =
        10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 public constant GAMMA_X1 =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 public constant GAMMA_X2 =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 public constant GAMMA_Y1 =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 public constant GAMMA_Y2 =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 public constant DELTA_X1 =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 public constant DELTA_X2 =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 public constant DELTA_Y1 =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 public constant DELTA_Y2 =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;

    uint256 public constant IC0_X =
        15173812305309831757708639027315020189449057594488219448543959207607673084279;
    uint256 public constant IC0_Y =
        4814820718200744916511464835021856303255833249952873915686759979417600552947;
    uint256 public constant IC1_X =
        3444252994063267366080312721417215139713916628122723523087529286045650776409;
    uint256 public constant IC1_Y =
        4361919222828239648312602078120666110225297919827173779067050201452455249930;
    uint256 public constant IC2_X =
        19300808472721615667034958542809903725324875358810540778846814364169650800414;
    uint256 public constant IC2_Y =
        20426091859060010655343410540159901955165826321293328056909481802779225131221;
    uint256 public constant IC3_X =
        8329495446876201996995806231175162591746860221198959263467553007658725162143;
    uint256 public constant IC3_Y =
        17508461337160224747297796306311768894282268327661620636214629260705532549624;
    uint256 public constant IC4_X =
        20040123241747600892666259227496013749215236854660587785663857812228012673762;
    uint256 public constant IC4_Y =
        5729443332333637593770762404117272066047057113326960028413991477297974183903;
    uint256 public constant IC5_X =
        3024259430970802219526870158524046712149294065997344281422276885118044200553;
    uint256 public constant IC5_Y =
        9801065014450203161439146571266682567573487164679976344521031094443632198026;
    uint256 public constant IC6_X =
        15667469284259607099267228672405726445698960078994075111208469718859122323637;
    uint256 public constant IC6_Y =
        10787447162480273994046848927763585296663244037416113612572074251856207793682;
    uint256 public constant IC7_X =
        9820074783160412985187460372522436631200468609751139914172627821323239779064;
    uint256 public constant IC7_Y =
        12972559272391447938575941241577431744095602567340658045147691923715011520072;
    uint256 public constant IC8_X =
        5419213375484459883306350143506463889901576856899122960678862270845991915096;
    uint256 public constant IC8_Y =
        9261974966733576467250263770968551812519600034135314844726635880580498504025;
    uint256 public constant IC9_X =
        11290445513758753115012850630733665404002511428601534527806086290324782552840;
    uint256 public constant IC9_Y =
        1659743188610609462703631354829204020986657725865076762217376006074675596814;
    uint256 public constant IC10_X =
        14821705212209839031788750598029676874964794243356605498494182067162800708956;
    uint256 public constant IC10_Y =
        1840975772780294955842758105215237594901536551454124194460024363325959212487;
    
    /// @dev Memory data
    uint16 public constant P_VK = 0;
    uint16 public constant P_PAIRING = 128;
    uint16 public constant P_LAST_MEM = 896;

    function verifyProof(
        uint256[2] calldata pA_,
        uint256[2][2] calldata pB_,
        uint256[2] calldata pC_,
        uint256[10] calldata pubSignals_
    ) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, BASE_FIELD_SIZE)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            /// @dev G1 function to multiply a G1 value(x,y) to value in an address
            function g1MulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)

                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let pPairing_ := add(pMem, P_PAIRING)
                let pVk_ := add(pMem, P_VK)

                mstore(pVk_, IC0_X)
                mstore(add(pVk_, 32), IC0_Y)

                /// @dev Compute the linear combination vk_x
                g1MulAccC(pVk_, IC1_X, IC1_Y, calldataload(add(pubSignals, 0)))
                g1MulAccC(pVk_, IC2_X, IC2_Y, calldataload(add(pubSignals, 32)))
                g1MulAccC(pVk_, IC3_X, IC3_Y, calldataload(add(pubSignals, 64)))
                g1MulAccC(pVk_, IC4_X, IC4_Y, calldataload(add(pubSignals, 96)))
                g1MulAccC(pVk_, IC5_X, IC5_Y, calldataload(add(pubSignals, 128)))
                g1MulAccC(pVk_, IC6_X, IC6_Y, calldataload(add(pubSignals, 160)))
                g1MulAccC(pVk_, IC7_X, IC7_Y, calldataload(add(pubSignals, 192)))
                g1MulAccC(pVk_, IC8_X, IC8_Y, calldataload(add(pubSignals, 224)))
                g1MulAccC(pVk_, IC9_X, IC9_Y, calldataload(add(pubSignals, 256)))
                g1MulAccC(pVk_, IC10_X, IC10_Y, calldataload(add(pubSignals, 288)))
                
                /// @dev -A
                mstore(pPairing_, calldataload(pA))
                mstore(
                    add(pPairing_, 32),
                    mod(sub(BASE_FIELD_SIZE, calldataload(add(pA, 32))), BASE_FIELD_SIZE)
                )

                /// @dev B
                mstore(add(pPairing_, 64), calldataload(pB))
                mstore(add(pPairing_, 96), calldataload(add(pB, 32)))
                mstore(add(pPairing_, 128), calldataload(add(pB, 64)))
                mstore(add(pPairing_, 160), calldataload(add(pB, 96)))

                /// @dev alpha1
                mstore(add(pPairing_, 192), ALPHA_X)
                mstore(add(pPairing_, 224), ALPHA_Y)

                /// @dev beta2
                mstore(add(pPairing_, 256), BETA_X1)
                mstore(add(pPairing_, 288), BETA_X2)
                mstore(add(pPairing_, 320), BETA_Y1)
                mstore(add(pPairing_, 352), BETA_Y2)

                /// @dev vk_x
                mstore(add(pPairing_, 384), mload(add(pMem, P_VK)))
                mstore(add(pPairing_, 416), mload(add(pMem, add(P_VK, 32))))

                /// @dev gamma2
                mstore(add(pPairing_, 448), GAMMA_X1)
                mstore(add(pPairing_, 480), GAMMA_X2)
                mstore(add(pPairing_, 512), GAMMA_Y1)
                mstore(add(pPairing_, 544), GAMMA_Y2)

                /// @dev C
                mstore(add(pPairing_, 576), calldataload(pC))
                mstore(add(pPairing_, 608), calldataload(add(pC, 32)))

                /// @dev delta2
                mstore(add(pPairing_, 640), DELTA_X1)
                mstore(add(pPairing_, 672), DELTA_X2)
                mstore(add(pPairing_, 704), DELTA_Y1)
                mstore(add(pPairing_, 736), DELTA_Y2)

                let success_ := staticcall(sub(gas(), 2000), 8, pPairing_, 768, pPairing_, 0x20)

                isOk := and(success_, mload(pPairing_))
            }

            let pMem_ := mload(0x40)
            mstore(0x40, add(pMem_, P_LAST_MEM))

            /// @dev Validate that all evaluations ∈ F
            checkField(calldataload(add(pubSignals_, 0)))
            checkField(calldataload(add(pubSignals_, 32)))
            checkField(calldataload(add(pubSignals_, 64)))
            checkField(calldataload(add(pubSignals_, 96)))
            checkField(calldataload(add(pubSignals_, 128)))
            checkField(calldataload(add(pubSignals_, 160)))
            checkField(calldataload(add(pubSignals_, 192)))
            checkField(calldataload(add(pubSignals_, 224)))
            checkField(calldataload(add(pubSignals_, 256)))
            checkField(calldataload(add(pubSignals_, 288)))
            checkField(calldataload(add(pubSignals_, 320)))
            
            /// @dev Validate all evaluations
            let isValid := checkPairing(pA_, pB_, pC_, pubSignals_, pMem_)

            mstore(0, isValid)
            return(0, 0x20)
        }
    }
}
