let subset_test0 = subset [] []
let subset_test1 = not (subset [1] [])
let subset_test2 = subset [] [1]

let equal_sets_test0 = equal_sets [] []
let equal_sets_test1 = not (equal_sets [1] [])

let set_union_test0 = equal_sets (set_union [1;2;3] [1;2;3;4]) [1;2;3;4]
let set_union_test1 = equal_sets (set_union [1;2;3] []) [1;2;3] (* checking other order than provided testcases *)
					    
let set_intersection_test0 = equal_sets (set_intersection [] []) []
let set_intersection_test1 =  equal_sets (set_intersection [1;2;3] []) [] (* check other order *)

let set_diff_test0 = equal_sets (set_diff [] []) []
let set_diff_test1 = equal_sets (set_diff  [1] [] ) [1]

let computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x * 10) 1000000000 = 0

let computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> x * -1) 1 1 = 1

let while_away_test0 = while_away ((+) 3) ((<) 10) 0 = [] 
let while_away_test1 = while_away ((+) 3) ((>) 15) 0 = [0; 3; 6; 9; 12]

let rle_decode_test0 = rle_decode [0,"z"; 1,""] = [""]
let rle_decode_test1 = rle_decode [2,"Gg"] = ["Gg"; "Gg"];

(*grammar from assignment *)
type awksub_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num

let awksub_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];
    Num, [T"1"];
    Num, [T"2"];
    Num, [T"3"];
    Num, [T"4"];
    Num, [T"5"];
    Num, [T"6"];
    Num, [T"7"];
    Num, [T"8"];
    Num, [T"9"]]


let filter_blind_alleys_test0 = filter_blind_alleys (Expr,[]) = (Expr,[])
let filter_blind_alleys_test1 = filter_blind_alleys (awksub_rules, awksub_rules) = (awksub_rules, awksub_rules)
let filter_blind_alleys_test2 = filter_blind_alleys (awksub_rules , List.rev awksub_rules) = (awksub_rules , List.rev awksub_rules)  (* make sure order is maintained *)
