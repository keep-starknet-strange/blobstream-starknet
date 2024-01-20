use blobstream::VALIDATOR_SET_HASH_DOMAIN_SEPARATOR;

#[test]
#[should_panic(expected: ('checkpoint !== encoding',))]
fn stub_test() {
    assert(VALIDATOR_SET_HASH_DOMAIN_SEPARATOR == 'checkpoint', 'checkpoint !== encoding');
}
