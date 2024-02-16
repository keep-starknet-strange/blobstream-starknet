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
    #[cfg(test)]
    mod tests {
        mod test_hasher;
        mod test_merkle_tree;
    }
}

#[cfg(test)]
mod tests {
    mod test_consts;
    mod test_utils;
}
