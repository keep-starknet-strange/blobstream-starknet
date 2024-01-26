mod consts;
mod binary {
    mod hasher;
    mod merkle_proof;
    #[cfg(test)]
    mod tests {
        mod test_hasher;
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
}
