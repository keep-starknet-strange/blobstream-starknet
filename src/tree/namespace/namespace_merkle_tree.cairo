// Celestia-app namespace ID and its version
// See: https://celestiaorg.github.io/celestia-app/specs/namespace.html

struct Namespace {
    version: u8,
    id: bytes31, //TODO: make sure the switch from bytes28 is `safe` here
}

