module owner::main {
    use std::signer::address_of;
    use aptos_framework::object;
    use std::string::{Self, String};
    use std::bcs;
    use aptos_std::string_utils;
    use std::vector;

    friend owner::main_test;

    struct State has key {
        tags: vector<address>, // object[] holding tags
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Tag has key {
        name: String,
        creator: address,
    }   
    // Errors
    const ETAG_NAME_LIMIT_EXCEED: u64 = 0;
    const ETAG_NAME_ALREADY_EXISTS: u64 = 4;

    // Constants
    const TAG_NAME_LIMIT: u64 = 15; 

    // CHANGE THIS: fun init_module
    public(friend) fun initialize(account: &signer) {
        move_to(account, State {
            tags: vector::empty(),
        });
    }

    public(friend) entry fun create_tag(account: &signer, name: String) acquires State, Tag {
        let state = borrow_global_mut<State>(@owner);
        assert_tag_name_limit_doesnt_exceed(name);
        assert_tag_name_doesnt_exist(state.tags, name);
        let new_tag_idx = vector::length(&state.tags) + 1; 
        let constructor_ref = object::create_named_object(account, construct_tag_seed(new_tag_idx));
        let app_signer = &object::generate_signer(&constructor_ref);
        move_to(app_signer, Tag {
            name,
            creator: address_of(account),
        });
        vector::push_back(&mut state.tags, object::address_from_constructor_ref(&constructor_ref));
    }

    // View functions
    #[view] // Length of tags 
    public(friend) fun num_tag(): u64 acquires State {
        vector::length(& borrow_global<State>(@owner).tags)
    } 

    // Helper functions
    fun construct_tag_seed(num: u64): vector<u8> {
        bcs::to_bytes(&string_utils::format2(&b"{}_tag_{}", @owner, num))
    }
    // Assert functions
    fun assert_tag_name_limit_doesnt_exceed(name: String) {
        assert!(string::length(&name) <= TAG_NAME_LIMIT, ETAG_NAME_LIMIT_EXCEED);
    }
    fun assert_tag_name_doesnt_exist(tags: vector<address>, new_name: String) acquires Tag {
        let exists = false;
        let i = 0;
        while(i < vector::length(&tags)){
            let tag_addr = *vector::borrow(&tags, i);
            let tag_name = borrow_global<Tag>(tag_addr).name;
            // VULNERABLE
            if(tag_name == new_name){
                exists = true;
            };
            // CHECK THIS
        };
        assert!(exists == false, ETAG_NAME_ALREADY_EXISTS);
    }   


}