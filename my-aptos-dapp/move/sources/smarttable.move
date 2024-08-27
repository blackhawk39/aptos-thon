module guide_me_addr::smart_table_usage {
    use aptos_std::smart_table;
 
    public entry fun main() {
        let table = smart_table::new<u64, u64>();
        smart_table::add(&mut table, 1, 100);
        smart_table::add(&mut table, 2, 200);
        std::debug::print(&b"Registered");
        let length = smart_table::length(&table);
        assert!(length == 2, 0);
        
        let value1 = smart_table::borrow(&table, 1);
        assert!(*value1 == 100, 0);
        
        let value2 = smart_table::borrow(&table, 2);
        assert!(*value2 == 200, 0);
        
        let removed_value = smart_table::remove(&mut table, 1);
        assert!(removed_value == 100, 0);
        
        smart_table::destroy_empty(table);
    }
}