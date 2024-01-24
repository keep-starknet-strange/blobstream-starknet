// Celestia-app namespace ID and its version
// See: https://celestiaorg.github.io/celestia-app/specs/namespace.html
struct NamespaceNode {
    min: Namespace,
    max: Namespace,
    // Node value.
    digest: u256,
}

struct Namespace {
    version: u8,
    id: bytes31, //TODO: #28
}

// TODO: #28
// impl NamespacePartialOrd of PartialOrd<Namespace> {
//     #[inline(always)]
//     fn le(lhs: Namespace, rhs: Namespace) -> bool {
//     }
//     #[inline(always)]
//     fn ge(lhs: Namespace, rhs: Namespace) -> bool {
//     }
//     #[inline(always)]
//     fn lt(lhs: Namespace, rhs: Namespace) -> bool {
//     }
//     #[inline(always)]
//     fn gt(lhs: Namespace, rhs: Namespace) -> bool {
//     }
// }

// impl NamespacePartialEq of PartialEq<Namespace> {
//     #[inline(always)]
//     fn eq(lhs: @Namespace, rhs: @Namespace) -> bool {
//     }
//     #[inline(always)]
//     fn ne(lhs: @Namespace, rhs: @Namespace) -> bool {
//     }
// }

// // compares two `NamespaceNode`s
// fn namespace_node_eq(first: NamespaceNode, second: NamespaceNode) -> bool {
//     return first.min.eq(second.min) && first.max.eq(second.max) && (first.digest == second.digest);
// }
