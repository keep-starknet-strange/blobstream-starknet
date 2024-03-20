// // Celestia-app namespace ID and its version
// // See: https://celestiaorg.github.io/celestia-app/specs/namespace.html
#[derive(Serde, Drop, Copy)]
struct Namespace {
    version: u8,
    id: bytes31, // only 28 bytes are used
}

impl NamespaceDefault of Default<Namespace> {
    #[inline(always)]
    fn default() -> Namespace {
        return Namespace {
            version: 0,
            id: bytes31_const::<0>()
        };
    }
}

trait NamespaceValue {
    /// Equivalent of toBytes used in Solidity for comparing namespaces
    fn to_value(self: Namespace) -> u256;
}

impl NamespaceValueTrait of NamespaceValue {
    fn to_value(self: Namespace) -> u256 {
        // Same value as bytes29(abi.encodePacked(namespace.version, namespace.id))
        let mut value: u256 = self.id.into();
        value = value + (self.version.into() * 268435456); // 2^28
        return value;
    }
}

impl NamespacePartialOrd of PartialOrd<Namespace> {
    #[inline(always)]
    fn le(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_val: u256 = lhs.to_value();
        let rhs_val: u256 = rhs.to_value();
        return lhs_val <= rhs_val;
    }
    #[inline(always)]
    fn ge(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_val: u256 = lhs.to_value();
        let rhs_val: u256 = rhs.to_value();
        return lhs_val >= rhs_val;
    }
    #[inline(always)]
    fn lt(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_val: u256 = lhs.to_value();
        let rhs_val: u256 = rhs.to_value();
        return lhs_val < rhs_val;
    }
    #[inline(always)]
    fn gt(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_val: u256 = lhs.to_value();
        let rhs_val: u256 = rhs.to_value();
        return lhs_val > rhs_val;
    }
}

impl NamespacePartialEq of PartialEq<Namespace> {
    #[inline(always)]
    fn eq(lhs: @Namespace, rhs: @Namespace) -> bool {
        let lhs_id: u256 = (*lhs.id).into();
        let rhs_id: u256 = (*rhs.id).into();
        if ((lhs_id == rhs_id) && (lhs.version == rhs.version)) {
            return true;
        } else {
            return false;
        }
    }
    #[inline(always)]
    fn ne(lhs: @Namespace, rhs: @Namespace) -> bool {
        let lhs_id: u256 = (*lhs.id).into();
        let rhs_id: u256 = (*rhs.id).into();
        if (lhs_id != rhs_id || lhs.version != rhs.version) {
            return true;
        } else {
            return false;
        }
    }
}
