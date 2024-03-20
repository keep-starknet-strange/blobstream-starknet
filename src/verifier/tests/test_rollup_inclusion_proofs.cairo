use blobstream_sn::verifier::da_verifier::DAVerifier;
/// This contains the tests and setup from the Blobstream Solidity tests.
/// https://github.com/celestiaorg/blobstream-contracts/blob/master/src/lib/verifier/test/RollupInclusionProofs.t.sol

use blobstream_sn::verifier::types::{SharesProof, AttestationProof};

/// A span sequence defines the location of the rollup transaction data inside the Celestia block.
#[derive(Drop)]
struct SpanSequence {
    // Celestia block height where the rollup data was posted.
    height: u256,
    // Index of the first share containing the rollup transaction data
    // inside the Celestia block
    index: u256,
    // Number of shares that the rollup transaction data spans on.
    length: u256,
}

/// A rollup header is a simple example of the fields a Celestium header would contain.
#[derive(Drop)]
struct RollupHeader {
    // The rollup state root.
    state_root: u256,
    // The reference to the position of the rollup block inside
    // the Celestia block.
    sequence: SpanSequence
}

#[test]
fn test_unavailable_data() {
    let height: u256 = 21;
    let start_index: u256 = 0;
    let length: u256 = 10;

    let sequence = SpanSequence { height, index: start_index, length };
    let header = RollupHeader {
        state_root: 0x215bd7509274803c556914e2a4b840826bb8b7d94de9344dfb2c2b0e71ba2d26, sequence
    };
    let (square_size, error) = DAVerifier::compute_square_size_from_row_proof(
        TestFixture::get_row_root_to_data_root_proof()
    );
    assert_eq!(error, DAVerifier::Error::NoError, "Compute square size from row proof failed");
    assert_eq!(TestFixture::square_size(), square_size, "Square size mismatch");

    let attestation_proof = AttestationProof {
        commit_nonce: TestFixture::data_root_tuple_root_nonce(),
        data_root: TestFixture::get_data_root_tuple(),
        proof: TestFixture::get_data_root_tuple_proof()
    };
//let (success, err) = DAVerifier::verify_row_root_to_data_root_tuple_root(
//    bridge,

}

mod TestFixture {
    use alexandria_bytes::{Bytes, BytesTrait};
    use blobstream_sn::interfaces::DataRoot;
    use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
    //
    //    const share_data: Bytes = BytesTrait::new(512, array![
    //        0x00000000000000000000000000000000,
    //        0x00000012131232424324328899010000,
    //        0x01172830786231303937423144393932,
    //        0x39623837336641304132413830383134,
    //        0x313339446231323838323932362c3078,
    //        0x62313039374231443939323962383733,
    //        0x66413041324138303831343133394462,
    //        0x31323838323932372c313030293b2830,
    //        0x78623130393742314439393239623837,
    //        0x33664130413241383038313431333944,
    //        0x6231323838323932362c307862313039,
    //        0x37423144393932396238373366413041,
    //        0x32413830383134313339446231323838,
    //        0x323932382c3230303030293b28307862,
    //        0x31303937423144393932396238373366,
    //        0x41304132413830383134313339446231,
    //        0x323838323932362c3078623130393742,
    //        0x31443939323962383733664130413241,
    //        0x38303831343133394462313238383239,
    //        0x32392c31303030302900000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000000000000,
    //    ]);
    //
    //    const first_row_root: Bytes = BytesTrait::new(90, array![
    //        0x00000000000000000000000000000000,
    //        0x00000000000000000000000004000000,
    //        0x00000000000000000000000000000000,
    //        0x12131232424324328899eca190450f14,
    //        0x24f4c96f50142cae150261466dcf4d47,
    //        0xfb52b5e1cccef047f2fe000000000000,
    //    ]);
    //
    //    const second_row_root: Bytes = BytesTrait::new(90, array![
    //        0xffffffffffffffffffffffffffffffff,
    //        0xfffffffffffffffffffffffffeffffff,
    //        0xffffffffffffffffffffffffffffffff,
    //        0xfffffffffffffffffffe94ddc2da7e01,
    //        0xf575f757fbb4fa42ba202d51a576b609,
    //        0xa8aeb114fd226c6e7372000000000000,
    //    ]);
    //
    //    const square_size: u256 = 0x2;
    //

    fn square_size() -> u256 {
        0x2
    }

    fn data_root_tuple_root_nonce() -> u256 {
        0x2
    }

    fn get_data_root_tuple() -> DataRoot {
        DataRoot {
            height: 21,
            data_root: 0xb9b0d94eae45e56a551e9415701bec462b18329d2a42bcce3e37a22a2ca83a6f
        }
    }

    fn get_data_root_tuple_proof() -> BinaryMerkleProof {
        let data_root_tuple_proof_side_nodes: Array<u256> = array![
            0x062f1c98fda4619e8ce92c39d1fa02dc68a880fdcf2c28c9ac31cf3abb1d6ab2,
            0x8aa95c4c4ef50468dc728d4e90a07560f1c0095d2df4491879e50ef96305751d
        ];
        BinaryMerkleProof {
            side_nodes: data_root_tuple_proof_side_nodes, key: 0x0, num_leaves: 0x4
        }
    }

    fn get_row_root_to_data_root_proof() -> BinaryMerkleProof {
        let row_root_to_data_root_proof_side_nodes: Array<u256> = array![
            0xba0a74b15f58344239a4e89847b45d39db30c257c1876a375e246c98c3666cab,
            0x89d6a174bb5327c792535cb769d388e5e5904ebdf2c650dc5ff2e1c90b5eb764,
            0x5e48d0e89322b5caac9925f7acf77621dc0b06844fef864a2ab92b108fae4101
        ];

        BinaryMerkleProof {
            side_nodes: row_root_to_data_root_proof_side_nodes, key: 0x0, num_leaves: 0x8
        }
    }
}
