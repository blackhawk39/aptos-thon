module owner::main_test {
    #[test_only]
    use owner::main;

    #[test_only]
    use std::string;

    #[test_only]
    use std::debug::print;

    #[test_only]
    fun setup(owner: &signer){
        main::initialize(owner);
    }

    #[test(owner=@owner, alice=@0xCAFE)]
    fun test_create_tag(owner: &signer, alice: &signer) {
        setup(owner);
        main::create_tag(alice, string::utf8(b"programming"));
        // main::create_tag(alice, string::utf8(b"coding")); // Timeout
        print(&main::num_tag());
    }

    #[test(owner=@owner, alice=@0xCAFE)]
    #[expected_failure]
    fun test_fail_create_tag(owner: &signer, alice: &signer) {
        setup(owner);
        main::create_tag(alice, string::utf8(b"programming"));
        main::create_tag(alice, string::utf8(b"programming"));
    }

}