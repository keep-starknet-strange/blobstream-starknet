#[derive(Debug)] pub struct BlobstreamX < A : starknet :: accounts ::
ConnectedAccount + Sync >
{ pub address : starknet :: core :: types :: FieldElement, pub account : A, }
impl < A : starknet :: accounts :: ConnectedAccount + Sync > BlobstreamX < A >
{
    pub fn
    new(address : starknet :: core :: types :: FieldElement, account : A) ->
    Self { Self { address, account } } pub fn
    set_contract_address(mut self, address : starknet :: core :: types ::
    FieldElement) { self.address = address; } pub fn provider(& self) -> & A
    :: Provider { self.account.provider() }
} #[derive(Debug)] pub struct BlobstreamXReader < P : starknet :: providers ::
Provider + Sync >
{
    pub address : starknet :: core :: types :: FieldElement, pub provider : P,
    pub block_id : starknet :: core :: types :: BlockId,
} impl < P : starknet :: providers :: Provider + Sync > BlobstreamXReader < P
>
{
    pub fn
    new(address : starknet :: core :: types :: FieldElement, provider : P,) ->
    Self
    {
        Self
        {
            address, provider, block_id : starknet :: core :: types :: BlockId
            :: Tag(starknet :: core :: types :: BlockTag :: Pending)
        }
    } pub fn
    set_contract_address(mut self, address : starknet :: core :: types ::
    FieldElement) { self.address = address; } pub fn provider(& self) -> & P
    { & self.provider } pub fn
    with_block(self, block_id : starknet :: core :: types :: BlockId) -> Self
    { Self { block_id, .. self } }
} #[derive(Debug, PartialEq, Clone)] pub struct DataRoot
{
    pub height : starknet :: core :: types :: FieldElement, pub data_root :
    U256
} impl cainome :: cairo_serde :: CairoSerde for DataRoot
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += starknet :: core :: types ::
        FieldElement :: cairo_serialized_size(& __rust.height); __size += U256
        :: cairo_serialized_size(& __rust.data_root); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! [];
        __out.extend(starknet :: core :: types :: FieldElement ::
        cairo_serialize(& __rust.height));
        __out.extend(U256 :: cairo_serialize(& __rust.data_root)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let height = starknet :: core :: types ::
        FieldElement :: cairo_deserialize(__felts, __offset) ? ; __offset +=
        starknet :: core :: types :: FieldElement ::
        cairo_serialized_size(& height); let data_root = U256 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += U256 ::
        cairo_serialized_size(& data_root); Ok(DataRoot { height, data_root })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct DataCommitmentStored
{
    pub proof_nonce : u64, pub start_block : u64, pub end_block : u64, pub
    data_commitment : U256
} impl cainome :: cairo_serde :: CairoSerde for DataCommitmentStored
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += u64 ::
        cairo_serialized_size(& __rust.proof_nonce); __size += u64 ::
        cairo_serialized_size(& __rust.start_block); __size += u64 ::
        cairo_serialized_size(& __rust.end_block); __size += U256 ::
        cairo_serialized_size(& __rust.data_commitment); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! []; __out.extend(u64 :: cairo_serialize(& __rust.proof_nonce));
        __out.extend(u64 :: cairo_serialize(& __rust.start_block));
        __out.extend(u64 :: cairo_serialize(& __rust.end_block));
        __out.extend(U256 :: cairo_serialize(& __rust.data_commitment)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let proof_nonce = u64 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u64 ::
        cairo_serialized_size(& proof_nonce); let start_block = u64 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u64 ::
        cairo_serialized_size(& start_block); let end_block = u64 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u64 ::
        cairo_serialized_size(& end_block); let data_commitment = U256 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += U256 ::
        cairo_serialized_size(& data_commitment);
        Ok(DataCommitmentStored
        { proof_nonce, start_block, end_block, data_commitment })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct HeadUpdate
{ pub target_block : u64, pub target_header : U256 } impl cainome ::
cairo_serde :: CairoSerde for HeadUpdate
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += u64 ::
        cairo_serialized_size(& __rust.target_block); __size += U256 ::
        cairo_serialized_size(& __rust.target_header); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! []; __out.extend(u64 :: cairo_serialize(& __rust.target_block));
        __out.extend(U256 :: cairo_serialize(& __rust.target_header)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let target_block = u64 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u64 ::
        cairo_serialized_size(& target_block); let target_header = U256 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += U256 ::
        cairo_serialized_size(& target_header);
        Ok(HeadUpdate { target_block, target_header })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct BinaryMerkleProof
{ pub side_nodes : Vec < U256 > , pub key : u32, pub num_leaves : u32 } impl
cainome :: cairo_serde :: CairoSerde for BinaryMerkleProof
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += Vec :: < U256 > ::
        cairo_serialized_size(& __rust.side_nodes); __size += u32 ::
        cairo_serialized_size(& __rust.key); __size += u32 ::
        cairo_serialized_size(& __rust.num_leaves); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! [];
        __out.extend(Vec :: < U256 > :: cairo_serialize(& __rust.side_nodes));
        __out.extend(u32 :: cairo_serialize(& __rust.key));
        __out.extend(u32 :: cairo_serialize(& __rust.num_leaves)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let side_nodes = Vec :: < U256 > ::
        cairo_deserialize(__felts, __offset) ? ; __offset += Vec :: < U256 >
        :: cairo_serialized_size(& side_nodes); let key = u32 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u32 ::
        cairo_serialized_size(& key); let num_leaves = u32 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u32 ::
        cairo_serialized_size(& num_leaves);
        Ok(BinaryMerkleProof { side_nodes, key, num_leaves })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct NextHeaderRequested
{ pub trusted_block : u64, pub trusted_header : U256 } impl cainome ::
cairo_serde :: CairoSerde for NextHeaderRequested
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += u64 ::
        cairo_serialized_size(& __rust.trusted_block); __size += U256 ::
        cairo_serialized_size(& __rust.trusted_header); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! []; __out.extend(u64 :: cairo_serialize(& __rust.trusted_block));
        __out.extend(U256 :: cairo_serialize(& __rust.trusted_header)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let trusted_block = u64 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u64 ::
        cairo_serialized_size(& trusted_block); let trusted_header = U256 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += U256 ::
        cairo_serialized_size(& trusted_header);
        Ok(NextHeaderRequested { trusted_block, trusted_header })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct HeaderRangeRequested
{ pub trusted_block : u64, pub trusted_header : U256, pub target_block : u64 }
impl cainome :: cairo_serde :: CairoSerde for HeaderRangeRequested
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += u64 ::
        cairo_serialized_size(& __rust.trusted_block); __size += U256 ::
        cairo_serialized_size(& __rust.trusted_header); __size += u64 ::
        cairo_serialized_size(& __rust.target_block); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! []; __out.extend(u64 :: cairo_serialize(& __rust.trusted_block));
        __out.extend(U256 :: cairo_serialize(& __rust.trusted_header));
        __out.extend(u64 :: cairo_serialize(& __rust.target_block)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let trusted_block = u64 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u64 ::
        cairo_serialized_size(& trusted_block); let trusted_header = U256 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += U256 ::
        cairo_serialized_size(& trusted_header); let target_block = u64 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u64 ::
        cairo_serialized_size(& target_block);
        Ok(HeaderRangeRequested
        { trusted_block, trusted_header, target_block })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct OwnershipTransferStarted
{
    pub previous_owner : cainome :: cairo_serde :: ContractAddress, pub
    new_owner : cainome :: cairo_serde :: ContractAddress
} impl cainome :: cairo_serde :: CairoSerde for OwnershipTransferStarted
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += cainome :: cairo_serde ::
        ContractAddress :: cairo_serialized_size(& __rust.previous_owner);
        __size += cainome :: cairo_serde :: ContractAddress ::
        cairo_serialized_size(& __rust.new_owner); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! [];
        __out.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(& __rust.previous_owner));
        __out.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(& __rust.new_owner)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let previous_owner = cainome ::
        cairo_serde :: ContractAddress :: cairo_deserialize(__felts, __offset)
        ? ; __offset += cainome :: cairo_serde :: ContractAddress ::
        cairo_serialized_size(& previous_owner); let new_owner = cainome ::
        cairo_serde :: ContractAddress :: cairo_deserialize(__felts, __offset)
        ? ; __offset += cainome :: cairo_serde :: ContractAddress ::
        cairo_serialized_size(& new_owner);
        Ok(OwnershipTransferStarted { previous_owner, new_owner })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct U256
{ pub low : u128, pub high : u128 } impl cainome :: cairo_serde :: CairoSerde
for U256
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += u128 ::
        cairo_serialized_size(& __rust.low); __size += u128 ::
        cairo_serialized_size(& __rust.high); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! []; __out.extend(u128 :: cairo_serialize(& __rust.low));
        __out.extend(u128 :: cairo_serialize(& __rust.high)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let low = u128 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u128 ::
        cairo_serialized_size(& low); let high = u128 ::
        cairo_deserialize(__felts, __offset) ? ; __offset += u128 ::
        cairo_serialized_size(& high); Ok(U256 { low, high })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct OwnershipTransferred
{
    pub previous_owner : cainome :: cairo_serde :: ContractAddress, pub
    new_owner : cainome :: cairo_serde :: ContractAddress
} impl cainome :: cairo_serde :: CairoSerde for OwnershipTransferred
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += cainome :: cairo_serde ::
        ContractAddress :: cairo_serialized_size(& __rust.previous_owner);
        __size += cainome :: cairo_serde :: ContractAddress ::
        cairo_serialized_size(& __rust.new_owner); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! [];
        __out.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(& __rust.previous_owner));
        __out.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(& __rust.new_owner)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let previous_owner = cainome ::
        cairo_serde :: ContractAddress :: cairo_deserialize(__felts, __offset)
        ? ; __offset += cainome :: cairo_serde :: ContractAddress ::
        cairo_serialized_size(& previous_owner); let new_owner = cainome ::
        cairo_serde :: ContractAddress :: cairo_deserialize(__felts, __offset)
        ? ; __offset += cainome :: cairo_serde :: ContractAddress ::
        cairo_serialized_size(& new_owner);
        Ok(OwnershipTransferred { previous_owner, new_owner })
    }
} #[derive(Debug, PartialEq, Clone)] pub struct Upgraded
{ pub class_hash : cainome :: cairo_serde :: ClassHash } impl cainome ::
cairo_serde :: CairoSerde for Upgraded
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        let mut __size = 0; __size += cainome :: cairo_serde :: ClassHash ::
        cairo_serialized_size(& __rust.class_hash); __size
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        let mut __out : Vec < starknet :: core :: types :: FieldElement > =
        vec! [];
        __out.extend(cainome :: cairo_serde :: ClassHash ::
        cairo_serialize(& __rust.class_hash)); __out
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let mut __offset = __offset; let class_hash = cainome :: cairo_serde
        :: ClassHash :: cairo_deserialize(__felts, __offset) ? ; __offset +=
        cainome :: cairo_serde :: ClassHash ::
        cairo_serialized_size(& class_hash); Ok(Upgraded { class_hash })
    }
} #[derive(Debug, PartialEq, Clone)] pub enum BlobstreamXEvent
{
    DataCommitmentStored(DataCommitmentStored),
    HeaderRangeRequested(HeaderRangeRequested), HeadUpdate(HeadUpdate),
    NextHeaderRequested(NextHeaderRequested), OwnableEvent(OwnableCptEvent),
    UpgradeableEvent(UpgradeableCptEvent)
} impl cainome :: cairo_serde :: CairoSerde for BlobstreamXEvent
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = std :: option :: Option :: None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        match __rust
        {
            BlobstreamXEvent :: DataCommitmentStored(val) =>
            DataCommitmentStored :: cairo_serialized_size(val) + 1,
            BlobstreamXEvent :: HeaderRangeRequested(val) =>
            HeaderRangeRequested :: cairo_serialized_size(val) + 1,
            BlobstreamXEvent :: HeadUpdate(val) => HeadUpdate ::
            cairo_serialized_size(val) + 1, BlobstreamXEvent ::
            NextHeaderRequested(val) => NextHeaderRequested ::
            cairo_serialized_size(val) + 1, BlobstreamXEvent ::
            OwnableEvent(val) => OwnableCptEvent :: cairo_serialized_size(val)
            + 1, BlobstreamXEvent :: UpgradeableEvent(val) =>
            UpgradeableCptEvent :: cairo_serialized_size(val) + 1, _ => 0
        }
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        match __rust
        {
            BlobstreamXEvent :: DataCommitmentStored(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 0usize));
                temp.extend(DataCommitmentStored :: cairo_serialize(val));
                temp
            }, BlobstreamXEvent :: HeaderRangeRequested(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 1usize));
                temp.extend(HeaderRangeRequested :: cairo_serialize(val));
                temp
            }, BlobstreamXEvent :: HeadUpdate(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 2usize));
                temp.extend(HeadUpdate :: cairo_serialize(val)); temp
            }, BlobstreamXEvent :: NextHeaderRequested(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 3usize));
                temp.extend(NextHeaderRequested :: cairo_serialize(val)); temp
            }, BlobstreamXEvent :: OwnableEvent(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 4usize));
                temp.extend(OwnableCptEvent :: cairo_serialize(val)); temp
            }, BlobstreamXEvent :: UpgradeableEvent(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 5usize));
                temp.extend(UpgradeableCptEvent :: cairo_serialize(val)); temp
            }, _ => vec! []
        }
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let __index : u128 = __felts [__offset].try_into().unwrap(); match
        __index as usize
        {
            0usize =>
            Ok(BlobstreamXEvent ::
            DataCommitmentStored(DataCommitmentStored ::
            cairo_deserialize(__felts, __offset + 1) ?)), 1usize =>
            Ok(BlobstreamXEvent ::
            HeaderRangeRequested(HeaderRangeRequested ::
            cairo_deserialize(__felts, __offset + 1) ?)), 2usize =>
            Ok(BlobstreamXEvent ::
            HeadUpdate(HeadUpdate :: cairo_deserialize(__felts, __offset + 1)
            ?)), 3usize =>
            Ok(BlobstreamXEvent ::
            NextHeaderRequested(NextHeaderRequested ::
            cairo_deserialize(__felts, __offset + 1) ?)), 4usize =>
            Ok(BlobstreamXEvent ::
            OwnableEvent(OwnableCptEvent ::
            cairo_deserialize(__felts, __offset + 1) ?)), 5usize =>
            Ok(BlobstreamXEvent ::
            UpgradeableEvent(UpgradeableCptEvent ::
            cairo_deserialize(__felts, __offset + 1) ?)), _ => return
            Err(cainome :: cairo_serde :: Error ::
            Deserialize(format!
            ("Index not handle for enum {}", "BlobstreamXEvent")))
        }
    }
} impl TryFrom < starknet :: core :: types :: EmittedEvent > for
BlobstreamXEvent
{
    type Error = String; fn
    try_from(event : starknet :: core :: types :: EmittedEvent) -> Result <
    Self, Self :: Error >
    {
        use cainome :: cairo_serde :: CairoSerde; if event.keys.is_empty()
        { return Err("Event has no key".to_string()); } let selector =
        event.keys [0]; if selector == starknet :: core :: utils ::
        get_selector_from_name("DataCommitmentStored").unwrap_or_else(| _ |
        panic! ("Invalid selector for {}", "DataCommitmentStored"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            proof_nonce = match u64 ::
            cairo_deserialize(& event.data, data_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "proof_nonce",
                "DataCommitmentStored", e)),
            }; data_offset += u64 :: cairo_serialized_size(& proof_nonce); let
            start_block = match u64 ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "start_block",
                "DataCommitmentStored", e)),
            }; key_offset += u64 :: cairo_serialized_size(& start_block); let
            end_block = match u64 ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "end_block",
                "DataCommitmentStored", e)),
            }; key_offset += u64 :: cairo_serialized_size(& end_block); let
            data_commitment = match U256 ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "data_commitment", "DataCommitmentStored", e)),
            }; key_offset += U256 :: cairo_serialized_size(& data_commitment);
            return
            Ok(BlobstreamXEvent ::
            DataCommitmentStored(DataCommitmentStored
            { proof_nonce, start_block, end_block, data_commitment }))
        }; let selector = event.keys [0]; if selector == starknet :: core ::
        utils ::
        get_selector_from_name("HeaderRangeRequested").unwrap_or_else(| _ |
        panic! ("Invalid selector for {}", "HeaderRangeRequested"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            trusted_block = match u64 ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "trusted_block", "HeaderRangeRequested", e)),
            }; key_offset += u64 :: cairo_serialized_size(& trusted_block);
            let trusted_header = match U256 ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "trusted_header", "HeaderRangeRequested", e)),
            }; key_offset += U256 :: cairo_serialized_size(& trusted_header);
            let target_block = match u64 ::
            cairo_deserialize(& event.data, data_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "target_block", "HeaderRangeRequested", e)),
            }; data_offset += u64 :: cairo_serialized_size(& target_block);
            return
            Ok(BlobstreamXEvent ::
            HeaderRangeRequested(HeaderRangeRequested
            { trusted_block, trusted_header, target_block }))
        }; let selector = event.keys [0]; if selector == starknet :: core ::
        utils ::
        get_selector_from_name("HeadUpdate").unwrap_or_else(| _ | panic!
        ("Invalid selector for {}", "HeadUpdate"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            target_block = match u64 ::
            cairo_deserialize(& event.data, data_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "target_block", "HeadUpdate", e)),
            }; data_offset += u64 :: cairo_serialized_size(& target_block);
            let target_header = match U256 ::
            cairo_deserialize(& event.data, data_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "target_header", "HeadUpdate", e)),
            }; data_offset += U256 :: cairo_serialized_size(& target_header);
            return
            Ok(BlobstreamXEvent ::
            HeadUpdate(HeadUpdate { target_block, target_header }))
        }; let selector = event.keys [0]; if selector == starknet :: core ::
        utils ::
        get_selector_from_name("NextHeaderRequested").unwrap_or_else(| _ |
        panic! ("Invalid selector for {}", "NextHeaderRequested"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            trusted_block = match u64 ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "trusted_block", "NextHeaderRequested", e)),
            }; key_offset += u64 :: cairo_serialized_size(& trusted_block);
            let trusted_header = match U256 ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "trusted_header", "NextHeaderRequested", e)),
            }; key_offset += U256 :: cairo_serialized_size(& trusted_header);
            return
            Ok(BlobstreamXEvent ::
            NextHeaderRequested(NextHeaderRequested
            { trusted_block, trusted_header }))
        }; let selector = event.keys [0]; if selector == starknet :: core ::
        utils ::
        get_selector_from_name("OwnershipTransferred").unwrap_or_else(| _ |
        panic! ("Invalid selector for {}", "OwnershipTransferred"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            previous_owner = match cainome :: cairo_serde :: ContractAddress
            :: cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "previous_owner", "OwnershipTransferred", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& previous_owner); let new_owner = match
            cainome :: cairo_serde :: ContractAddress ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "new_owner",
                "OwnershipTransferred", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& new_owner); return
            Ok(BlobstreamXEvent ::
            OwnableEvent(OwnableCptEvent ::
            OwnershipTransferred(OwnershipTransferred
            { previous_owner, new_owner })))
        }; let selector = event.keys [0]; if selector == starknet :: core ::
        utils ::
        get_selector_from_name("OwnershipTransferStarted").unwrap_or_else(| _
        | panic! ("Invalid selector for {}", "OwnershipTransferStarted"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            previous_owner = match cainome :: cairo_serde :: ContractAddress
            :: cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "previous_owner", "OwnershipTransferStarted", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& previous_owner); let new_owner = match
            cainome :: cairo_serde :: ContractAddress ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "new_owner",
                "OwnershipTransferStarted", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& new_owner); return
            Ok(BlobstreamXEvent ::
            OwnableEvent(OwnableCptEvent ::
            OwnershipTransferStarted(OwnershipTransferStarted
            { previous_owner, new_owner })))
        }; let selector = event.keys [0]; if selector == starknet :: core ::
        utils ::
        get_selector_from_name("Upgraded").unwrap_or_else(| _ | panic!
        ("Invalid selector for {}", "Upgraded"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            class_hash = match cainome :: cairo_serde :: ClassHash ::
            cairo_deserialize(& event.data, data_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "class_hash",
                "Upgraded", e)),
            }; data_offset += cainome :: cairo_serde :: ClassHash ::
            cairo_serialized_size(& class_hash); return
            Ok(BlobstreamXEvent ::
            UpgradeableEvent(UpgradeableCptEvent ::
            Upgraded(Upgraded { class_hash })))
        };
        Err(format! ("Could not match any event from keys {:?}", event.keys))
    }
} #[derive(Debug, PartialEq, Clone)] pub enum UpgradeableCptEvent
{ Upgraded(Upgraded) } impl cainome :: cairo_serde :: CairoSerde for
UpgradeableCptEvent
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = std :: option :: Option :: None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        match __rust
        {
            UpgradeableCptEvent :: Upgraded(val) => Upgraded ::
            cairo_serialized_size(val) + 1, _ => 0
        }
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        match __rust
        {
            UpgradeableCptEvent :: Upgraded(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 0usize));
                temp.extend(Upgraded :: cairo_serialize(val)); temp
            }, _ => vec! []
        }
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let __index : u128 = __felts [__offset].try_into().unwrap(); match
        __index as usize
        {
            0usize =>
            Ok(UpgradeableCptEvent ::
            Upgraded(Upgraded :: cairo_deserialize(__felts, __offset + 1) ?)),
            _ => return
            Err(cainome :: cairo_serde :: Error ::
            Deserialize(format!
            ("Index not handle for enum {}", "UpgradeableCptEvent")))
        }
    }
} impl TryFrom < starknet :: core :: types :: EmittedEvent > for
UpgradeableCptEvent
{
    type Error = String; fn
    try_from(event : starknet :: core :: types :: EmittedEvent) -> Result <
    Self, Self :: Error >
    {
        use cainome :: cairo_serde :: CairoSerde; if event.keys.is_empty()
        { return Err("Event has no key".to_string()); } let selector =
        event.keys [0]; if selector == starknet :: core :: utils ::
        get_selector_from_name("Upgraded").unwrap_or_else(| _ | panic!
        ("Invalid selector for {}", "Upgraded"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            class_hash = match cainome :: cairo_serde :: ClassHash ::
            cairo_deserialize(& event.data, data_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "class_hash",
                "Upgraded", e)),
            }; data_offset += cainome :: cairo_serde :: ClassHash ::
            cairo_serialized_size(& class_hash); return
            Ok(UpgradeableCptEvent :: Upgraded(Upgraded { class_hash }))
        };
        Err(format! ("Could not match any event from keys {:?}", event.keys))
    }
} #[derive(Debug, PartialEq, Clone)] pub enum OwnableCptEvent
{
    OwnershipTransferred(OwnershipTransferred),
    OwnershipTransferStarted(OwnershipTransferStarted)
} impl cainome :: cairo_serde :: CairoSerde for OwnableCptEvent
{
    type RustType = Self; const SERIALIZED_SIZE : std :: option :: Option <
    usize > = std :: option :: Option :: None; #[inline] fn
    cairo_serialized_size(__rust : & Self :: RustType) -> usize
    {
        match __rust
        {
            OwnableCptEvent :: OwnershipTransferred(val) =>
            OwnershipTransferred :: cairo_serialized_size(val) + 1,
            OwnableCptEvent :: OwnershipTransferStarted(val) =>
            OwnershipTransferStarted :: cairo_serialized_size(val) + 1, _ => 0
        }
    } fn cairo_serialize(__rust : & Self :: RustType) -> Vec < starknet ::
    core :: types :: FieldElement >
    {
        match __rust
        {
            OwnableCptEvent :: OwnershipTransferred(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 0usize));
                temp.extend(OwnershipTransferred :: cairo_serialize(val));
                temp
            }, OwnableCptEvent :: OwnershipTransferStarted(val) =>
            {
                let mut temp = vec! [];
                temp.extend(usize :: cairo_serialize(& 1usize));
                temp.extend(OwnershipTransferStarted :: cairo_serialize(val));
                temp
            }, _ => vec! []
        }
    } fn
    cairo_deserialize(__felts : & [starknet :: core :: types :: FieldElement],
    __offset : usize) -> cainome :: cairo_serde :: Result < Self :: RustType >
    {
        let __index : u128 = __felts [__offset].try_into().unwrap(); match
        __index as usize
        {
            0usize =>
            Ok(OwnableCptEvent ::
            OwnershipTransferred(OwnershipTransferred ::
            cairo_deserialize(__felts, __offset + 1) ?)), 1usize =>
            Ok(OwnableCptEvent ::
            OwnershipTransferStarted(OwnershipTransferStarted ::
            cairo_deserialize(__felts, __offset + 1) ?)), _ => return
            Err(cainome :: cairo_serde :: Error ::
            Deserialize(format!
            ("Index not handle for enum {}", "OwnableCptEvent")))
        }
    }
} impl TryFrom < starknet :: core :: types :: EmittedEvent > for
OwnableCptEvent
{
    type Error = String; fn
    try_from(event : starknet :: core :: types :: EmittedEvent) -> Result <
    Self, Self :: Error >
    {
        use cainome :: cairo_serde :: CairoSerde; if event.keys.is_empty()
        { return Err("Event has no key".to_string()); } let selector =
        event.keys [0]; if selector == starknet :: core :: utils ::
        get_selector_from_name("OwnershipTransferred").unwrap_or_else(| _ |
        panic! ("Invalid selector for {}", "OwnershipTransferred"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            previous_owner = match cainome :: cairo_serde :: ContractAddress
            :: cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "previous_owner", "OwnershipTransferred", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& previous_owner); let new_owner = match
            cainome :: cairo_serde :: ContractAddress ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "new_owner",
                "OwnershipTransferred", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& new_owner); return
            Ok(OwnableCptEvent ::
            OwnershipTransferred(OwnershipTransferred
            { previous_owner, new_owner }))
        }; let selector = event.keys [0]; if selector == starknet :: core ::
        utils ::
        get_selector_from_name("OwnershipTransferStarted").unwrap_or_else(| _
        | panic! ("Invalid selector for {}", "OwnershipTransferStarted"))
        {
            let mut key_offset = 0 + 1; let mut data_offset = 0; let
            previous_owner = match cainome :: cairo_serde :: ContractAddress
            :: cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}",
                "previous_owner", "OwnershipTransferStarted", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& previous_owner); let new_owner = match
            cainome :: cairo_serde :: ContractAddress ::
            cairo_deserialize(& event.keys, key_offset)
            {
                Ok(v) => v, Err(e) => return
                Err(format!
                ("Could not deserialize field {} for {}: {:?}", "new_owner",
                "OwnershipTransferStarted", e)),
            }; key_offset += cainome :: cairo_serde :: ContractAddress ::
            cairo_serialized_size(& new_owner); return
            Ok(OwnableCptEvent ::
            OwnershipTransferStarted(OwnershipTransferStarted
            { previous_owner, new_owner }))
        };
        Err(format! ("Could not match any event from keys {:?}", event.keys))
    }
} impl < A : starknet :: accounts :: ConnectedAccount + Sync > BlobstreamX < A
>
{
    #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub fn
    verify_attestation(& self, proof_nonce : & u64, data_root : & DataRoot,
    proof : & BinaryMerkleProof) -> cainome :: cairo_serde :: call :: FCall <
    A :: Provider, bool >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(proof_nonce));
        __calldata.extend(DataRoot :: cairo_serialize(data_root));
        __calldata.extend(BinaryMerkleProof :: cairo_serialize(proof)); let
        __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("verify_attestation"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn owner(& self,) -> cainome :: cairo_serde :: call :: FCall < A ::
    Provider, cainome :: cairo_serde :: ContractAddress >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("owner"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn data_commitment_max(& self,) -> cainome :: cairo_serde :: call :: FCall
    < A :: Provider, u64 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("data_commitment_max"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_gateway(& self,) -> cainome :: cairo_serde :: call :: FCall < A ::
    Provider, cainome :: cairo_serde :: ContractAddress >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_gateway"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_state_proof_nonce(& self,) -> cainome :: cairo_serde :: call ::
    FCall < A :: Provider, u64 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_state_proof_nonce"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_state_data_commitment(& self, state_nonce : & u64) -> cainome ::
    cairo_serde :: call :: FCall < A :: Provider, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(state_nonce)); let __call
        = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_state_data_commitment"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_header_range_id(& self,) -> cainome :: cairo_serde :: call :: FCall
    < A :: Provider, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_header_range_id"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_next_header_id(& self,) -> cainome :: cairo_serde :: call :: FCall
    < A :: Provider, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_next_header_id"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_frozen(& self,) -> cainome :: cairo_serde :: call :: FCall < A ::
    Provider, bool >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_frozen"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_herodotus_facts_registry(& self,) -> cainome :: cairo_serde :: call
    :: FCall < A :: Provider, cainome :: cairo_serde :: ContractAddress >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_herodotus_facts_registry"), calldata
            : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_blobstreamx_l1_contract(& self,) -> cainome :: cairo_serde :: call
    :: FCall < A :: Provider, starknet :: core :: types :: FieldElement >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_blobstreamx_l1_contract"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_header_hash(& self, _height : & u64) -> cainome :: cairo_serde ::
    call :: FCall < A :: Provider, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_height)); let __call =
        starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_header_hash"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_latest_block(& self,) -> cainome :: cairo_serde :: call :: FCall <
    A :: Provider, u64 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_latest_block"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn
    transfer_ownership_getcall(& self, new_owner : & cainome :: cairo_serde ::
    ContractAddress) -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(new_owner)); starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("transfer_ownership"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    transfer_ownership(& self, new_owner : & cainome :: cairo_serde ::
    ContractAddress) -> starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(new_owner)); let __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("transfer_ownership"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn renounce_ownership_getcall(& self,) -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("renounce_ownership"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn renounce_ownership(& self,) ->
    starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("renounce_ownership"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn
    upgrade_getcall(& self, new_class_hash : & cainome :: cairo_serde ::
    ClassHash) -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ClassHash ::
        cairo_serialize(new_class_hash)); starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("upgrade"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    upgrade(& self, new_class_hash : & cainome :: cairo_serde :: ClassHash) ->
    starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ClassHash ::
        cairo_serialize(new_class_hash)); let __call = starknet :: accounts ::
        Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("upgrade"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn
    set_gateway_getcall(& self, new_gateway : & cainome :: cairo_serde ::
    ContractAddress) -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(new_gateway)); starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_gateway"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    set_gateway(& self, new_gateway : & cainome :: cairo_serde ::
    ContractAddress) -> starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(new_gateway)); let __call = starknet :: accounts ::
        Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_gateway"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn set_header_range_id_getcall(& self, _function_id : & U256) -> starknet
    :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(U256 :: cairo_serialize(_function_id)); starknet
        :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_header_range_id"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    set_header_range_id(& self, _function_id : & U256) -> starknet :: accounts
    :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(U256 :: cairo_serialize(_function_id)); let
        __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_header_range_id"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn set_next_header_id_getcall(& self, _function_id : & U256) -> starknet
    :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(U256 :: cairo_serialize(_function_id)); starknet
        :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_next_header_id"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    set_next_header_id(& self, _function_id : & U256) -> starknet :: accounts
    :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(U256 :: cairo_serialize(_function_id)); let
        __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_next_header_id"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn set_frozen_getcall(& self, _frozen : & bool) -> starknet :: accounts ::
    Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(bool :: cairo_serialize(_frozen)); starknet ::
        accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_frozen"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn set_frozen(& self, _frozen : & bool)
    -> starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(bool :: cairo_serialize(_frozen)); let __call =
        starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_frozen"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn
    set_herodotus_facts_registry_getcall(& self, facts_registry : & cainome ::
    cairo_serde :: ContractAddress) -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(facts_registry)); starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_herodotus_facts_registry"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    set_herodotus_facts_registry(& self, facts_registry : & cainome ::
    cairo_serde :: ContractAddress) -> starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(cainome :: cairo_serde :: ContractAddress ::
        cairo_serialize(facts_registry)); let __call = starknet :: accounts ::
        Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_herodotus_facts_registry"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn
    set_blobstreamx_l1_contract_getcall(& self, l1_contract : & starknet ::
    core :: types :: FieldElement) -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(starknet :: core :: types :: FieldElement ::
        cairo_serialize(l1_contract)); starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_blobstreamx_l1_contract"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    set_blobstreamx_l1_contract(& self, l1_contract : & starknet :: core ::
    types :: FieldElement) -> starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        [];
        __calldata.extend(starknet :: core :: types :: FieldElement ::
        cairo_serialize(l1_contract)); let __call = starknet :: accounts ::
        Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("set_blobstreamx_l1_contract"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn request_header_range_getcall(& self, _target_block : & u64) -> starknet
    :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_target_block)); starknet
        :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("request_header_range"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    request_header_range(& self, _target_block : & u64) -> starknet ::
    accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_target_block)); let
        __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("request_header_range"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn commit_header_range_getcall(& self, _target_block : & u64) -> starknet
    :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_target_block)); starknet
        :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("commit_header_range"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    commit_header_range(& self, _target_block : & u64) -> starknet :: accounts
    :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_target_block)); let
        __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("commit_header_range"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn request_next_header_getcall(& self,) -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("request_next_header"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn request_next_header(& self,) ->
    starknet :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("request_next_header"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn commit_next_header_getcall(& self, _trusted_block : & u64) -> starknet
    :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_trusted_block));
        starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("commit_next_header"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    commit_next_header(& self, _trusted_block : & u64) -> starknet :: accounts
    :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_trusted_block)); let
        __call = starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("commit_next_header"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn update_data_commitments_from_facts_getcall(& self, l1_block : & U256)
    -> starknet :: accounts :: Call
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(U256 :: cairo_serialize(l1_block)); starknet ::
        accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("update_data_commitments_from_facts"), calldata : __calldata,
        }
    } #[allow(clippy :: ptr_arg)] pub fn
    update_data_commitments_from_facts(& self, l1_block : & U256) -> starknet
    :: accounts :: Execution < A >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(U256 :: cairo_serialize(l1_block)); let __call =
        starknet :: accounts :: Call
        {
            to : self.address, selector : starknet :: macros :: selector!
            ("update_data_commitments_from_facts"), calldata : __calldata,
        }; self.account.execute(vec! [__call])
    }
} impl < P : starknet :: providers :: Provider + Sync > BlobstreamXReader < P
>
{
    #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub fn
    verify_attestation(& self, proof_nonce : & u64, data_root : & DataRoot,
    proof : & BinaryMerkleProof) -> cainome :: cairo_serde :: call :: FCall <
    P, bool >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(proof_nonce));
        __calldata.extend(DataRoot :: cairo_serialize(data_root));
        __calldata.extend(BinaryMerkleProof :: cairo_serialize(proof)); let
        __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("verify_attestation"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn owner(& self,) -> cainome :: cairo_serde :: call :: FCall < P, cainome
    :: cairo_serde :: ContractAddress >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("owner"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn data_commitment_max(& self,) -> cainome :: cairo_serde :: call :: FCall
    < P, u64 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("data_commitment_max"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_gateway(& self,) -> cainome :: cairo_serde :: call :: FCall < P,
    cainome :: cairo_serde :: ContractAddress >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_gateway"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_state_proof_nonce(& self,) -> cainome :: cairo_serde :: call ::
    FCall < P, u64 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_state_proof_nonce"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_state_data_commitment(& self, state_nonce : & u64) -> cainome ::
    cairo_serde :: call :: FCall < P, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(state_nonce)); let __call
        = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_state_data_commitment"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_header_range_id(& self,) -> cainome :: cairo_serde :: call :: FCall
    < P, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_header_range_id"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_next_header_id(& self,) -> cainome :: cairo_serde :: call :: FCall
    < P, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_next_header_id"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_frozen(& self,) -> cainome :: cairo_serde :: call :: FCall < P,
    bool >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_frozen"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_herodotus_facts_registry(& self,) -> cainome :: cairo_serde :: call
    :: FCall < P, cainome :: cairo_serde :: ContractAddress >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_herodotus_facts_registry"), calldata
            : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_blobstreamx_l1_contract(& self,) -> cainome :: cairo_serde :: call
    :: FCall < P, starknet :: core :: types :: FieldElement >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_blobstreamx_l1_contract"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_header_hash(& self, _height : & u64) -> cainome :: cairo_serde ::
    call :: FCall < P, U256 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; __calldata.extend(u64 :: cairo_serialize(_height)); let __call =
        starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_header_hash"), calldata : __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    } #[allow(clippy :: ptr_arg)] #[allow(clippy :: too_many_arguments)] pub
    fn get_latest_block(& self,) -> cainome :: cairo_serde :: call :: FCall <
    P, u64 >
    {
        use cainome :: cairo_serde :: CairoSerde; let mut __calldata = vec!
        []; let __call = starknet :: core :: types :: FunctionCall
        {
            contract_address : self.address, entry_point_selector : starknet
            :: macros :: selector! ("get_latest_block"), calldata :
            __calldata,
        }; cainome :: cairo_serde :: call :: FCall ::
        new(__call, self.provider(),)
    }
}