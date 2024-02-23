mod blobstreamx;
mod interfaces;

mod mocks {
    mod function_verifier;
    mod upgradeable;
}

mod succinctx {
    mod gateway;
    mod interfaces;
    mod function_registry {
        mod component;
        mod interfaces;
        mod mock;
    }
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
        mod merkle_tree;
        #[cfg(test)]
        mod tests {
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
    mod types;
    #[cfg(test)]
    mod tests {
        mod test_verifier;
    }
}

