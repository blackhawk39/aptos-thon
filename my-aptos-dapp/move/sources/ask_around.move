// module message_board_addr::AskAround {
//     use std::Signer;
//     use std::Timestamp;
//     use aptos_std::vector;

//     struct Question {
//         id: u64,
//         asker: address,
//         content: vector<u8>,
//         tag: vector<u8>,
//         answered: bool,
//         best_answer_id: u64,
//         timestamp: u64
//     }

//     struct Answer {
//         answerer: address,
//         content: vector<u8>,
//         timestamp: u64
//     }

//     struct User {
//         name: vector<u8>,
//         questions: vector<u64>
//     }

//     struct Tag {
//         user_count: u64
//     }

//     struct UserTag {
//         exists: bool,
//         timestamp: u64,
//         last_claimed: u64,
//         best_answer_count: u64
//     }

//     struct AskAround {
//         owner: address,
//         questions: vector<Question>,
//         answers: vector<vector<Answer>>,
//         tags: vector<Tag>,
//         user_tags: vector<UserTag>,
//         stakes: vector<u128>,
//         tag_to_questions: vector<vector<u64>>,
//         tag_keys: vector<vector<u8>>,
//         users: vector<User>,
//     }

//     public fun new(owner: &signer): AskAround {
//         let owner_addr = Signer::address_of(owner);
//         AskAround {
//             owner: owner_addr,
//             questions: vector::empty<Question>(),
//             answers: vector::empty<vector<Answer>>(),
//             tags: vector::empty<Tag>(),
//             user_tags: vector::empty<UserTag>(),
//             stakes: vector::empty<u128>(),
//             tag_to_questions: vector::empty<vector<u64>>(),
//             tag_keys: vector::empty<vector<u8>>(),
//             users: vector::empty<User>()
//         }
//     }

//     // Register a user
//     public fun register_user(
//         self: &mut AskAround,
//         user: &signer,
//         name: vector<u8>
//     ) {
//         let user_addr = Signer::address_of(user);

//         // Check that the name is not empty
//         assert!(vector::length(&name) > 0, 1);

//         // Check that the name length is within acceptable limits (1 to 100 characters)
//         assert!(vector::length(&name) <= 100, 2);

//         // Register the user with the new name
//         let user_info = User {
//             name: name,
//             questions: vector::empty<u64>()
//         };
//         vector::push_back(&mut self.`, user_info);
//     }

//     // Add a tag
//     public fun add_tag(
//         self: &mut AskAround,
//         user: &signer,
//         tag: vector<u8>,
//         stake_amount: u128
//     ) {
//         assert!(vector::length(&tag) > 0 && vector::length(&tag) <= 10, 3);

//         // Add tag logic here
//         let tag_info = Tag { user_count: 1 };
//         vector::push_back(&mut self.tags, tag_info);
//         vector::push_back(&mut self.tag_keys, tag);
//     }

//     // Ask a question
//     public fun ask_question(
//         self: &mut AskAround,
//         user: &signer,
//         content: vector<u8>,
//         tag: vector<u8>
//     ) {
//         assert!(vector::length(&content) > 0, 4);

//         // Create a new question
//         let question = Question {
//             id: vector::length(&self.questions),
//             asker: Signer::address_of(user),
//             content: content,
//             tag: tag,
//             answered: false,
//             best_answer_id: 0,
//             timestamp: Timestamp::now_microseconds()
//         };
//         vector::push_back(&mut self.questions, question);
//     }

//     // Submit an answer
//     public fun submit_answer(
//         self: &mut AskAround,
//         user: &signer,
//         question_id: u64,
//         content: vector<u8>
//     ) {
//         assert!(vector::length(&content) > 0, 5);
//         let answer = Answer {
//             answerer: Signer::address_of(user),
//             content: content,
//             timestamp: Timestamp::now_microseconds()
//         };

//         // Add answer to the corresponding question
//         let answers_vec = vector::borrow_mut(&mut self.answers, question_id);
//         vector::push_back(answers_vec, answer);
//     }

//     // Select the best answer
//     public fun select_best_answer(
//         self: &mut AskAround,
//         user: &signer,
//         question_id: u64,
//         answer_id: u64
//     ) {
//         let question = vector::borrow_mut(&mut self.questions, question_id );
//         assert!(Signer::address_of(user) == question.asker, 6);

//         // Mark the best answer
//         question.best_answer_id = answer_id;
//         question.answered = true;
//     }

//     // Get all questions by a tag
//     // public fun get_questions_by_tag(
//     //     self: &AskAround,
//     //     tag: vector<u8>
//     // ): vector<Question> {
//     //     // Implement fetching questions by tag logic
//     //     let questions_by_tag = vector::empty<Question>();
//     //     let tag_index = vector::index_of(&self.tag_keys, tag).unwrap();

//     //     let question_ids = vector::borrow(&self.tag_to_questions, tag_index );
//     //     for question_id in question_ids.iter() {
//     //         let question = vector::borrow(&self.questions, *question_id);
//     //         vector::push_back(&mut questions_by_tag, question);
//     //     }

//     //     questions_by_tag
//     // }

//     // Remove tag functionality
//     public fun remove_tag(
//         self: &mut AskAround,
//         user: &signer,
//         tag: vector<u8>
//     ) {
//         let tag_index = vector::index_of(&self.tag_keys, tag).unwrap();
//         vector::remove(&mut self.tags, tag_index);
//         vector::remove(&mut self.tag_keys, tag_index);
//     }

//     // Claim reward
//     public fun claim_reward(
//         self: &mut AskAround,
//         user: &signer,
//         tag: vector<u8>
//     ) {
//         // Reward claiming logic here
//     }
//     #[test]
//     public fun test_register_user() {
//         let owner = @message_board_addr;
//         let ask_around = AskAround::new(&owner);

//         let user = @message_board_addr;
//         let user_name = b"User1";

//         // Register the user
//         AskAround::register_user(&mut ask_around, &user, user_name);

//         // Assert that the user is registered correctly
//         let user_info = vector::borrow(&ask_around.users, 0);
//         Assert::assert(vector::equals(&user_info.name, user_name), 103);
//         Assert::assert(vector::length(&user_info.questions) == 0, 104);
//     }
// }
