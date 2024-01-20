use blobstream::DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR;

#[test]
#[should_panic(expected: ('checkpoint !== encoding',))]
fn stub_test() {
    assert(DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR == 'checkpoint', 'checkpoint !== encoding');
}
