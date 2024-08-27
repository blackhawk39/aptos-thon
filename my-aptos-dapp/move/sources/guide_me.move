module guide_me_addr::guide_me{
    use std::string::String;
    use aptos_framework::object;
    use aptos_std::smart_table::{Self,SmartTable};
    use aptos_std::smart_vector;

    const OBJECT_NAME: vector<u8> = b"AskAroundObject";
    struct Question has store{
        id: u64,
        asker: address,
        content: String,
        tag: String,
        answered: bool,
        best_answer_id: u64,
        timestamp: u64
    }
    struct Answer has store {
        answerer: address,
        content: String,
        timestamp: u64
    }
    struct User has store{
        name: String,
        questions: smart_vector<u64>
    }
    struct Tag has store {
        user_count: u64
    }

    struct UserTag has store{
        exists: bool,
        timestamp: u64,
        last_claimed: u64,
        best_answer_count: u64
    }
    // #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct AskAroundObject has key{
        owner: address,
        questions: smart_vector<Question>,
        answers: smart_vector<smart_vector<Answer>>,
        tags: smart_table<String, Tag>,
        user_tags: smart_table<address, smart_table<String, UserTag>>,
        // stakes: smart_table<address,u64>,
        tag_to_questions: smart_table<String, smart_vector<u64>>,
        tag_keys: smart_vector<String>,
        users:  smart_table<address, User>
    }
    fun init_module(owner: &signer) {
       
        assert!(!exists<AskAroundObject>(@guide_me_addr), 0);
        let ask_around_object_constructor_ref = &object::create_named_object(owner,OBJECT_NAME);
        let object_signer = &object::generate_signer(ask_around_object_constructor_ref);
        // move_to is a function to move the struct to the global storage
        move_to(object_signer, AskAroundObject {
            owner: @guide_me_addr ,
            questions: smart_vector::new<Question>(),
            answers: smart_vector::new<smart_vector<Answer>>(),
            tags: smart_table::new<String, Tag>(),
            user_tags: smart_table::new<address, smart_table<String, UserTag>>(),
            // stakes: smart_table::new<address,u64>(),
            tag_to_questions:smart_table::new<String, smart_vector<u64>>(),
            tag_keys: smart_vector::new<String>(),
            users: smart_table::new<address, User>()
        });
    }
    public fun register_user(
        user: &signer,
        name: String
    ) {
        let user_addr = Signer::address_of(user);

        // // Check that the name is not empty
        // assert!(string::length(&name) > 0, 1);

        // // Check that the name length is within acceptable limits (1 to 100 characters)
        // assert!(string::length(&name) <= 100, 2);
        let a_a_object = borrow_global_mut<AskAroundObject>(state_object_address());
        let table = a_a_object.users;
        assert!(smart_table::contains(&table, user_addr),2);
        // Register the user with the new name
        let user_info = User {
            name: name,
            questions: smart_vector::new<u64>()
        };
        smart_table::add(&mut table, user_addr, user_info);
    }

// ======================== Helper functions ========================
    #[view]
    public fun state_object_address(): address {
        object::create_object_address(@guide_me_addr, OBJECT_NAME)
    }

    #[view]
    public fun state_object(): Object<GlobalData> {
        object::address_to_object(state_object_address())
    }
 // ======================== Unit Tests ========================

    #[test_only]
    use std::string;

    #[test(sender = @guide_me_addr)]
    fun test_end_to_end<>(sender: &signer) acquires AskAroundObject {
        init_module(sender);
        register_user(sender, string::utf8(b"Sourabh"));
        std::debug::print(&b"Registered");
    }
}