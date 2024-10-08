module guide_me_addr::guide_me{
    use std::string::{Self, String};
    use aptos_framework::object::{Self, Object};
    use aptos_std::smart_table::{Self,SmartTable};
    use aptos_std::smart_vector::{Self,SmartVector};
    // use std::option::{Option, none, some};
    use std::signer;
    use std::vector;

    const OBJECT_NAME: vector<u8> = b"AskAroundObject";
    
    const E_UNEXPECTED_VALUE:u64 = 1;
    const E_KEY_NOT_FOUND:u64 = 2;

    const QUESTION_RETRIEVE_COUNT:u64 = 20;
    
    struct Question has store,copy,drop{ //why drop??
        id: u64,
        asker: address,
        content: String,
        tag: String,
        answered: bool,
        best_answer_id: u64,
        timestamp: u64 //pending
    }
    struct Answer has store, copy, drop {
        answerer: address,
        content: String,
        timestamp: u64
    }
    struct User has store{
        name: String,
        questions: SmartVector<u64>
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
        questions: SmartVector<Question>,
        answers: SmartVector<SmartVector<Answer>>,
        tags: SmartTable<String, Tag>,//global
        user_tags: SmartTable<address, SmartTable<String, UserTag>>,
        // stakes: SmartTable<address,u64>, //Pending
        tag_to_questions: SmartTable<String, SmartVector<u64>>,
        tag_keys: SmartVector<String>,
        users:  SmartTable<address, User>
    }
    fun init_module(owner: &signer) {
       
        assert!(!exists<AskAroundObject>(@guide_me_addr), 0);
        let ask_around_object_constructor_ref = &object::create_named_object(owner,OBJECT_NAME);
        let object_signer = &object::generate_signer(ask_around_object_constructor_ref);
        // move_to is a function to move the struct to the global storage
        move_to(object_signer, AskAroundObject {
            owner: @guide_me_addr ,
            questions: smart_vector::new(),
            answers: smart_vector::new(),
            tags: smart_table::new(),
            user_tags: smart_table::new(),
            // stakes: smart_table::new<address,u64>(),
            tag_to_questions:smart_table::new(),
            tag_keys: smart_vector::new(),
            users: smart_table::new()
        });
    }
    public entry fun register_user(
        user: &signer,
        name: String
    ) acquires AskAroundObject {
        let user_addr = signer::address_of(user);

        // Check that the name is not empty
        assert!(string::length(&name) > 0, E_UNEXPECTED_VALUE);

        // Check that the name length is within acceptable limits (1 to 100 characters)
        assert!(string::length(&name) <= 100, E_UNEXPECTED_VALUE);
        let a_a_object = borrow_global_mut<AskAroundObject>(state_object_address());
        let table = &a_a_object.users;
        assert!(!smart_table::contains(table, user_addr),E_KEY_NOT_FOUND);
        // Register the user with the new name
        let user_info = User {
            name: name,
            questions: smart_vector::new<u64>()
        };
        smart_table::add(&mut a_a_object.users, user_addr, user_info);
        smart_table::add(&mut a_a_object.user_tags, user_addr, smart_table::new());
        std::debug::print(&string::utf8(b"User Registered"));
        std::debug::print(&name);
    }
    //add a tag
    public entry fun add_tag(
        user: &signer,
        tag: String
    ) acquires AskAroundObject {
        let user_addr = signer::address_of(user);
        // let user_tags = SmartTable<String, UserTag>;
        assert!(string::length(&tag) > 0 && string::length(&tag) <= 10, E_UNEXPECTED_VALUE);
        
        let a_a_object = borrow_global_mut<AskAroundObject>(state_object_address());
        let tags = &a_a_object.tag_keys;
        if (!smart_vector::contains(tags, &tag)){
            smart_vector::push_back(&mut a_a_object.tag_keys,tag);
            let tag_ob = Tag {
                user_count: 0
            };
            smart_table::add(&mut a_a_object.tags,tag,tag_ob);
            smart_table::add(&mut a_a_object.tag_to_questions,tag,smart_vector::new());
        };
        let user_tags = smart_table::borrow_mut(&mut a_a_object.user_tags, user_addr);
        if (smart_table::contains(user_tags,tag) ){
            let user_tag = smart_table::borrow(user_tags, tag);
            assert!(!user_tag.exists, E_UNEXPECTED_VALUE)
        };
        // Register the userTag
        let user_tag = UserTag {
            exists: true,
            timestamp: 0,
            last_claimed: 0,
            best_answer_count: 0
        };
        smart_table::add(user_tags , tag, user_tag);
        let tag_count = smart_table::borrow_mut(&mut a_a_object.tags,tag);
        tag_count.user_count = tag_count.user_count + 1;
        
        std::debug::print(&string::utf8(b"Added Tag"));
        std::debug::print(&tag);
        std::debug::print(&string::utf8(b"User Count"));
        std::debug::print(&smart_table::borrow(&a_a_object.tags,tag).user_count);
    }

    //remove a tag
    public entry fun remove_tag(
        user: &signer,
        tag: String
    ) acquires AskAroundObject {
        let user_addr = signer::address_of(user);
        // let user_tags = SmartTable<String, UserTag>;
        assert!(string::length(&tag) > 0 && string::length(&tag) <= 10, E_UNEXPECTED_VALUE);
        let a_a_object = borrow_global_mut<AskAroundObject>(state_object_address());
        assert!(TagExists(&a_a_object.user_tags,user_addr,tag), E_UNEXPECTED_VALUE);
        
      
        let user_tags = smart_table::borrow_mut(&mut a_a_object.user_tags, user_addr);
        let user_tag = smart_table::borrow_mut(user_tags, tag);
        assert!(user_tag.exists, E_UNEXPECTED_VALUE);
        user_tag.exists = false;
        // Register the userTag
        let tag_count = smart_table::borrow_mut(&mut a_a_object.tags,tag);
        tag_count.user_count = tag_count.user_count - 1;
        std::debug::print(&string::utf8(b"Removed Tag"));
        std::debug::print(&tag);
        std::debug::print(&string::utf8(b"User Count"));
        std::debug::print(&smart_table::borrow(&a_a_object.tags,tag).user_count);
    //logic to remove tag if users are zero
    }
// Ask A Qusetion
    public entry fun ask_question(
        user: &signer,
        tag: String,
        content: String
    ) acquires AskAroundObject{
        let user_addr = signer::address_of(user);
        let a_a_object = borrow_global_mut<AskAroundObject>(state_object_address());
        assert!(string::length(&content) > 0, 5);
        assert!(TagExists(&a_a_object.user_tags,user_addr,tag), E_UNEXPECTED_VALUE);
        // Create a new question
        let q_num = smart_vector::length(&a_a_object.questions);
        let question = Question {
            id: q_num,
            asker: user_addr,
            content: content,
            tag: tag,
            answered: false,
            best_answer_id: 1,
            timestamp: 0
        };
        smart_vector::push_back(&mut a_a_object.questions, question);
        let user_info = smart_table::borrow_mut(&mut a_a_object.users, user_addr);
        smart_vector::push_back(&mut user_info.questions, q_num);
        smart_vector::push_back(&mut a_a_object.answers, smart_vector::new());
        smart_vector::push_back(smart_table::borrow_mut(&mut a_a_object.tag_to_questions,tag),q_num);
    }

    // answer a question
    public entry fun submit_answer(
        user: &signer,
        q_id: u64,
        tag: String,
        content: String
    ) acquires AskAroundObject{
        let user_addr = signer::address_of(user);
        let a_a_object = borrow_global_mut<AskAroundObject>(state_object_address());
        assert!(string::length(&content) > 0, 5);
        assert!(TagExists(&a_a_object.user_tags,user_addr,tag), E_UNEXPECTED_VALUE);
        // Create a new question
        let q_num = smart_vector::length(&a_a_object.questions);
        assert!(q_id < q_num, E_UNEXPECTED_VALUE);
        let answer = Answer {
            answerer: user_addr,
            content: content,
            timestamp: 0
        };
        let answer_vector = smart_vector::borrow_mut(&mut a_a_object.answers, q_id);
        smart_vector::push_back( answer_vector, answer);
    } 

    public fun selectBestAnswer(
        user: &signer,
        q_id:u64,
        a_id: u64
        ) acquires AskAroundObject{
        let user_addr = signer::address_of(user);
        let a_a_object = borrow_global_mut<AskAroundObject>(state_object_address());
        assert!(user_addr == smart_vector::borrow(& a_a_object.questions,q_id).asker,E_UNEXPECTED_VALUE);
        let question =  smart_vector::borrow_mut(&mut a_a_object.questions,q_id);
        let answer = smart_vector::borrow(smart_vector::borrow(&a_a_object.answers,q_id),a_id);
        assert!(user_addr != answer.answerer,E_UNEXPECTED_VALUE);
        question.best_answer_id = a_id;
        question.answered = true;
        let user_tag = smart_table::borrow_mut(smart_table::borrow_mut(&mut a_a_object.user_tags, answer.answerer),question.tag);
        user_tag.best_answer_count = user_tag.best_answer_count+ 1;

    }
    
// ======================== Helper functions ========================
    #[view]
    public fun state_object_address(): address {
        object::create_object_address(&@guide_me_addr, OBJECT_NAME)
    }

    #[view]
    public fun state_object(): Object<AskAroundObject> {
        object::address_to_object(state_object_address())
    }
    
    #[view]//get question by ID
    public fun getQuestionsbyID(q_vec:vector<u64>): vector<Question> acquires AskAroundObject{
        assert!(vector::length(&q_vec) <=QUESTION_RETRIEVE_COUNT, E_UNEXPECTED_VALUE);
        let a_a_object = borrow_global<AskAroundObject>(state_object_address());
        let q_vec = vector::map_ref(&q_vec,|q_id| *smart_vector::borrow(& a_a_object.questions, *q_id));
        return q_vec
    }

    #[view] //get answer for a question
    public fun getAnswers(q_id: u64): vector<Answer> acquires AskAroundObject{
       let a_a_object = borrow_global<AskAroundObject>(state_object_address());
            let answer_vector = smart_vector::borrow(& a_a_object.answers, q_id);
            return smart_vector::to_vector(answer_vector)
    }

    // #[view] //get username from address
    public fun getUsername(user_addr: address): String acquires AskAroundObject{
        let a_a_object = borrow_global<AskAroundObject>(state_object_address());
        let user_obj = smart_table::borrow(&a_a_object.users,user_addr);
        return user_obj.name
    }
    // #[view] // get best anser count
    #[view]//get questionsID by tag
    public fun getQuestionsIdbyTag(tag: String,page:u64): vector<u64> acquires AskAroundObject{
        let a_a_object = borrow_global<AskAroundObject>(state_object_address());
        let q_num = smart_vector::length(smart_table::borrow(&a_a_object.tag_to_questions,tag));
        assert!(page>0,E_UNEXPECTED_VALUE);
        let start = 0;
        if( page*QUESTION_RETRIEVE_COUNT < q_num ){
            start = q_num - page*QUESTION_RETRIEVE_COUNT;
        };
        let max_end= start+QUESTION_RETRIEVE_COUNT; 
        let results = vector[];
        while(start <q_num && start <max_end) {
            let q_id = *smart_vector::borrow(smart_table::borrow(&a_a_object.tag_to_questions,tag),start);
            vector::push_back(&mut results, q_id);
            start = start + 1;
        };
        results
    }
    // #[view] //getTagKeys
    public fun getTagKeys(): vector<String>acquires AskAroundObject{
        let a_a_object = borrow_global<AskAroundObject>(state_object_address());
        return smart_vector::to_vector(& a_a_object.tag_keys)
    }
    // #[view]//get best answer count 
    // #[view]



    public fun TagExists(user_tags: &SmartTable<address, SmartTable<String, UserTag>>, user_addr: address, tag: String): bool {
        let user_tag = smart_table::borrow(user_tags, user_addr);
        if (smart_table::contains(user_tag,tag) ){
            std::debug::print(&string::utf8(b"Tag is present"));
            let user_tag = smart_table::borrow(user_tag, tag);
            return user_tag.exists
        };
        std::debug::print(&string::utf8(b"Tag is Not present"));
        return false
    }

 // ======================== Unit Tests ========================

    #[test(sender = @guide_me_addr, tester = @tester_addr)]
    fun test_end_to_end<>(sender: &signer, tester :& signer) acquires AskAroundObject {
        init_module(sender);
        register_user(sender, string::utf8(b"Sourabh"));
        register_user(tester, string::utf8(b"Thakur"));
        let tag1 = string::utf8(b"Coding");
        let question1 = string::utf8(b"which language is easy?");
        let answer1 = string::utf8(b"all are same, try python");
        let answer2 = string::utf8(b"dekh bhai language");
        add_tag(sender, tag1 );
        add_tag(tester, tag1 );
        add_tag(sender, string::utf8(b"Guitar"));
        ask_question(sender,tag1,question1);
        submit_answer(tester,0,tag1, answer1);
        submit_answer(tester,0,tag1, answer2);
        let tag_keys:vector<String> = getTagKeys();
        vector::for_each(tag_keys, |x| std::debug::print(&x));
        let q_id_vec = getQuestionsIdbyTag(tag1,1);
        vector::for_each(q_id_vec, |x| std::debug::print(&x));
        let q_vec:vector<Question>  = getQuestionsbyID(q_id_vec);
        // let question = vector::borrow(&q_vec,0);
        let v_length = vector::length(&q_vec);
        let i = 0;
        while (i < v_length) {
            let x = vector::borrow(&q_vec, i);
            std::debug::print(&x.content);
            i = i + 1;
        };
        let a_vec = getAnswers(0);
        v_length = vector::length(&a_vec);
        i = 0;
        while (i < v_length) {
            let x = vector::borrow(&a_vec, i);
            std::debug::print(&x.content);
            i = i + 1;
        };
        selectBestAnswer(sender,0,1);
        let q_vec:vector<Question>  = getQuestionsbyID(q_id_vec);
        let question = vector::borrow(&q_vec,0);
        std::debug::print(&question.asker);
        std::debug::print(&question.content);
        std::debug::print(&question.answered);
        std::debug::print(&question.best_answer_id);
        remove_tag(sender, string::utf8(b"Guitar"));
    }
    #[test(sender = @guide_me_addr)]
    #[expected_failure(abort_code = E_UNEXPECTED_VALUE)]
    fun test_question_without_tag<>(sender: &signer) acquires AskAroundObject {
        init_module(sender);
        register_user(sender, string::utf8(b"Sourabh"));
        add_tag(sender, string::utf8(b"Hello"));
        ask_question(sender,string::utf8(b"Hello2"),string::utf8(b"Wassdupp hahaha"),); 
    }
    

    #[test(sender = @guide_me_addr)]
    #[expected_failure(abort_code = E_UNEXPECTED_VALUE)]
    fun test_duplicate_tag_add<>(sender: &signer) acquires AskAroundObject {
        init_module(sender);
        register_user(sender, string::utf8(b"Sourabh"));
        add_tag(sender, string::utf8(b"Hello"));
        add_tag(sender, string::utf8(b"Hello"));

    }
    #[test(sender = @guide_me_addr)]
    #[expected_failure(abort_code = E_KEY_NOT_FOUND)]
    fun test_double_reg<>(sender: &signer) acquires AskAroundObject {
        init_module(sender);
        register_user(sender, string::utf8(b"Sourabh"));
        let str: String = string::utf8(b"Registered");
        std::debug::print(&str);
        register_user(sender, string::utf8(b"Sourabh"));
    }
    #[test(sender = @guide_me_addr)]
    #[expected_failure(abort_code = E_UNEXPECTED_VALUE)]
    fun test_emplty_name<>(sender: &signer) acquires AskAroundObject {
        init_module(sender);
        register_user(sender, string::utf8(b""));
        let str: String = string::utf8(b"Registered");
        std::debug::print(&str);
    }
    #[test(sender = @guide_me_addr)]
    fun test_get_name<>(sender: &signer) acquires AskAroundObject {
        init_module(sender);
        register_user(sender, string::utf8(b"sOUR"));
        let str: String = string::utf8(b"Registered");
        std::debug::print(&str);
        std::debug::print(&getUsername(signer::address_of(sender)))
    }
}