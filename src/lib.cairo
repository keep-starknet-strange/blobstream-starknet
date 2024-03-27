pub mod blobstreamx;
mod interfaces;

mod mocks {
    mod function_verifier;
    mod upgradeable;
}

#[cfg(test)]
mod tests {
    mod common;
    mod test_blobstreamx;
    mod test_ownable;
    mod test_upgradeable;
}

mod tree {
    mod consts;
    mod utils;
    mod binary {
        mod hasher;
        mod merkle_proof;
        mod merkle_tree;
        #[cfg(test)]
        mod tests {
            mod test_hasher;
            mod test_merkle_proof;
        }
    }
    mod namespace {
        mod hasher;
        mod merkle_tree;
        mod namespace;
        use namespace::{Namespace, NamespaceValueTrait};
        #[cfg(test)]
        mod tests {
            mod test_hasher;
            mod test_merkle_multi_proof;
            mod test_merkle_tree;
        }
    }
    #[cfg(test)]
    mod tests {
        mod test_consts;
        mod test_utils;
    }
}

mod verifier {
    mod da_verifier;
    mod types;
    #[cfg(test)]
    mod tests {
        mod test_rollup_inclusion_proofs;
        mod test_verifier;
    }
}

