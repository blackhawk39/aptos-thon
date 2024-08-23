module owner::main {
    use std::signer::address_of;
    use aptos_framework::object;
    use std::string::String;
    use std::bcs;
    use aptos_std::string_utils;
    use std::vector;

    struct State has key {
        tags: vector<address>, // object[] holding tags
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Tag has key {
        name: String,
        creator: address,
    }

    const TAG_SEED_PREFIX: vector<u8> = b"TAG";

    fun init_module(account: &signer) {
        move_to(account, State {
            tags: vector::empty(),
        });
    }

    entry fun create_tag(account: &signer, name: String) acquires State {
        let state = borrow_global_mut<State>(@owner);
        // TODO: ADD NAME VALIDATION
        let new_tag_idx = vector::length(&state.tags) + 1; 
        let constructor_ref = object::create_named_object(account, construct_tag_seed(new_tag_idx));
        let app_signer = &object::generate_signer(&constructor_ref);
        move_to(app_signer, Tag {
            name,
            creator: address_of(account),
        });
        vector::push_back(&mut state.tags, object::address_from_constructor_ref(&constructor_ref));
    }

    // Helper functions
    fun construct_tag_seed(num: u64): vector<u8> {
        bcs::to_bytes(&string_utils::format2(&b"{}_tag_{}", @owner, num))
    }
}