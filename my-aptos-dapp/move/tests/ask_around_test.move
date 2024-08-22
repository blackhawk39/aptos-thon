// #[test_only]
// module 0x1::AskAroundTest {
//     use 0x1::Assert;
//     use 0x1::Vector;
//     use 0x1::Timestamp;
//     use 0x1::AskAround;

//     // Test data initialization
//     #[test]
//     public fun test_initialize() {
//         // Create an instance of the AskAround contract
//         let owner = @0x1;
//         let ask_around = AskAround::new(&owner);
//         // let my_0x1_signer = account::create_signer_for_test(@0x1);
//         // let my_0x1_signer = &account::create_account_for_test(@0x1);
//         // Assert that the owner is set correctly
//         Assert::assert(Signer::address_of(&owner) == ask_around.owner, 100);

//         // Assert that the initial question vector is empty
//         Assert::assert(Vector::length(&ask_around.questions) == 0, 101);

//         // Assert that there are no tags initially
//         Assert::assert(Vector::length(&ask_around.tag_keys) == 0, 102);
//     }

//     // Test user registration
// //     #[test(user_1 = @0x123, user_2 = @0x234)]
// // #[expected_failure(abort_code = 1)]
// // fun test_with_signers_and_error(user_1: &signer, user_2: &signer)
//     public fun test_register_user() {
//         let owner = @0x1;
//         let mut ask_around = AskAround::new(&owner);

//         let user = @0x2;
//         let user_name = b"User1";

//         // Register the user
//         AskAround::register_user(&mut ask_around, &user, user_name);

//         // Assert that the user is registered correctly
//         let user_info = Vector::borrow(&ask_around.users, 0);
//         Assert::assert(Vector::equals(&user_info.name, user_name), 103);
//         Assert::assert(Vector::length(&user_info.questions) == 0, 104);
//     }

//     // Test adding a tag
//     public fun test_add_tag() {
//         let owner = @0x1;
//         let mut ask_around = AskAround::new(&owner);

//         let user = @0x2;
//         let tag = b"TECH";
//         let stake_amount = 1000000;

//         // Add a tag
//         AskAround::add_tag(&mut ask_around, &user, tag, stake_amount);

//         // Assert that the tag is added correctly
//         let tag_info = Vector::borrow(&ask_around.tags, 0);
//         Assert::assert(tag_info.user_count == 1, 105);
//         Assert::assert(Vector::equals(&Vector::borrow(&ask_around.tag_keys, 0), tag), 106);
//     }

//     // Test asking a question
//     public fun test_ask_question() {
//         let owner = @0x1;
//         let mut ask_around = AskAround::new(&owner);

//         let user = @0x2;
//         let tag = b"TECH";
//         let stake_amount = 1000000;
//         let content = b"What is Move language?";

//         // Add a tag before asking a question
//         AskAround::add_tag(&mut ask_around, &user, tag, stake_amount);

//         // Ask a question
//         AskAround::ask_question(&mut ask_around, &user, content, tag);

//         // Assert that the question is added correctly
//         let question = Vector::borrow(&ask_around.questions, 0);
//         Assert::assert(Vector::equals(&question.content, content), 107);
//         Assert::assert(question.asker == Signer::address_of(&user), 108);
//         Assert::assert(Vector::equals(&question.tag, tag), 109);
//     }

//     // Test submitting an answer
//     public fun test_submit_answer() {
//         let owner = @0x1;
//         let mut ask_around = AskAround::new(&owner);

//         let user = @0x2;
//         let tag = b"TECH";
//         let stake_amount = 1000000;
//         let question_content = b"What is Move language?";
//         let answer_content = b"Move is a programming language for smart contracts.";

//         // Add a tag and ask a question before submitting an answer
//         AskAround::add_tag(&mut ask_around, &user, tag, stake_amount);
//         AskAround::ask_question(&mut ask_around, &user, question_content, tag);

//         // Submit an answer
//         AskAround::submit_answer(&mut ask_around, &user, 0, answer_content);

//         // Assert that the answer is added correctly
//         let answers = Vector::borrow(&ask_around.answers, 0);
//         let answer = Vector::borrow(answers, 0);
//         Assert::assert(Vector::equals(&answer.content, answer_content), 110);
//         Assert::assert(answer.answerer == Signer::address_of(&user), 111);
//     }

//     // Test selecting the best answer
//     public fun test_select_best_answer() {
//         let owner = @0x1;
//         let mut ask_around = AskAround::new(&owner);

//         let user = @0x2;
//         let tag = b"TECH";
//         let stake_amount = 1000000;
//         let question_content = b"What is Move language?";
//         let answer_content = b"Move is a programming language for smart contracts.";

//         // Add a tag, ask a question, and submit an answer before selecting the best answer
//         AskAround::add_tag(&mut ask_around, &user, tag, stake_amount);
//         AskAround::ask_question(&mut ask_around, &user, question_content, tag);
//         AskAround::submit_answer(&mut ask_around, &user, 0, answer_content);

//         // Select the best answer
//         AskAround::select_best_answer(&mut ask_around, &user, 0, 0);

//         // Assert that the best answer is selected correctly
//         let question = Vector::borrow(&ask_around.questions, 0);
//         Assert::assert(question.best_answer_id == 0, 112);
//         Assert::assert(question.answered == true, 113);
//     }

//     // Test removing a tag
//     public fun test_remove_tag() {
//         let owner = @0x1;
//         let mut ask_around = AskAround::new(&owner);

//         let user = @0x2;
//         let tag = b"TECH";
//         let stake_amount = 1000000;

//         // Add a tag before removing it
//         AskAround::add_tag(&mut ask_around, &user, tag, stake_amount);

//         // Remove the tag
//         AskAround::remove_tag(&mut ask_around, &user, tag);

//         // Assert that the tag is removed correctly
//         Assert::assert(Vector::length(&ask_around.tags) == 0, 114);
//         Assert::assert(Vector::length(&ask_around.tag_keys) == 0, 115);
//     }

//     // Test claiming a reward
//     public fun test_claim_reward() {
//         let owner = @0x1;
//         let mut ask_around = AskAround::new(&owner);

//         let user = @0x2;
//         let tag = b"TECH";
//         let stake_amount = 1000000;

//         // Add a tag and simulate some time passage before claiming the reward
//         AskAround::add_tag(&mut ask_around, &user, tag, stake_amount);
//         let timestamp = Timestamp::now_microseconds() + 1000000;

//         // Claim the reward
//         AskAround::claim_reward(&mut ask_around, &user, tag);

//         // No specific asserts here since reward logic is simplified,
//         // but normally you would assert that the reward is correctly calculated and transferred.
//     }
// }
